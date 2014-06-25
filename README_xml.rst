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

Installation of LXir
====================

These instructions have been tested on a vanilla Lubuntu 14.04

Required packages:

#. ``subversion`` and a LaTeX distribution such as ``texlive``
#. ``build-essential, libxml2, libxml2-dev, libxslt1.1, libxslt1-dev, pkg-config, libicu-dev, automake, libkpathsea-dev, gengetopt`` for building LXir

Instructions:

#. Get LXir; at least r235 (2014-06-20). ``svn checkout http://svn.edpsciences.org/svn/lxir``
#. The installation instructions of LXir can be found on `its homepage <http://www.lxir-latex.org>`_,
   but only in French.
#. Configure LXir. ``./configure --prefix=binary/destination/path/prefix --with-texmf-prefix=tex/destination/path/prefix``
   The prefix of the destination for LXir's TeX files
   (which inject the data later recovered from the DVI)
   should be set to a path searched by your LaTeX distribution.
   LXir also stores some XSLT and XML files there.
   You can use ``kpsewhich -show-path ls-R`` to print those paths.
   For example, ``--with-texmf-prefix=/usr/local/share/texmf``
#. Make LXir. An error will most likely occur building the test suite.
   This seems not to seem to be fatal, though.
#. Make install.

Installation of the additional XSL Transformations
==================================================

For r235 of LXir, simply replace the ``transformations.xml`` in
``tex/destination/path/prefix/tex/lxir/xml/`` with the version
provided in this repository ``./xml/lxir_customizations``
You can also replace the original version with a symlink to
simplify updates.
For other versions of LXir, you might need to adjust this file.
It contains the list and order of all transformations applied to
the basic DVI -> XML transformation.

The additional transformations can also be found in this repository in
``./xml/lxir_customizations``
Inside the adjusted ``transformations.xml``, the transformations
are referred to via a relative subdirectory called ``cpp-trafos``.
This subdirectory is searched for from the location of
``transformations.xml``.
I recommend creating a symlink to ``./xml/lxir_customizations``, so that
updating this repository also updates the transformations used.

Building the XML cleaner
========================

Requirements:

#. `pugixml 1.4 <http://pugixml.org/downloads/>`_ for the XML cleaner tool

For instructions, see ``./xml/xml_cleaner/README.txt`` in this repository.

Running the toolchain
=====================

#. Build the DVI using the ``latex`` program at least twice to resolve
   references. E.g. ``latex std.tex && latex std.tex``
#. Run ``lxir`` on the resulting DVI. It will print the XML document to the
   standard output. E.g. ``lxir std.dvi > std.xml``
#. Run the XML cleaner on the resulting XML document. It will also print to
   the standard output. E.g. ``xml_cleaner std.xml > std-clean.xml``
