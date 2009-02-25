#!/bin/bash

if ! which rpmbuild &> /dev/null ; then
	echo "rpmbuild is not installed in your system; exiting"
	exit 1
fi

if [ ! "$#" = "1" ]; then
	echo "This script requires a single argument specifying the package version to build"
	echo "i.e. ./build.sh 1.2.3 for building version 1.2.3"
	exit 1
fi

if [ "$RPMBUILDROOT" = "" ]; then
	echo "RPMBUILDROOT seems uninitialized; are you sure you are not running this script directly?"
	exit 1
fi


echo "Cleaning up"

for dir in BUILD BUILDROOT RPMS SOURCES SRPMS; do
	if [ ! -d $dir ]; then
		mkdir $dir
	else
		rm -rf $dir/*
	fi
done


echo "applying version $1 to spec file"
cat SPECS/transifex-extras.spec.in | sed -e "s/\[\[version\]\]/$1/g" > SPECS/transifex-extras.spec
echo "checking out latest code; please wait"
mkdir -p SOURCES/transifex-extras-$1 >& /dev/null
touch SOURCES/transifex-extras-$1/transifex-extras-installed
pushd SOURCES

echo "bundling ..."
tar cfz transifex-extras-$1.tar.gz transifex-extras-$1
rm -rf transifex-extras-$1
pwd
popd

echo "setting up staging directory"
if [ ! -d $RPMBUILDROOT ]; then
	echo "creating staging directory"
	mkdir $RPMBUILDROOT
else
	rm -rf $RPMBUILDROOT
	mkdir $RPMBUILDROOT
fi

find . | cpio -p -dum -v $RPMBUILDROOT

pushd $RPMBUILDROOT
rpmbuild -ba --clean --nodeps SPECS/transifex-extras.spec
popd

