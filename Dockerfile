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
FROM ubuntu:24.04 AS base

ENV DEBIAN_FRONTEND=noninteractive
ENV TMP=/tmp
ENV TEMP=/tmp
ENV WINEPREFIX=/wine
ENV WINEDLLOVERRIDES="winemenubuilder.exe=d"
ENV PATH="/opt/msvc/bin/x64:/usr/bin:${PATH}"

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        wine \
        wine64 \
        wine32:i386 \
        winbind \
        cabextract \
        msitools \
        ca-certificates \
        build-essential \
        ninja-build \
        cmake \
        python3 \
        curl \
        git \
        xz-utils \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# MSBuild is a .NET Framework application and needs Wine Mono. 8.1.0 is the
# version matching Wine 9.0: https://gitlab.winehq.org/wine/wine/-/wikis/Wine-Mono#versions
ARG WINE_MONO_VERSION=8.1.0
RUN mkdir -p /usr/share/wine/mono && \
    curl -fsSL "https://github.com/madewokherd/wine-mono/releases/download/wine-mono-${WINE_MONO_VERSION}/wine-mono-${WINE_MONO_VERSION}-x86.tar.xz" \
        | tar -xJ -C /usr/share/wine/mono

WORKDIR /opt
RUN git clone --depth 1 --branch master https://github.com/mstorsjo/msvc-wine.git

COPY scripts/ /scripts/
RUN chmod +x /scripts/*.sh

#-------------------------------------------------------------------------------
# Base rootless stage: adds non-root user
#-------------------------------------------------------------------------------
FROM base AS base-rootless

ARG USER=bill
ARG UID=1000
ARG GID=1000
# Ubuntu 24.04 ships an "ubuntu" user with UID/GID 1000.
RUN if id ubuntu >/dev/null 2>&1; then userdel -r ubuntu; fi && \
    groupadd -g $GID $USER && \
    useradd -m -u $UID -g $GID -s /bin/bash $USER

#-------------------------------------------------------------------------------
# latest
#-------------------------------------------------------------------------------
FROM base AS latest
RUN /scripts/download.sh \
    Microsoft.VisualStudio.Component.VC.Tools.x86.x64 \
    Microsoft.VisualStudio.Component.Windows11SDK.26100 \
    Microsoft.Component.MSBuild
RUN /scripts/cleanup.sh
RUN /scripts/setup-wine.sh
WORKDIR /workspace
CMD ["/bin/bash"]

#-------------------------------------------------------------------------------
# latest-rootless
#-------------------------------------------------------------------------------
FROM base-rootless AS latest-rootless
RUN /scripts/download.sh \
    Microsoft.VisualStudio.Component.VC.Tools.x86.x64 \
    Microsoft.VisualStudio.Component.Windows11SDK.26100 \
    Microsoft.Component.MSBuild
RUN /scripts/cleanup.sh

ENV WINEPREFIX=/home/bill/.wine
USER bill
RUN /scripts/setup-wine.sh
WORKDIR /home/bill/workspace
CMD ["/bin/bash"]

#-------------------------------------------------------------------------------
# clang
#-------------------------------------------------------------------------------
FROM base AS clang
RUN /scripts/download.sh \
    Microsoft.VisualStudio.Component.VC.Tools.x86.x64 \
    Microsoft.VisualStudio.Component.VC.Llvm.Clang \
    Microsoft.VisualStudio.Component.Windows11SDK.26100 \
    Microsoft.Component.MSBuild
RUN /scripts/cleanup.sh --clang
RUN /scripts/setup-wine.sh
WORKDIR /workspace
CMD ["/bin/bash"]

#-------------------------------------------------------------------------------
# clang-rootless
#-------------------------------------------------------------------------------
FROM base-rootless AS clang-rootless
RUN /scripts/download.sh \
    Microsoft.VisualStudio.Component.VC.Tools.x86.x64 \
    Microsoft.VisualStudio.Component.VC.Llvm.Clang \
    Microsoft.VisualStudio.Component.Windows11SDK.26100 \
    Microsoft.Component.MSBuild
RUN /scripts/cleanup.sh --clang

ENV WINEPREFIX=/home/bill/.wine
USER bill
RUN /scripts/setup-wine.sh
WORKDIR /home/bill/workspace
CMD ["/bin/bash"]

#-------------------------------------------------------------------------------
# win10-sdk
#-------------------------------------------------------------------------------
FROM base AS win10-sdk
RUN /scripts/download.sh \
    Microsoft.VisualStudio.Component.VC.Tools.x86.x64 \
    Microsoft.VisualStudio.Component.Windows11SDK.26100 \
    Microsoft.VisualStudio.Component.Windows10SDK \
    Microsoft.Component.MSBuild
RUN /scripts/cleanup.sh
RUN /scripts/setup-wine.sh
WORKDIR /workspace
CMD ["/bin/bash"]

#-------------------------------------------------------------------------------
# win10-sdk-rootless
#-------------------------------------------------------------------------------
FROM base-rootless AS win10-sdk-rootless
RUN /scripts/download.sh \
    Microsoft.VisualStudio.Component.VC.Tools.x86.x64 \
    Microsoft.VisualStudio.Component.Windows11SDK.26100 \
    Microsoft.VisualStudio.Component.Windows10SDK \
    Microsoft.Component.MSBuild
RUN /scripts/cleanup.sh

ENV WINEPREFIX=/home/bill/.wine
USER bill
RUN /scripts/setup-wine.sh
WORKDIR /home/bill/workspace
CMD ["/bin/bash"]

#-------------------------------------------------------------------------------
# win10-sdk-clang
#-------------------------------------------------------------------------------
FROM base AS win10-sdk-clang
RUN /scripts/download.sh \
    Microsoft.VisualStudio.Component.VC.Tools.x86.x64 \
    Microsoft.VisualStudio.Component.VC.Llvm.Clang \
    Microsoft.VisualStudio.Component.Windows11SDK.26100 \
    Microsoft.VisualStudio.Component.Windows10SDK \
    Microsoft.Component.MSBuild
RUN /scripts/cleanup.sh --clang
RUN /scripts/setup-wine.sh
WORKDIR /workspace
CMD ["/bin/bash"]

#-------------------------------------------------------------------------------
# win10-sdk-clang-rootless
#-------------------------------------------------------------------------------
FROM base-rootless AS win10-sdk-clang-rootless
RUN /scripts/download.sh \
    Microsoft.VisualStudio.Component.VC.Tools.x86.x64 \
    Microsoft.VisualStudio.Component.VC.Llvm.Clang \
    Microsoft.VisualStudio.Component.Windows11SDK.26100 \
    Microsoft.VisualStudio.Component.Windows10SDK \
    Microsoft.Component.MSBuild
RUN /scripts/cleanup.sh --clang

ENV WINEPREFIX=/home/bill/.wine
USER bill
RUN /scripts/setup-wine.sh
WORKDIR /home/bill/workspace
CMD ["/bin/bash"]
