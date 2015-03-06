#!/bin/bash

set -x

FUNCTIONS="functions"
SOURCES="sources"
TREE="/home/lgeorget/Documents/THESE/linux/"
CLEAN=1
VERSION="master"

while getopts ":hf:s:kV:" opt; do
  case $opt in
    h)
cat <<EOF
Usage: $0 -f <functions list> -s <source files list> -t <linux source tree path>

$0 is used to extract activity diagrams from functions of the Linux kernel code
base.
The three options '-f', '-s', and '-t' take exactly one argument, which have a
default value:
	-f <functions list>: this parameter is the path of a file containing
	the list of functions for which an activity diagram must be extracted,
	one function name per line. The default value is "$FUNCTIONS".
	-s <source files list>: this parameter is the path of a file
	containing the list of files to compile, one per line.
	The files must be given as path relative to the kernel top directory.
	The functions of the functions list should be a subset of the functions
	implemented in those files. Otherwise, some diagrams will be missing.
	The default value is "$SOURCES".
	-t <linux source tree path>: this parameter is the location of the linux
	source tree from which activity diagrams have to be extracted. The
	default value is "$TREE".
	-k: this flags when it is set tells $0 not to clean remove the temporary
	files after extracting activity diagrams (mnemonics: "keep").
	-V: this parameters tells $0 to checkout a specific version of the
	kernel. Any commit number or version tag is fine. The default is 'master'.
EOF
      exit 0
      ;;
    \?)
      echo "Usage: $0 -f <functions list> -s <source files list>" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
    f)
      FUNCTIONS="$OPTARG"
      ;;
    s)
      SOURCES="$OPTARG"
      ;;
    t)
      TREE="$OPTARG"
      ;;
    k)
      CLEAN=0
      ;;
    V)
      VERSION="$OPTARG"
      ;;
  esac
done

error=0
if [[ ! -e $FUNCTIONS ]] || [[ ! -r $FUNCTIONS ]]
then
	echo "The functions list \"$FUNCTIONS\" does not exist or is not readable." >&2
	echo "See $0 -h for help." >&2
	error=1
fi

if [[ ! -e $SOURCES ]] || [[ ! -r $SOURCES ]]
then
	echo "The source files list \"$SOURCES\" does not exist or is not readable." >&2
	echo "See $0 -h for help." >&2
	error=1
fi

if [[ ! -e $TREE ]] || [[ ! -d $TREE ]] || [[ ! -x $TREE ]]
then
	echo "The linux source tree path \"$TREE\" is invalid." >&2
	echo "Do you have sufficient permission?" >&2
	echo "See $0 -h for help." >&2
	error=1
fi

[[ $error == 1 ]] && exit 2

OLDDIR=$(pwd)
tree_clone=$(mktemp -d)
git clone $TREE $tree_clone
cd $tree_clone
git pull origin master
git checkout $VERSION || exit 3
rm -f .config
make defconfig || exit 4
cd "$OLDDIR"

cp "$FUNCTIONS" "$tree_clone"/graph.list
while read sourcefile
do
	make CFLAGS_KERNEL="-fplugin=cgrapher4gcc -x c -fplugin-arg-cgrapher4gcc-fn_list=graph.list"  -C "$tree_clone" "${sourcefile/%c/o}"
	cp "$tree_clone"/"$sourcefile".dump .
done < "$SOURCES"

for i in *.dump
do
	./clip.pl < $i
done
for i in *.dot
do
	dot $i -Tpng > ${i/%dot/png}
done

if [[ $CLEAN == 1 ]]
then
	find \( -name '*.dump' -o -name '*.dot' \) -exec rm -f {} \+
fi

rm -rf $tree_clone

