setlocal enabledelayedexpansion
setlocal EnableExtensions 

REM Fetching packages..	

IF [%BUILD_NUMBER%] == [] (SET BUILD_NUMBER=0)

Tools\NuGet.exe install -OutputDirectory packages ILRepack
Tools\NuGet.exe install -OutputDirectory packages EasyNetQ

FOR /F %%I IN ('dir /b packages\ILRepack.*') DO SET ILREPACKDIR=%%I
FOR /F %%I IN ('dir /b packages\EasyNetQ.*') DO SET EASYNETQDIR=%%I
FOR /F %%I IN ('dir /b packages\RabbitMQ.Client.*') DO SET RABBITMQDIR=%%I
FOR /F %%I IN ('dir /b packages\Newtonsoft.Json.*') DO SET JSONNETDIR=%%I

REM Bundling EasyNetQ dependencies..

IF NOT EXIST Bundle MKDIR Bundle
IF NOT EXIST Bundle\lib MKDIR Bundle\lib
IF NOT EXIST Bundle\lib\net40 MKDIR Bundle\lib\net40

packages\%ILREPACKDIR%\tools\ILRepack.exe /internalize /out:Bundle\lib\net40\EasyNetQ.dll ^
  packages\%EASYNETQDIR%\lib\net40\EasyNetQ.dll ^
  packages\%RABBITMQDIR%\lib\net30\RabbitMQ.Client.dll ^
  packages\%JSONNETDIR%\lib\net40\Newtonsoft.Json.dll

REM Creating nuget package..

IF NOT EXIST Results MKDIR Results

FOR /F %%I IN ('echo %EASYNETQDIR% ^|sed -e "s/EasyNetQ\.//"') DO SET VERSION=%%I
FOR /F %%I IN ('echo %VERSION% ^|sed -e "s/\([0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/"') DO SET VERSION=%%I.%BUILD_NUMBER%
Tools\NuGet.exe pack Bundle\EasyNetQ.nuspec -OutputDirectory Results -BasePath Bundle -Version %VERSION%



