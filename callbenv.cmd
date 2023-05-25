@echo off
rem You must adjust to EWDK volume
call D:\BuildEnv\SetupBuildEnv.cmd %1
@set "INCLUDE=%INCLUDE%;%WindowsSdkDir%\Include\%Version_Number%\shared;%WindowsSdkDir%\Include\%Version_Number%\ucrt;%WindowsSdkDir%\Include\%Version_Number%\um;%WindowsSdkDir%\Include\%Version_Number%\km;%WindowsSdkDir%\Include\%Version_Number%\winrt;%WindowsSdkDir%\Include\%Version_Number%\cppwinrt"
@set "LIB=%LIB%;%WindowsSdkDir%\Lib\%Version_Number%\ucrt\%Platform%;%WindowsSdkDir%\Lib\%Version_Number%\um\%Platform%;%WindowsSdkDir%\Lib\%Version_Number%\km\%Platform%"
call %2
exit