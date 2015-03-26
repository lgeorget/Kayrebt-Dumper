#!/bin/bash

set -x

SOURCES="sources"
CONFIG="config"
TREE="/home/lgeorget/Documents/THESE/linux/"
CLEAN=1
VERSION="master"

while getopts ":hs:kV:c:" opt; do
  case $opt in
    h)
cat <<EOF
Usage: $0 -s <source files list> -c <config file> -t <linux source tree path>

$0 is used to extract activity diagrams from functions of the Linux kernel code
base.
The options '-s' and '-t' take exactly one argument, which have a
default value:
	-s <source files list>: this parameter is the path of a file
	containing the list of files to compile, one per line.
	The files must be given as path relative to the kernel top directory.
	The functions of the functions list should be a subset of the functions
	implemented in those files. Otherwise, some diagrams will be missing.
	The default value is "$SOURCES".
	-c <config file>: this parameter is the path of the config file.
	The configuration is written in YAML. The configuration should look like
	the following:
		- general:
			- category:
				- 1: <how to output category 1 nodes and edges>
				- 2: <how to output category 2 nodes and edges>
				-...
		- <source file (relative path from the kernel source tree root)>:
			- category: <overload of the 'general' section's 'category'
			- functions: [<list of functions to graph in this file>]
		- <other source file>:
		...
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
      echo "Usage: $0 -s <source files list>" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
    s)
      SOURCES="$OPTARG"
      ;;
    c)
      CONFIG="$OPTARG"
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
if [[ ! -e $SOURCES ]] || [[ ! -r $SOURCES ]]
then
	echo "The source files list \"$SOURCES\" does not exist or is not readable." >&2
	echo "See $0 -h for help." >&2
	error=1
fi

if [[ ! -e $CONFIG ]] || [[ ! -r $CONFIG ]]
then
	echo "The configuration file \"$CONFIG\" does not exist or is not readable." >&2
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
git add remote linux  git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
git fetch linux
git checkout $VERSION || exit 3
rm -f .config
make defconfig || exit 4
cd "$OLDDIR"
cp "$CONFIG" "$tree_clone/config"

make CFLAGS_KERNEL="-fplugin=cgrapher4gcc -x c"  -C "$tree_clone" bzImage
find $tree_clone -name '*.c.dump' | tar cvf dump-all.tar --transform "s/"${tree_clone//\//\\\/}"/linux-"${VERSION//\//\\\/}"/"-T -

# TODO : make all of this work somehow
#
#tar xvf dump-all.tar
#for i in *.c.dump
#do
#	./clip.pl < $i
#done
#for i in *.dot
#do
#	dot $i -Tpng > ${i/%dot/png}
#done

 if [[ $CLEAN == 1 ]]
 then
 	find \( -name '*.dump' -o -name '*.dot' \) -exec rm -f {} \+
 fi

 rm -rf $tree_clone

