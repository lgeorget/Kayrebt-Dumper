# Kayrebt-Dumper

Wrapper for Kayrebt::Extractor to generate activity diagrams for any version of
the Linux kernel.

# Scripts documentation

## krdump

```
Usage: krdump [-s [<source files list>]] [-c [<config file>]]
              [-t [<linux source tree path>]] [-k] [-V <tag or commit>] [-N]

krdump is used to extract activity diagrams from functions of the Linux kernel code
base.
The options '-s', '-c'  and '-t' take exactly one argument, which has a
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
	-N: do not clone the kernel source tree provided by the -t option but use
	it directly. Of course, it must be a local path. You may want to 'make
	clean' it first as $0 will not do it for you.
```

## krdumpall

```
Usage: krdumpall [-c [<config file>]] [-t [<linux source tree path>]] [-k]
                 [-V <tag or commit>] [-N] [-D <database path>]

krdumpall is used to extract activity diagrams from functions of the Linux kernel code
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
```

## Example of use

We want to extract diagrams for linux v4.0 and build a database of symbols at
the same time (see project Kayrebt::Globsym to see what I'm talking about).

  ./krdumpall -V v4.0 -D ./linux-4.0.db -c configs/greedy_without_db

Actually, you don't want to pull from upstream each time. To reduce the load
on the server and clone quicker, clone from a local copy of the Linux kernel:

  ./krdumpall -V 4.0 -D ./linux-4.0.db -c configs/greedy_without_db -t ~/Documents/linux

Am I silly? I forgot the "v" in the version number (Kayrebt::Dumper can use any
Git tag or commit number as a version, the default is "master"). Fortunately, I
don't have to reclone the entire kernel another time:

  ./krdumpall -V v4.0 -D ./linux-4.0.db -c configs/greedy_without_db -t /tmp/tmp.bBpWv01MZn -N

Now that I have the symbol database for the Linux kernel, I can extract some
diagrams with hyperlinks:

  ./krdump -V v4.0 -c configs/selective_with_4.0-db -t /tmp/tmp.bBpWv01MZn -N

