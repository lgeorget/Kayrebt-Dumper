Cgrapher4gcc
============

Laurent Georget [<laurent.georget@inria.fr>](mailto:laurent.georget@inria.fr).
03/2015

Cgrapher4gcc is a tool from the Kayrebt tool set. Its purpose is to extract
automatically pseudo-UML2 activity diagrams from functions of the Linux kernel.
The diagrams can be useful for software visualization, static analysis, etc.


Inputs
------

Cgrapher4gcc receives two files as parameters : a file containing a list of
functions to draw and a file containing a list of files to compile containing
those functions (in order to avoid compiling the entire kernel to extract the
graph of one or two functions).

Parameters:
	-s <path>: the file containing the list of source files to compile
	(default: "sources")
	-f <path>: the file containing the list of functions to graph
	(default: "functions")
	-k: do not remove temporary files at the end of the execution
	-t <path>: select a different sources tree than the default one
	-V <commit>: select a specific commit in the kernel tree for diagram
	extraction (default: "master")

Outputs
-------

Cgrapher4gcc produces a graph under png format for each function in the function
list file that was compiled.
