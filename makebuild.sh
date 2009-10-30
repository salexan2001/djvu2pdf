#!/bin/sh

FILES="djvu2pdf djvu2pdf.1.gz changelog INSTALL copyright"
OUTPUT=djvu2pdf
VERSION=$(grep VERSION= djvu2pdf | sed 's/VERSION=//g; s/ *//g')


write_control() {
cat > $FINAL/DEBIAN/control <<End-of-message
Package: djvu2pdf
Version: $VERSION
Section: utils
Priority: extra
Architecture: all
Depends: bash (>= 1.0)
Maintainer: Christoph Sieghart <sigi@0x2a.at>
Description: A script to convert Djvu files to PDF files
 A script to convert Djvu
 files to PDF files.
End-of-message
}

if [ -z $VERSION ]; then
    echo -e "Error: $0: Found no valid version info";
    exit 1
else
    echo "Found version info: $VERSION"
fi

if [ 1 -ne $# ]; then
	echo -e "Error: $0: Specifiy either 'debian' or 'source' as an argument"
	exit 1
else
	if [ "$1" = "debian" ] || [ "$1" = "source" ]; then
		PACKAGE=$1
	else
		echo -e "Error: $0: Specifiy either 'debian' or 'source' as an argument"
		exit 1
	fi
fi

FINAL=$OUTPUT-$VERSION

if [ -e $FINAL ]; then
	echo -e "Error: $0: The output directory '$FINAL' already exists"
	exit 1
fi

mkdir $FINAL

case $PACKAGE in
	debian)
		if [ "root" == $(whoami) ]; then
			mkdir $FINAL/DEBIAN
			mkdir -p $FINAL/usr/bin/
			mkdir -p $FINAL/usr/share/man/man1/
			mkdir -p $FINAL/usr/share/doc/djvu2pdf
			cp djvu2pdf $FINAL/usr/bin/
			cp djvu2pdf.1.gz $FINAL/usr/share/man/man1
			cp copyright $FINAL/usr/share/doc/djvu2pdf
			gzip -c -9 changelog > changelog.gz
			cp changelog.gz $FINAL/usr/share/doc/djvu2pdf

			write_control
			dpkg --build $FINAL .
			#lintian *.deb
			rm -rf $FINAL changelog.gz
		else
			echo "Error: $0: You must be root to build for debian"
			rm -rf $FINAL
			exit 1
		fi
		;;
	source)
		cp $FILES $FINAL

		tar -c $FINAL | gzip > ${FINAL}.tar.gz

		echo "Created tar with following content"
		tar -tf $FINAL.tar.gz

		rm -rf $FINAL
		;;
	*)
		echo "How the hell did you get here?"
		exit 1
		;;
esac
