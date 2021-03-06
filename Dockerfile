# escape=`

FROM microsoft/windowsservercore:latest  as SetupPhase
SHELL ["powershell.exe", "-ExecutionPolicy", "Bypass", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

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

# Download log collection utility
ADD https://aka.ms/vscollect.exe C:\\TEMP\\collect.exe

# Download the Build Tools bootstrapper outside of the PATH.
ADD https://aka.ms/vs/15/release/vs_buildtools.exe C:\\TEMP\\vs_buildtools.exe

# Install Visual Studio Build Tools
 RUN $VerbosePreference = 'Continue'; `
    # ls 'C:\\Program Files\\';`
    # ls 'C:\\Program Files\\Common Files';`
    # ls 'C:\\Program Files (x86)\\';`
    # ls 'C:\\Program Files (x86)\\Common Files';`
    # ls 'C:\\Program Files (x86)\\Microsoft.NET';`
    $p = Start-Process -Wait -PassThru -FilePath C:\TEMP\vs_buildtools.exe -ArgumentList '--add Microsoft.VisualStudio.Workload.MSBuildTools --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.VC.140 --add Microsoft.VisualStudio.Component.Windows10SDK.15063.Desktop --quiet --wait --installPath C:\BuildTools';`
    #Get-ChildItem Env:;`
    #Get-ChildItem -Path . -Recurse| ? {$_.LastWriteTime -gt (Get-Date).AddDays(-1)};`
    # ls 'C:\\Program Files\\';`
    # ls 'C:\\Program Files\\Common Files';`
    # ls 'C:\\Program Files (x86)\\';`
    # ls 'C:\\Program Files (x86)\\Common Files';`
    # ls 'C:\\Program Files (x86)\\Microsoft.NET';`
    Get-ItemProperty 'hklm:\software\microsoft\Windows Kits\Installed Roots';`
    if ($ret = $p.ExitCode) { c:\TEMP\collect.exe; throw ('Install failed with exit code 0x{0:x}' -f $ret) }

RUN icacls 'C:\\Program Files (x86)\\WindowsPowerShell\\Modules' /reset /t /c /q 
RUN attrib -h -r -s 'C:\\Program Files (x86)\\WindowsPowerShell\\Modules' /s

RUN attrib -h -r -s "C:/Windows" /s

# Add C:\Bin to PATH
# RUN $env:Path += ";C:\Bin"

#FROM microsoft/nanoserver
FROM microsoft/windowsservercore:latest

RUN REG QUERY "HKLM\software\microsoft" /s

COPY --from=SetupPhase C:\\Bin C:\\Bin
COPY --from=SetupPhase C:\\BuildTools C:\\BuildTools

#COPY --from=SetupPhase ["C:\\Program Files\\Common Files", "C:/Program Files\\Common Files"]

COPY --from=SetupPhase ["C:\\Program Files (x86)\\Common Files\\Merge Modules", "C:\\Program Files (x86)\\Common Files\\Merge Modules"]
COPY --from=SetupPhase ["C:\\Program Files (x86)\\Common Files\\Microsoft", "C:\\Program Files (x86)\\Common Files\\Microsoft"]
COPY --from=SetupPhase ["C:\\Program Files (x86)\\Common Files\\Microsoft Shared", "C:\\Program Files (x86)\\Common Files\\Microsoft Shared"]
COPY --from=SetupPhase ["C:\\Program Files (x86)\\Microsoft SDKs", "C:\\Program Files (x86)\\Microsoft SDKs"]
COPY --from=SetupPhase ["C:\\Program Files (x86)\\Microsoft Visual Studio", "C:\\Program Files (x86)\\Microsoft Visual Studio"]
COPY --from=SetupPhase ["C:\\Program Files (x86)\\Microsoft Visual Studio 14.0", "C:\\Program Files (x86)\\Microsoft Visual Studio 14.0"]
COPY --from=SetupPhase ["C:\\Program Files (x86)\\MSBuild", "C:\\Program Files (x86)\\MSBuild"]
COPY --from=SetupPhase ["C:\\Program Files (x86)\\Reference Assemblies", "C:\\Program Files (x86)\\Reference Assemblies"]
COPY --from=SetupPhase ["C:\\Program Files (x86)\\Windows Kits", "C:\\Program Files (x86)\\Windows Kits"]

RUN icacls "C:/Program Files (x86)/WindowsPowerShell/Modules" /reset /t /c /q 
RUN attrib -h -r -s "C://Program Files (x86)/WindowsPowerShell/Modules" /s

COPY --from=SetupPhase ["C:\\Program Files (x86)\\WindowsPowerShell\\Modules", "C:\\Program Files (x86)\\WindowsPowerShell\\Modules"]

#RUN icacls "C:/Windows" /reset /t /c /q 
#RUN attrib -h -r -s "C:/Windows" /s
#COPY --from=SetupPhase ["C:/Windows", "C:/Windows"]

RUN icacls "C:\\Windows\\assembly" /reset /t /c /q 
RUN attrib -h -r -s "C:\\Windows\\assembly" /s
COPY --from=SetupPhase ["C:\\Windows\\assembly", "C:\\Windows\\assembly"]

RUN icacls "C:\\Windows\\Microsoft.NET" /reset /t /c /q 
RUN attrib -h -r -s "C:\\Windows\\Microsoft.NET" /s
COPY --from=SetupPhase ["C:\\Windows\\Microsoft.NET", "C:\\Windows\\Microsoft.NET"]

RUN icacls "C:\\Windows\\System32" /reset /t /c /q 
RUN attrib -h -r -s "C:\\Windows\\System32" /s
COPY --from=SetupPhase ["C:\\Windows\\System32", "C:\\Windows\\System32"]

RUN set

# Add version label
LABEL "monamimani.version"="Bootstrapper15.3.26730.12_Windows10SDK.15063.Desktop"

WORKDIR c:\\SourceCode

# Start developer command prompt with any other commands specified.
ENTRYPOINT C:\BuildTools\Common7\Tools\VsDevCmd.bat &&

# Default to PowerShell console running within developer command prompt environment
CMD ["powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
