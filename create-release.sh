#!/bin/bash
rm sion.zip
zip sion.zip haxelib.json README.md LICENSE.md history.txt
pushd src
zip ../sion.zip -r org/*
popd
echo "sion.zip created."
echo "Run \"haxelib local sion.zip\" to test or \"haxelib submit sion.zip\" to release."
echo "Also remember to tag any release with \"git tag -a <version>\"."
