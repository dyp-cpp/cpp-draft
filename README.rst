===========================================================
Converting the C++ Standard Draft Sources from LaTeX to XML
===========================================================

This repository contains changes to the original LaTeX sources
and additional tools to convert the sources to an XML format.

The conversion is intended to be lossless, that is, no information
or intentions expressed in the sources should be lost.
The resulting XML document shall reflect the structure defined in
LaTeX.

--------------------
About the conversion
--------------------

A short chain of tools is used and can be extended to convert the
final XML document to any other format, e.g. HTML.
Currently, the precise structure of the XML document is not stable.
Therefore, there is no XML schema yet.
Most likely, the structure of tables, figures and footnotes will be
changed, while the basic document structure using
``<document>``
``<section>``
``<par>``
will remain.

The toolchain
=============

The first and main tool used is `LXir <http://www.lxir-latex.org>`_.
It injects some data into the DVI output of the LaTeX compiler
by replacing LaTeX macros and classes with versions that inject
markers and additional data.
This requires altering the LaTeX sources to use the LXir macros
instead of the default ones.
The resulting DVI document is converted by the lxir program to XML.

LXir is customizable and allows adding custom XSL Transformations
to the set of predefined transformations applied to the XML
document.
Additionally, custom XML elements can be created and used inside
LaTeX.

Both techniques are used to simplify, clean and enhance the XML
output of lxir specifically adjusted to the C++ Standard Draft
Sources.

The second tool is a small C++ program called "XML cleaner"
that performs some XML transformations I found hard to do in
XSLT (1.0).

Known restrictions and flaws
============================

#. Only the core language part is currently supported.
   The library part has been deactivated in ``std.tex``.
#. Tables only have basic support and their XML structure is likely
   to change.
#. Figures are not supported yet (using placeholders instead of
   pictures).
#. There are too few space characters, e.g. after the <cpp/> tag,
   or after quotes.
#. The toolchain is really slow. It might take several minutes
   and might require several hundred MiB of RAM.
#. The index is dropped entirely.
#. The front matter is dropped entirely.

Copyright
=========

#. The adjusted ``transformations.xml`` is released under
   the LaTeX Project Public License.

#. I do not claim any copyrights for the additional
   XSL Transformations nor for the XML cleaner.
   If you're a lawyer, consider it under the CC0 or in the public
   domain or whatever license that imposes the least
   restrictions on reuse, modification, republication etc.
   Do with it whatever you want.
   The software is distributed without any warranty.

Author
======

Responsible for this hacky conversion is::

   dyp <dyp-cpp@gmx.net>

Please send me encrypted and signed e-mails::

   http://pgp.mit.edu/pks/lookup?op=get&search=0xC266E5BC26C0704A

------------
Instructions
------------

These instructions have been tested on a vanilla Lubuntu 14.10

Note: I recommend trying the tool chain in a virtual machine.
Lubuntu 14.10 in a VirtualBox caused some graphics problems on my machine,
which could be fixed by right-CTRL-F1 followed by right-CTRL-F7.


Setup to build the C++ Standard Draft LaTeX Sources
=========================================

Required packages:

#. A LaTeX distribution such as ``texlive`` to build the C++ draft,
   plus any additional packages required to build the C++ draft sources
   (such as ``texlive-latex-extra`` for ``isodate.sty``).
#. git, to download this repository.

Instructions:

This step is merely to ensure you can build the original PDF version.
Check out the ``main`` branch of this repository,
and run ``pdflatex std.tex`` inside the ``source`` directory.
Run it twice to resolve additional dependencies, or use ``latexmk``,
as described in the `original README file <README_orig.rst>`_.


Installation of LXir
====================

Required packages:

#. ``subversion`` to fetch a recent version of the LXir sources.
#. ``automake build-essential gengetopt libicu-dev libkpathsea-dev libxml2 libxml2-dev libxslt1.1 libxslt1-dev pkg-config``
   for building LXir.

Instructions:

The installation instructions of LXir can be found on `its homepage <http://www.lxir-latex.org>`_,
but only in French.
The following is a short summary that worked fine for me.

