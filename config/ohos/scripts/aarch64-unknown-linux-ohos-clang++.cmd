@echo off
set "CLANG=C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\native\llvm\bin\clang++.exe"
set "SYSROOT=C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\native\sysroot"
"%CLANG%" -target aarch64-linux-ohos "--sysroot=%SYSROOT%" -D__MUSL__ %*
exit /b %ERRORLEVEL%
