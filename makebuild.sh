#!/bin/sh

FILES="djvu2pdf djvu2pdf.1.gz CHANGES README COPYING"
OUTPUT=djvu2pdf

VERSION=$(grep VERSION= djvu2pdf | sed 's/VERSION=//g; s/ *//g')

if [ -z $VERSION ]; then
    echo -e "Error: $0: Found no valid version info";
    exit 1
else
    echo "Found version info: $VERSION"
fi

FINAL=$OUTPUT-$VERSION

if [ -e $FINAL ]; then
    echo -e "Error: $0: The output directory '$FINAL' already exists"
    exit 1
fi

mkdir $FINAL
cp $FILES $FINAL

tar -c $FINAL | gzip > ${FINAL}.tar.gz

echo "Created tar with following content"
tar -tf $FINAL.tar.gz

rm -rf $FINAL
