# escape=`

FROM microsoft/windowsservercore:latest  as SetupPhase
SHELL ["powershell.exe", "-ExecutionPolicy", "Bypass", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN pwd
# Download Build Tools 15.4.27004.2005 and other useful tools.
ENV VS_BUILDTOOLS_URI=https://aka.ms/vs/15/release/6e8971476/vs_buildtools.exe `
    VS_BUILDTOOLS_SHA256=D482171C7F2872B6B9D29B116257C6102DBE6ABA481FAE4983659E7BF67C0F88 `
    NUGET_URI=https://dist.nuget.org/win-x86-commandline/v4.1.0/nuget.exe `
    NUGET_SHA256=4C1DE9B026E0C4AB087302FF75240885742C0FAA62BD2554F913BBE1F6CB63A0

# Download useful tools to C:\Bin.
# ADD https://dist.nuget.org/win-x86-commandline/v4.1.0/nuget.exe C:\\Bin\\nuget.exe
RUN $VerbosePreference = 'Continue'; `
    New-Item -Path C:\bin -Type Directory | Out-Null; `
    [System.Environment]::SetEnvironmentVariable('PATH', "\"${env:PATH};C:\bin\"", 'Machine'); `
    Invoke-WebRequest -Uri $env:NUGET_URI -OutFile C:\bin\nuget.exe; `
    if ((Get-FileHash -Path C:\bin\nuget.exe -Algorithm SHA256).Hash -ne $env:NUGET_SHA256) { throw 'Download hash does not match' }
RUN dir
# Download log collection utility
#ADD https://aka.ms/vscollect.exe C:\\TEMP\\collect.exe

# Download the Build Tools bootstrapper outside of the PATH.
#ADD https://aka.ms/vs/15/release/vs_buildtools.exe C:\\TEMP\\vs_buildtools.exe

#RUN $BuildToolsVer = (get-item C:\\TEMP\\vs_buildtools.exe).VersionInfo | % FileVersion

# Add version label
#LABEL "monamimani.version"="Bootstrapper15.3.26730.12"
#LABEL "monamimani.versionTest"="$BuildToolsVer"
#RUN dir
# Install Visual Studio Build Tools
# RUN $ErrorActionPreference = 'Stop'; \
#    $VerbosePreference = 'Continue'; \
#    $p = Start-Process -Wait -PassThru -FilePath C:\TEMP\vs_buildtools.exe -ArgumentList '--add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.VC.140 --add Microsoft.VisualStudio.Component.Windows10SDK.15063.Desktop --quiet --nocache --wait --installPath C:\BuildTools'; \
#    if ($ret = $p.ExitCode) { c:\TEMP\collect.exe; throw ('Install failed with exit code 0x{0:x}' -f $ret) }

# Add C:\Bin to PATH
# RUN $env:Path += ";C:\Bin"
WORKDIR c:\\
RUN pwd
RUN dir

RUN dir

FROM microsoft/nanoserver

# COPY --from=SetupPhase C:\BuildTools\ C:\BuildTools\
RUN dir

COPY --from=SetupPhase C:\\Bin C:\\Bin
RUN dir
WORKDIR c:\\SourceCode


# Use shell form to start developer command prompt and any other commands specified
SHELL ["cmd.exe", "/s", "/c"]
ENTRYPOINT C:\BuildTools\Common7\Tools\VsDevCmd.bat &&

# Default to PowerShell console running within developer command prompt environment
CMD ["powershell.exe", "-nologo"]
