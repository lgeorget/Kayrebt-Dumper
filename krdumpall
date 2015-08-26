#!/bin/bash

set -x

CONFIG="config"
TREE="/home/lgeorget/Documents/THESE/linux/"
CLEAN=1
VERSION="master"
DB_PATH=""
NO_CLONE=0

while getopts ":ht:kV:c:ND:" opt; do
  case $opt in
    h)
cat <<EOF
Usage: $0 [-c [<config file>]] [-t [<linux source tree path>]] [-k]
          [-V <tag or commit>] [-N] [-D <database path>]

$0 is used to extract activity diagrams from functions of the Linux kernel code
base.
The options '-c' and '-t' take exactly one argument, which has a default value:
	-c <config file>: this parameter is the path of the config file.
	The configuration is written in YAML. The configuration should look like
	the following:
		- general:
			- greedy: 1
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
	-N: do not clone the kernel source tree provided by the -t option but use
	it directly. Of course, it must be a local path. You may want to 'make
	clean' it first as $0 will not do it for you.
	-D <database path>: produce a symbol database from the dump
EOF
      exit 0
      ;;
    \?)
      echo "Usage: $0 [-c [<config file>]] [-t [<linux source tree path>]] [-k]" >&2
      echo "       [-V <tag or commit>] [-N] [-D <database path>]" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      echo "Usage: $0 [-c [<config file>]] [-t [<linux source tree path>]] [-k]" >&2
      echo "       [-V <tag or commit>] [-N] [-D <database path>]" >&2
      exit 1
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
    N)
      NO_CLONE=1
      ;;
    D)
      DB_PATH="$OPTARG"
      ;;
  esac
done

error=0
if [[ ! -e $CONFIG ]] || [[ ! -r $CONFIG ]]
then
	echo "The configuration file \"$CONFIG\" does not exist or is not readable." >&2
	echo "See $0 -h for help." >&2
	error=1
fi

if [[ $NO_CLONE ]] && ([[ ! -e $TREE ]] || [[ ! -d $TREE ]] || [[ ! -x $TREE ]])
then
	echo "You want to use \"$TREE\" as the source tree but it's either not" >&2
	echo "a local path or a local path that is not accessible" >&2
	echo "Do you have sufficient permission?" >&2
	echo "See $0 -h for help." >&2
	error=1
fi

[[ $error == 1 ]] && exit 2

OLDDIR=$(pwd)
tree_clone=""
if [[ $NO_CLONE == 1 ]]
then
	tree_clone=$TREE
	cd $tree_clone
	git fetch origin $VERSION
else
	tree_clone=$(mktemp -d)
	git clone $TREE $tree_clone
	cd $tree_clone
	git remote add linux  git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
	git fetch linux $VERSION
fi
git checkout FETCH_HEAD || exit 3
rm -f .config
make defconfig || exit 4
if [[ "$DB_PATH" != "" ]]
then
cat <<EOF >>.config
CONFIG_DEBUG_INFO_SPLIT=y
CONFIG_DEBUG_INFO_DWARF4=y
EOF
fi

cd "$OLDDIR"
cp "$CONFIG" "$tree_clone/config"
make CFLAGS_KERNEL="-fplugin=cgrapher4gcc -x c"  -C "$tree_clone" bzImage
stripped_tree_clone=${tree_clone#\/}
find $tree_clone -name '*.c.dump' | tar cf dump-linux-"$VERSION".tar --transform "s/"${stripped_tree_clone//\//\\\/}"/linux-"${VERSION//\//_}"/" -T -

if [[ "$DB_PATH" != "" ]]
then
	cd "$tree_clone"
	extract_global_symbols.pl > $DB_PATH
	cd "$OLDDIR"
fi

if [[ $NO_CLONE == 0 ]] && [[ $CLEAN == 1 ]]
then
	rm -rf $tree_clone
fi

