## docker-msvc-wine

Dockerized version of [msvc-wine](https://github.com/mstorsjo/msvc-wine).

## Included tools

All images are based on Ubuntu 24.04 and come with:

- Wine 9.0 with Wine Mono 8.1.0, so `msbuild` can build `.vcxproj`, `.sln` and `.slnx` files, including file tracking (`Tracker.exe`).
- CMake 3.28 and Ninja 1.11, the minimum versions CMake needs for C++20 modules. Pass `-DCMAKE_SYSTEM_NAME=Windows` so CMake treats `cl` as MSVC.

The debug runtime (`ucrtbased.dll`, `vcruntime140d.dll`) is not included, so Debug executables build but don't run under Wine.

## Available tags

|Tag|Packages|
|---|---|
|`latest`|`Microsoft.Component.MSBuild`<br>`Microsoft.VisualStudio.Component.VC.Tools.x86.x64`<br>`Microsoft.VisualStudio.Component.Windows11SDK.26100`|
|`clang`|`Microsoft.Component.MSBuild`<br>`Microsoft.VisualStudio.Component.VC.Tools.x86.x64`<br>`Microsoft.VisualStudio.Component.Windows11SDK.26100`<br>`Microsoft.VisualStudio.Component.VC.Llvm.Clang`|
|`win10-sdk`|`Microsoft.Component.MSBuild`<br>`Microsoft.VisualStudio.Component.VC.Tools.x86.x64`<br>`Microsoft.VisualStudio.Component.Windows11SDK.26100`<br>`Microsoft.VisualStudio.Component.Windows10SDK`|
|`win10-sdk-clang`|`Microsoft.Component.MSBuild`<br>`Microsoft.VisualStudio.Component.VC.Tools.x86.x64`<br>`Microsoft.VisualStudio.Component.Windows11SDK.26100`<br>`Microsoft.VisualStudio.Component.Windows10SDK`<br>`Microsoft.VisualStudio.Component.VC.Llvm.Clang`|

### Rootless

Each tag above is also available with a `-rootless` suffix (e.g., `latest-rootless`, `clang-rootless`).

|Root|Rootless|
|---|---|
|User: `root`|User: `bill`|
|Workdir: `/workspace`|Workdir: `/home/bill/workspace`|
|WINEPREFIX: `/wine`|WINEPREFIX: `/home/bill/.wine`|

The UID/GID of the `bill` user defaults to `1000:1000`. You can [override this at build time](#custom-uidgid-for-rootless-images) to match your host user.
```

## Building

### Prerequisites

- Docker with BuildKit support

### Build a specific target
```bash
docker build --target latest -t msvc-wine:latest .
```

### Available targets

- `latest`, `latest-rootless`
- `clang`, `clang-rootless`
- `win10-sdk`, `win10-sdk-rootless`
- `win10-sdk-clang`, `win10-sdk-clang-rootless`

### Custom UID/GID for rootless images
```bash
docker build \
  --build-arg UID=$(id -u) \
  --build-arg GID=$(id -g) \
  --target latest-rootless \
  -t msvc-wine:latest-rootless \
  .
```

## License

The project uses the [MIT](LICENSE.md) license. However, the referenced repository is licensed under [ISC](https://github.com/mstorsjo/msvc-wine?tab=License-1-ov-file).
