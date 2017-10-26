# Copyright (C) Microsoft Corporation. All rights reserved.
# Licensed under the MIT license. See LICENSE.txt in the project root for license information.
FROM microsoft/windowsservercore:latest  as SetupPhase
SHELL ["powershell.exe", "-ExecutionPolicy", "Bypass", "-Command"]

# Download useful tools to C:\Bin.
ADD https://dist.nuget.org/win-x86-commandline/v4.1.0/nuget.exe C:\\Bin\\nuget.exe

# Download the Build Tools bootstrapper outside of the PATH.
ADD https://aka.ms/vs/15/release/vs_buildtools.exe C:\\TEMP\\vs_buildtools.exe

RUN $BuildToolsVer = (get-item C:\\TEMP\\vs_buildtools.exe).VersionInfo | % FileVersion

# Download log collection utility
ADD https://aka.ms/vscollect.exe C:\\TEMP\\collect.exe

# Add version label
LABEL "monamimani.version"="Bootstrapper15.3.26730.12"
LABEL "monamimani.versionTest"=$BuildToolsVer

# Install Visual Studio Build Tools
RUN $ErrorActionPreference = 'Stop'; \
    $VerbosePreference = 'Continue'; \
    $p = Start-Process -Wait -PassThru -FilePath C:\TEMP\vs_buildtools.exe -ArgumentList '--add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.VC.140 --add Microsoft.VisualStudio.Component.Windows10SDK.15063.Desktop --quiet --nocache --wait --installPath C:\BuildTools'; \
    if ($ret = $p.ExitCode) { c:\TEMP\collect.exe; throw ('Install failed with exit code 0x{0:x}' -f $ret) }

# Add C:\Bin to PATH
# RUN $env:Path += ";C:\Bin"

FROM microsoft/nanoserver

COPY --from=SetupPhase C:\BuildTools\ C:\BuildTools\

COPY --from=SetupPhase C:\Bin\ C:\Bin\

WORKDIR c:\\SourceCode


# Use shell form to start developer command prompt and any other commands specified
SHELL ["cmd.exe", "/s", "/c"]
ENTRYPOINT C:\BuildTools\Common7\Tools\VsDevCmd.bat &&

# Default to PowerShell console running within developer command prompt environment
CMD ["powershell.exe", "-nologo"]
