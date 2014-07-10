This program finalizes the XML output of LXir.
It performs some transformations which I found hard to do in XSLT 1.0,
e.g. merging of nodes and some text processing.

It uses the pugixml library v1.4: http://pugixml.org/

Currently, the program consists of a single source file and various header files,
using pugixml in header-only mode.

When not defining NDEBUG, it prints the current node traversed to cerr.

Examplary compiler call:

g++ -std=c++11 -Wall -Wextra -pedantic -O3 -march=native -fwhole-program -DNDEBUG -I/path/to/pugixml-1.4/src/ xml_cleaner.cpp -o xml_cleaner


The current version uses static polymorphism and is overengineered.


dyp, 2014
dyp-cpp@gmx.net
