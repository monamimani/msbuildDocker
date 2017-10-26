[![Build status](https://ci.appveyor.com/api/projects/status/k421g08lwbyvwden?svg=true)](https://ci.appveyor.com/project/monamimani/msbuilddocker)
# msbuild Docker

Build a Docker image with Visual C++ Build tools.

## Build image

```
docker build -t msbuild .
```

## Use the image

```
docker run -v "$(pwd):C:\SourceCode" msbuild msbuild yourproject.sln /p:Configuration=Release
```

## Example

```
git clone https://github.com/monamimani/helloworld.git
cd helloworld
docker run -v "$(pwd):C:\code" monamimani/msbuild msbuild helloworld.sln /p:Configuration=Release
dir helloworld.exe
```

## Reference
- [Installing Build Tools for Visual Studio 2017 in a Docker container](https://blogs.msdn.microsoft.com/heaths/2017/09/18/installing-build-tools-for-visual-studio-2017-in-a-docker-container/?utm_source=t.co&utm_medium=referral) by Heath Stewart
  - [Dockerfile](https://gist.github.com/heaths/a81048f5eb6f1476e49ca2783d31a836#file-dockerfile)

### Docker Microsft
- [Dockerfile on Windows](https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-docker/manage-windows-dockerfile)
- [Install Build Tools into a Container](https://docs.microsoft.com/en-us/visualstudio/install/build-tools-container)
- [Advanced Example for Containers](https://docs.microsoft.com/en-us/visualstudio/install/advanced-build-tools-container)
- [Known issues for containers](https://docs.microsoft.com/en-us/visualstudio/install/build-tools-container-issues)

- [Visual Studio Build Tools 2017 component directory](https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools)
- [Setup a Windows Docker CI with AppVeyor](https://stefanscherer.github.io/setup-windows-docker-ci-appveyor/)

### Docker Official Reference
- [Dockerfile reference](https://docs.docker.com/engine/reference/builder/)
- [Docker commands](https://docs.docker.com/engine/reference/commandline/docker/)
