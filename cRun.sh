#!/bin/bash

set +x
cd converter || exit
haxe --interp --main FNFToLineMap
cd ..
