# docker-msvc-wine

[![build](https://github.com/neonbyte1/docker-msvc-wine/actions/workflows/build.yml/badge.svg)](https://github.com/neonbyte1/docker-msvc-wine/actions/workflows/build.yml)
[![license](https://img.shields.io/github/license/neonbyte1/docker-msvc-wine)](LICENSE.md)

MSVC (`cl`, `link`, MSBuild), optionally clang-cl, and the Windows SDK in a Docker image, running through Wine. Build Windows binaries on Linux and in CI without a Windows machine. Based on [msvc-wine](https://github.com/mstorsjo/msvc-wine).

## Why this image

On top of what msvc-wine provides, the images come with:

- **MSBuild that works:** Wine Mono, `Tracker.exe` and the fixes MSBuild 18 needs under Wine are included, so `.vcxproj`, `.sln` and `.slnx` files build out of the box.
- **CMake and Ninja for C++20 modules:** CMake 3.28 and Ninja 1.11, the minimum versions CMake needs to build modules.
- **Rootless images:** run as a regular user with your UID, so build output on mounted folders belongs to you instead of root.
- **Ready-made variants:** with or without clang-cl, and with or without the Windows 10 SDK.

## Quick start

Build the image once. This downloads several GB from Microsoft and accepts the Visual Studio license on your behalf, see [License](#license).

```bash
docker build \
  --build-arg UID=$(id -u) \
  --build-arg GID=$(id -g) \
  --target latest-rootless \
  -t msvc-wine \
  .
```

Then mount your project and build it:

```bash
# cl directly
docker run --rm -v "$PWD:/src" -w /src msvc-wine cl /EHsc /O2 hello.cpp

# CMake + Ninja
docker run --rm -v "$PWD:/src" -w /src msvc-wine bash -c '
  cmake -S . -B build -G Ninja -DCMAKE_SYSTEM_NAME=Windows \
        -DCMAKE_C_COMPILER=cl -DCMAKE_CXX_COMPILER=cl -DCMAKE_BUILD_TYPE=Release &&
  cmake --build build'

# MSBuild
docker run --rm -v "$PWD:/src" -w /src msvc-wine msbuild app.slnx -p:Configuration=Release -p:Platform=x64

# Run the result
docker run --rm -v "$PWD:/src" -w /src msvc-wine wine hello.exe
```

`-DCMAKE_SYSTEM_NAME=Windows` is needed so CMake treats `cl` as MSVC.

## Included tools

All images are based on Ubuntu 24.04 and come with:

- Wine 9.0 with Wine Mono 8.1.0, so `msbuild` can build `.vcxproj`, `.sln` and `.slnx` files, including file tracking (`Tracker.exe`).
- CMake 3.28 and Ninja 1.11.

The debug runtime (`ucrtbased.dll`, `vcruntime140d.dll`) is not included, so Debug executables build but don't run under Wine. The images are large: around 11 GB, or 17 GB with clang-cl.

## Image targets

| Target            | Packages                                                                                                                                                                                                                                             |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `latest`          | `Microsoft.Component.MSBuild`<br>`Microsoft.VisualStudio.Component.VC.Tools.x86.x64`<br>`Microsoft.VisualStudio.Component.Windows11SDK.26100`                                                                                                        |
| `clang`           | `Microsoft.Component.MSBuild`<br>`Microsoft.VisualStudio.Component.VC.Tools.x86.x64`<br>`Microsoft.VisualStudio.Component.Windows11SDK.26100`<br>`Microsoft.VisualStudio.Component.VC.Llvm.Clang`                                                    |
| `win10-sdk`       | `Microsoft.Component.MSBuild`<br>`Microsoft.VisualStudio.Component.VC.Tools.x86.x64`<br>`Microsoft.VisualStudio.Component.Windows11SDK.26100`<br>`Microsoft.VisualStudio.Component.Windows10SDK`                                                     |
| `win10-sdk-clang` | `Microsoft.Component.MSBuild`<br>`Microsoft.VisualStudio.Component.VC.Tools.x86.x64`<br>`Microsoft.VisualStudio.Component.Windows11SDK.26100`<br>`Microsoft.VisualStudio.Component.Windows10SDK`<br>`Microsoft.VisualStudio.Component.VC.Llvm.Clang` |

### Rootless

Each target is also available with a `-rootless` suffix (e.g. `latest-rootless`, `clang-rootless`).

|            | Root         | Rootless               |
| ---------- | ------------ | ---------------------- |
| User       | `root`       | `bill`                 |
| Workdir    | `/workspace` | `/home/bill/workspace` |
| WINEPREFIX | `/wine`      | `/home/bill/.wine`     |

The UID/GID of the `bill` user defaults to `1000:1000`. Pass `--build-arg UID=...` and `--build-arg GID=...` to match your host user, as in the [quick start](#quick-start).

## Building

Building needs Docker with BuildKit support. Pick a target with `--target`:

```bash
docker build --target latest -t msvc-wine:latest .
```

## License

The project uses the [MIT](LICENSE.md) license. However, the referenced repository is licensed under [ISC](https://github.com/mstorsjo/msvc-wine?tab=License-1-ov-file).

The images contain Microsoft software (MSVC, the Windows SDK and MSBuild). Building an image runs `vsdownload.py --accept-license`, which accepts the [Microsoft Diagnostic and Build Tools for Visual Studio license terms](https://go.microsoft.com/fwlink/?LinkId=2327714) on your behalf. Read them before building. Among other things, they don't allow sharing, publishing or otherwise distributing the software.
