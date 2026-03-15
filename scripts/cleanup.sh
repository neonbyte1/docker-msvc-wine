#!/usr/bin/env bash

# The MIT License (MIT)
# =====================
#
# Copyright (c) 2026 - neonbyte <https://github.com/neonbyte1>
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the “Software”), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

set -e

CLEANUP_CLANG=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --clang) CLEANUP_CLANG=true; shift ;;
        *) shift ;;
    esac
done

rm -rf /opt/msvc-wine

# remove clang for ARM64 and also the duplicated "lib" directory
if [ "$CLEANUP_CLANG" = true ]; then
    rm -rf /opt/msvc/VC/Tools/Llvm/ARM64
    rm -rf /opt/msvc/VC/Tools/Llvm/bin
    rm -rf /opt/msvc/VC/Tools/Llvm/lib
fi

rm -rf /opt/msvc/VC/Tools/MSVC/*/lib/onecore

# remove all debug symbols
# todo: maybe add an option and additional tags?
find /opt/msvc -name '*.pdb' -delete

# remove Windows Kits cruft
rm -rf "/opt/msvc/Windows Kits/10/Testing"
rm -rf "/opt/msvc/Windows Kits/10/App Certification Kit"
rm -rf "/opt/msvc/Windows Kits/10/Redist"

rm -rf /root/.cache /tmp/*
