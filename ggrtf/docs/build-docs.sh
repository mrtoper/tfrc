#!/bin/sh
### Settings
DOCBOOKBASE="/usr/share/xml/docbook/stylesheet/docbook-xsl-ns"
UPURL="ccr@tnsp.org:public_html/ggrtf"
TFPATH="../"
SRCSGML="manual.sgml"
SRCXML="manual.xml"
SRCFO="manual.fo"
HTMLPATH="html"
HTMLFILE="$HTMLPATH/manual.html"
PDFFILE="manual.pdf"
XSLTPARAMS="--stringparam html.stylesheet manual.css"

### Get paths, if available
echo "* Initialization"
CPWD=`pwd`
CONVERT=`which convert`
PNMTOPS=`which pnmtops`
GIFTOPNM=`which giftopnm`
TIDY=`which tidy`
XSLTPROC=`which xsltproc`
FOP=`which fop`
CATALOGS1="$DOCBOOKBASE/xhtml/chunk.xsl"
CATALOGS2="$DOCBOOKBASE/xhtml/docbook.xsl"
CATALOGS3="$DOCBOOKBASE/fo/docbook.xsl"


### Check for locally installed FOP
echo -n "* Checking for FOP .. "
if test -n "$FOP" -a -x "$FOP"; then
	echo "$FOP"
elif test -x "$HOME/tf/docs/fop/fop"; then
	FOP="$HOME/tf/docs/fop/fop"
	echo "$FOP"
else
	echo "no"
fi

### Convert images
echo "* Checking for image to EPS converting utilities ..."
if test -n "$CONVERT" && test -x "$CONVERT"; then
	echo "** GraphicsMagic/ImageMagick convert found"
	for i in *.gif; do
		TOUTFILE=`echo "$i" | sed "s/.gif/.eps/"`
		echo " - $i -> $TOUTFILE"
		$CONVERT "$i" "$TOUTFILE"
	done
elif test -n "$PNMTOPS" && test -x "$PNMTOPS" && test -n "$GIFTOPNM" && test -x "$GIFTOPNM"; then
	echo "** NetPBM tools found"
	for i in *.gif; do
		TOUTFILE=`echo "$i" | sed "s/.gif/.eps/"`
		echo " - $i -> $TOUTFILE"
		$GIFTOPNM "$i" | $PNMTOPS -scale=0.5 -noturn > "$TOUTFILE"
	done
else
	echo "*** WARNING! No supported image conversion tools found, not converting images."
	echo "*** This may cause some document format conversions to fail or produce errors."
fi


### Check that we have xsltproc installed for DocBook XML processing
if test -n "$XSLTPROC" && test -x "$XSLTPROC"; then
	echo "* xsltproc found, good... testing for DocBook XML stuff .."
	if test -e "$CATALOGS1"; then
		echo "  * $CATALOGS1 found."
	else
		echo "*** xhtml/chunk.xsl not found!"
		exit 1
	fi
	if test -e "$CATALOGS2"; then
		echo "  * $CATALOGS2 found."
	else
		echo "*** xhtml/docbook.xsl not found!"
		exit 1
	fi
	if test -e "$CATALOGS3"; then
		echo "  * $CATALOGS3 found."
	else
		echo "*** fo/docbook.xsl not found!"
		exit 1
	fi
else
	echo "*** ERROR! Could not find xsltproc! You need xsltproc and the"
	echo "*** DocBook XML suite (with XSL stylesheets) to be able to"
	echo "*** generate the documentation!"
	exit 1
fi


### Generate kludge-normalized XML from the DocBook SGML source
( perl -w tfdoc.pl "$TFPATH" < "$SRCSGML" | perl -w normalizeml.pl > "$SRCXML" ) || exit 1


### Generate HTML files
echo "* HTML"
if test -e "$HTMLPATH"; then
	rm -fr "$HTMLPATH"
fi
mkdir -p "$HTMLPATH"

if test -d "$HTMLPATH"; then
	cp *.css *.png *.gif "$HTMLPATH" && cd "$HTMLPATH" && $XSLTPROC $XSLTPARAMS "$CATALOGS1" "../$SRCXML"
	cd "$CPWD"
	
	if $XSLTPROC $XSLTPARAMS "$CATALOGS2" "$SRCXML" > "$HTMLFILE"; then
		echo "  * Transform successful."
	else
		echo "*** ERROR! $XSLTPROC failed. Quitting on fatal error."
		echo "*** Check $SRCXML for errors."
		exit 2
	fi

	echo "  * Checking for HTML Tidy ..."
	if test -n "$TIDY" && test -x "$TIDY"; then
		echo "** Found, cleaning up the mess by DocBook .."
		if $TIDY -q -w 512 -utf8 -asxhtml -i -m $HTMLPATH/*.html "$HTMLFILE"; then
			echo "** Tidying process successful."
		fi
	else
		echo "*** WARNING! HTML tidy not found! To get better HTML output,"
		echo "*** please install HTML tidy (http://tidy.sourceforge.net/)"
	fi
fi


### Generate PDF
rm -f "$PDFFILE"
if test -n "$FOP" && test -x "$FOP" && test -e "$SRCXML"; then
	echo "* PDF .."
	$FOP -xml "$SRCXML" -xsl "$CATALOGS3" -pdf "$PDFFILE"
fi

## Remove temporary files
rm -f "$SRCXML"


## Upload
if test "x$1" = "x--upload"; then
	scp -C $HTMLPATH/* manual.css "$UPURL/html/"
	scp -C "$PDFFILE" "$UPURL"
	scp -C "$HOME/bin/tf5" "$UPURL/tf5.sh"
fi
