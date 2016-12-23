Manual building instructions
============================

NOTICE! Typically the end user (that probably means you) does not need to
build the manuals, as the pre-built manual comes in several formats within
the GgrTF packages.

However, if you wish to re-build the manual from source, you will need
the following tools / utilities on an UNIX-style platform:

 - bash or similar shell
 - Either GraphicsMagick, ImageMagick or NetPBM utils
 - DocBook XML utilities
 - xsltproc
 - Perl 5.8 or later

Optionally you can also benefit from:
 - HTML Tidy <http://tidy.sourceforge.net/>
 - fop <http://xmlgraphics.apache.org/fop/>

When these depencies have been satisfied, you can try building
the manual by running 'build-docs.sh'.


Miscellanea
===========
The documentation has been written using DocBook XML, with some
custom extensions that are handled and converted to plain XML by the
Perl-based utilities. The following utilities are used:

 - tfdoc.pl: Enables grabbing additional documentation embedded inside
   the various TinyFugue scripts. The documentation is inserted to
   matching places in the XML marked via special tags.

 - normalizeml.pl: "Normalizes" the SGML/XML document, removing any
   "recursive" entity definitions (similar to macros). Definitions like
   these are useful, but unfortunately XML/SGML does not seem to support
   anything like them.
   