#. Get the LXir sources; at least r235 (2014-06-20): ``svn checkout http://svn.edpsciences.org/svn/lxir``
#. (Maybe) rebuild the ``configure`` and ``Makefile.in`` files:
   LXir uses ``autotools`` to generate those files.
   It does ship with a ``configure`` and ``Makefile.in`` file, though.
   This caused problems for me since the versions used by the LXir developers
   didn't match my version of ``autotools``.
   To rebuild those files, run ``aclocal && autoconf && automake``.
#. Configure LXir.
   You might want to use two configuration options:
   The prefix for the binaries output,
   and the prefix for the TeX files (and related) output.
   The latter refers to TeX style files etc.
   that are used by your LaTeX to DVI compiler
   to inject markers later recoved from the DVI file by the LXir tool.
   Those files need to be placed in a location that can be found
   by your LaTeX to DVI compiler.
   You can use ``kpsewhich -show-path ls-R`` to print the paths searched
    for your LaTeX installation.
   Note that LXir also stores some XML files alongside the TeX files.
   Example:
   ``./configure --prefix=YOUR_BINARY_DESTINATION_PREFIX --with-texmf-prefix=YOUR_TEX_PREFIX``
   where, for example the TeX prefix is set to:
   ``--with-texmf-prefix=/usr/local/share/texmf``
#. Make LXir and install ``make && make install``.
   Depending on the paths chosen in the previous step,
   you'll need to run ``make install`` as the superuser,
   e.g. ``make && sudo make install``.


Installation of the additional XSL Transformations
==================================================

Preface:
LXir reads the DVI produced by your LaTeX to DVI compiler,
and looks for certain markers injected by special TeX files.
Then, it builds a rudimentary XML file based on this information.
This first XML file is then cleaned up in several steps using XSL
Transformations and C functions provided by LXir.
An XML file called ``transformations.xml`` configures which transformations
are called and their order.
This toolchain to convert the C++ Standard Draft LaTeX sources
contains an adjusted ``transformations.xml`` as well as additional XSL
Transformations.
Therefore, you'll need to replace the original file with a modified one.

No additioanl requirements.

Instructions:

#. For <= r237 of LXir, simply replace the file
   ``YOUR_TEX_PREFIX/tex/lxir/xml/transformations.xml``
   (inside the path you set up when configuring LXir)
   with the version provided in this repository:
   ``./xml/lxir_customizations/transformations.xml``
   You can also replace the original version with a symbolic link
   to this repository's ``transformation.xml`` to simplify updates.
   For other versions of LXir, you might need to adjust this file.
#. The additional transformations can also be found in this repository in
   ``./xml/lxir_customizations``
   LXir will search those in
   ``YOUR_TEX_PREFIX/tex/lxir/xslt/cpp-trafos/``
   (note: the subdirectory is ``xslt``, not ``xml``).
   I recommend creating a symbolic link
   from ``YOUR_TEX_PREFIX/tex/lxir/xslt/cpp-trafos``
   to your local copy of this repository ``./xml/lxir_customizations``,
   so that updating this repository also updates the transformations used by LXir.


Building the XML cleaner
========================

Requirements:

#. `pugixml <http://pugixml.org/downloads/>`_ for the XML cleaner tool

Originally, I used version 1.4 for development.
The XML cleaner tool also compiles and works fine with pugixml 1.5

For installation instructions,
see ``./xml/xml_cleaner/README.txt`` in this repository.


Running the toolchain
=====================

#. Check out the ``xml`` branch of this repository.
#. Build the DVI using your LaTeX to DVI compiler (e.g. the ``latex`` program)
   at least twice to resolve references:
   Inside this repository's ``source`` directory, compile ``std.tex``.
   E.g. (inside ``source``): ``latex std.tex && latex std.tex``
#. Run ``lxir`` on the resulting DVI. It will print the XML document to the
   standard output. E.g. ``lxir std.dvi > std.xml``
#. Run the XML cleaner on the resulting XML document. It will also print to
   the standard output. E.g. ``xml_cleaner std.xml > std-clean.xml``
