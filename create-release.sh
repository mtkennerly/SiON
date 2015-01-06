#!/bin/bash
rm sion.zip
zip sion.zip haxelib.json README.md LICENSE.md
pushd src
zip ../sion.zip -r org/*
popd

