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

cd /opt/msvc-wine

./vsdownload.py \
    --dest /opt/msvc \
    --accept-license \
    --architecture x64 x86 \
    --with-msbuild \
    -- \
    "$@"

./install.sh /opt/msvc

# Visual Studio only ships MSBuild.exe.config.template and lets its installer
# create the config. Without it, MSBuild has no toolset and fails right away.
find /opt/msvc/MSBuild -name MSBuild.exe.config.template | while read -r template; do
    config="${template%.template}"
    [ -e "$config" ] || cp "$template" "$config"
done

# The configs point MSBuild at assemblies in the parent directory through
# <codeBase href="..\X.dll">, which Wine Mono ignores. Link them next to MSBuild.exe.
find /opt/msvc/MSBuild -name MSBuild.exe.config | while read -r config; do
    dir="$(dirname "$config")"
    grep -o 'href="\.\.\\[^"]*"' "$config" | sed 's/^href="\.\.\\//; s/"$//' | while read -r name; do
        if [ ! -e "$dir/$name" ] && [ -e "$dir/../$name" ]; then
            ln -s "../$name" "$dir/$name"
        fi
    done
done
