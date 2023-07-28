@echo off 
setlocal enabledelayedexpansion
del "%TMP%\*.sql" "%TMP%\*.log" >nul 2>&1
set seldb=vm
echo Citrix CVAD VDI UUID Changer v1.3.1a
echo 버전일자 2023-07-27
title Citrix CVAD VDI UUID Changer v1.3.1a
set location=%~dp0
cd %location%
:: 인증방식 0이면 AD도메인 인증, 1이면 SQL Server 인증
set salist=0
:: Citrix MCS VM UUID변경 툴

::백업 옵션은 기본 옵션이'1' (1이 활성화 0이 비활성화)
set bkoption=1

:: bin 폴더 유무
IF EXIST bin (
goto mvcconfig
) ELSE (
 goto notbin
)

:notbin
echo.
echo bin 폴더가 존재하지 않습니다. 
echo 실행된 경로에서 bin폴더 빠지지 않았는지 다시한번 확인해주세요. 
pause 
exit

:mvcconfig
:: config 파일 유무
IF EXIST config.conf (
goto ODBC
) ELSE (
 goto main
)
:: pause


:input
cls
set dbport=1433
echo CitrixCVUC 초기구성 Config 구성 
echo 구성 완료 시 CitrixCVUC.bat 경로에 Config.conf 파일 생성
echo.
:: config 설정 ------

:: DB서버 IP or 도메인 설정
echo 1.DB서버 IP 입력
set /p userDBip=입력:
echo.
:: DB서버 포트 설정
echo 2.DB서버Port 입력
echo 입력안하고 넘어갈 시 기본 1433포트로 자동 입력
set /p dbport=입력:
echo.
if %seldb%==vm goto main
if %seldb%==1 set dbcon=1 & goto input1
if %seldb%==2 set dbcon=1 & goto selc1
if %seldb%==3 set dbcon=2 & goto input2
if %seldb%==4 set dbcon=2 & goto selc1

:: DB 싱글 및 분할 구성 선택
:main
set seldb=vm
echo.
:: echo %salist%
echo ## DB접속정보 설정 메뉴
echo.
echo 1) DB 인증을 AD도메인 및 SQL Server 인증을 선택 할 수 있습니다.
echo   -- 도메인 조인이 아닌 호스트에서는 AD도메인 인증을 해도 자동으로 SQL Server 인증으로 설정
echo 2) Citrix Controller에 설정 된 DB상태가 싱글 상태인지 Site/Monitoring/Logging으로 분할 구성 되어있는지 선택
echo.
echo 1. 싱글 구성 (AD도메인인증)
echo 2. 싱글 구성 (SQL Server 인증)
echo 3. 분할 구성 (AD도메인인증)
echo 4. 분할 구성 (SQL Server 인증)
echo.
echo x. 나가기  
echo c.이전 메뉴
echo.
set /p seldb=입력:

if %seldb%==vm goto derr
if %seldb%==1 goto input
if %seldb%==2 goto input
if %seldb%==3 goto input
if %seldb%==4 goto input
if %seldb%==x exit
if %seldb%==X exit
if %seldb%==c if exist "config.conf" (goto main2) ELSE (goto input)
if %seldb%==C if exist "config.conf" (goto main2) ELSE (goto input)


:derr
echo 범위를 벗어난 입력입니다.
echo 잘못된 값으로 처음 화면으로 다시 돌아갑니다.
pause
goto input

:: DB 구성 (싱글 / 분할)
:input1
:: 도메인 조인 여부 
:: 로컬 호스트에서 도메인 조인상태에 따라 DB조인 수동입력으로 자동 전환
if %computername%==%userdomain% goto selc1

echo.
echo 3-1. 싱글 DB 설정
set /p userDB=입력:
set userSiteDB=null
set userMoDB=null
goto input3

:input2
:: 도메인 조인 여부 
:: 로컬 호스트에서 도메인 조인상태에 따라 DB조인 수동입력으로 자동 전환
if %computername%==%userdomain% goto selc1

echo 3-2. 분할 DB 설정 
echo 1. CVAD DB Site명 입력
set /p userSiteDB=입력:
echo.
echo 2. CVAD DB Monitor명 입력
set /p userMoDB=입력:

:input3
if %dbcon%==1 set singleDB=Enable
if %dbcon%==2 set singleDB=Disable
echo salist= %salist% > config.conf
echo userDBip= %userDBip% >> config.conf
echo dbport= %dbport% >> config.conf
echo userDB= %userDB% >> config.conf
echo singleDB= %singleDB% >> config.conf
echo userSiteDB= %userSiteDB% >> config.conf
echo userMoDB= %userMoDB% >> config.conf
echo bkoption= %bkoption% >> config.conf
echo sauser= %sauser% >> config.conf
echo sapass= %passenc% >> config.conf
echo.
goto ODBC


:ODBC
sqlcmd -? >nul 2>&1
if Not %ERRORLEVEL%==0 goto install
goto confdb

:install

set location=%~dp0
::관리자 권한 확인
bcdedit >nul 2>&1
if not %errorlevel%==0 goto Adminstart
goto sqlcmdisntall
:Adminstart
cls
echo.
timeout 1 >nul
echo.
::관리자 권한 VBS 진행
echo Set UAC = CreateObject^("Shell.Application"^) > "%TMP%\mvcadmin.vbs"
echo UAC.ShellExecute "cmd", "/c """"%~f0"" """ + Wscript.Arguments.Item(0) + """ ""%user%""""", "%CD%", "runas", 1 >> "%TMP%\mvcadmin.vbs"
"%TMP%\mvcadmin.vbs" "%file%"

::관리자 권한 완료 후 VBS파일 삭제
del "%TMP%\mvcadmin.vbs"
exit /b

:sqlcmdisntall
cd %location%
cls
echo.
echo SQLCMD 및 ODBC 미설치로 자동 구성중입니다. 잠시만 기다려 주세요
echo 진행중 %%00
timeout /t 2 /nobreak >nul 2>&1
if %PROCESSOR_ARCHITECTURE%==x86 goto install32
:: msiexec /quiet /passive /qn /i "bin\vcredist\x64\vc_runtimeAdditional_x64.msi"
timeout /t 2 /nobreak >nul 2>&1
cls
echo.
echo SQLCMD 및 ODBC 미설치로 자동 구성중입니다. 잠시만 기다려 주세요
echo 진행중 %%35
:: msiexec /quiet /passive /qn /i "bin\vcredist\x64\vc_runtimeMinimum_x64.msi"
timeout /t 2 /nobreak >nul 2>&1
cls
echo.
echo SQLCMD 및 ODBC 미설치로 자동 구성중입니다. 잠시만 기다려 주세요
echo 진행중 %%55
msiexec /quiet /passive /qn /i "bin\odbc_x64.msi" IACCEPTMSODBCSQLLICENSETERMS=YES 
cls
echo.
echo SQLCMD 및 ODBC 미설치로 자동 구성중입니다. 잠시만 기다려 주세요
echo 진행중 %%75
timeout /t 5 /nobreak >nul 2>&1
cls
echo.
echo SQLCMD 및 ODBC 미설치로 자동 구성중입니다. 잠시만 기다려 주세요
echo 진행완료! %%100
msiexec /quiet /passive /qn /i "bin\MsSqlCmdLnUtils_x64.msi" IACCEPTMSSQLCMDLNUTILSLICENSETERMS=YES
echo.
echo.
echo 잠시 후 CitrixCVUC툴이 재시작 됩니다.
timeout /t 5 /nobreak 
echo.
set Path=%Path%;%ProgramFiles%\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn
goto confdb

:install32
:: msiexec /quiet /passive /qn /i "bin\vcredist\x86\vc_runtimeAdditional_x86.msi"
cls
echo.
echo SQLCMD 및 ODBC 미설치로 자동 구성중입니다. 잠시만 기다려 주세요
echo 진행중 %%35
timeout /t 2 /nobreak >nul 2>&1
:: msiexec /quiet /passive /qn /i "bin\vcredist\x86\vc_runtimeMinimum_x86.msi"
timeout /t 2 /nobreak >nul 2>&1
cls
echo.
echo SQLCMD 및 ODBC 미설치로 자동 구성중입니다. 잠시만 기다려 주세요
echo 진행중 %%55
msiexec /quiet /passive /qn /i "bin\odbc_x32.msi" IACCEPTMSODBCSQLLICENSETERMS=YES 
cls
echo.
echo SQLCMD 및 ODBC 미설치로 자동 구성중입니다. 잠시만 기다려 주세요
echo 진행중 %%75
timeout /t 5 /nobreak >nul 2>&1
cls
echo.
echo SQLCMD 및 ODBC 미설치로 자동 구성중입니다. 잠시만 기다려 주세요
echo 진행완료! %%100
msiexec /quiet /passive /qn /i "bin\MsSqlCmdLnUtils_x86.msi" IACCEPTMSSQLCMDLNUTILSLICENSETERMS=YES
echo.
echo.
echo 잠시 후 CitrixCVUC툴이 재시작 됩니다.
timeout /t 5 /nobreak 
echo.
set Path=%Path%;%ProgramFiles%\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\


:confdb
setlocal EnableDelayedExpansion
set sapass=err
for /f "tokens=2" %%i in ('findstr "salist" config.conf') do set salist=%%i
for /f "tokens=2" %%i in ('findstr "userDBip" config.conf') do set userDBip=%%i
for /f "tokens=2" %%i in ('findstr "dbport" config.conf') do set dbport=%%i
for /f "tokens=2" %%i in ('findstr "userDB" config.conf') do set userDB=%%i
for /f "tokens=2" %%i in ('findstr "singleDB" config.conf') do set singleDB=%%i
for /f "tokens=2" %%i in ('findstr "userSiteDB" config.conf') do set userSiteDB=%%i
for /f "tokens=2" %%i in ('findstr "userMoDB" config.conf') do set userMoDB=%%i
for /f "tokens=2" %%i in ('findstr "bkoption" config.conf') do set bkoption=%%i
for /f "tokens=2" %%i in ('findstr "sauser" config.conf') do set sauser=%%i
for /f "tokens=2" %%i in ('findstr "sapass" config.conf') do set passenc=%%i
echo.

echo %passenc% |bin\openssl.exe enc -d -aes256 -a -k %COMPUTERNAME% > "%TMP%\sapass.txt"
set /p sapass=<"%TMP%\sapass.txt"
set sa2pass=!sapass!
if !sapass!==err goto sapassline


:sapassline
if NOT !sapass!==err goto main2
echo %passenc%= |bin\openssl.exe enc -d -aes256 -a -k %COMPUTERNAME% > "%TMP%\sapass.txt"
set /p sapass=<"%TMP%\sapass.txt"
set sa2pass=!sapass!

:main2
del "%TMP%\sapass.txt"
if %singleDB%==Enable set dbcon=1
if %singleDB%==Disable set dbcon=2
set sel=vm
if %dbcon%==1 set bsel=싱글
if %dbcon%==2 set bsel=분할
if %salist%==0 set dbuserauto=AD도메인인증
if %salist%==1 set dbuserauto=SQL Server 인증
cls
:: echo 확인용도 %salist%
echo VM UUID,Pool 컨넥션 변경,카탈로그 마스터 VM 변경 및 DB 구성 변경 메뉴
echo.
echo ## CitrixCVUC Tools 설정 방식
echo -- 설정 변경 필요 시 '4'번 입력 또는 config.conf 파일 편집
echo 현재 Citrix Controller DB 방식은( %bsel% )방식입니다. 
echo 현재 CitrixCVUC Tools DB 계정 방식은 ( %dbuserauto% ) 방식입니다.
:: echo 패스워드 !sapass! 
echo.
echo ## 옵션 선택
echo.
echo 1. VM_UUID 변경    
echo 2. VM_POOL컨넥션 변경  
echo 3. Catalog Master VM 교체  
echo 4. DB접속정보 변경
echo 5. CitrixCVUC 복원
echo 6. 다량의 데이터 처리하기 (CSV파일 처리) 
echo x. 나가기
echo.
set /p sel=입력:

if %sel%==vm goto err
if %sel%==1 goto ch1
if %sel%==2 goto ch2
if %sel%==3 goto ch4
if %sel%==4 goto main
if %sel%==5 goto MVCBAK
if %sel%==6 goto CSVhome
if %sel%==x exit
if %sel%==X exit
if %sel%==v goto ver
if %sel%==V goto ver

:err
echo 범위를 벗어난 입력입니다.
pause
goto main2

:ch1
set useruuid=c
:: VM_UUID 교체 스크립트 구간 
cls 
echo 1. VM_UUID 변경
echo 이전메뉴로 돌아가기 'c' 입력
echo.
echo 입력 예시) 07324359-868a-6459-2b7c-21ca8dc1e20a
echo.
echo 현재 VM의 UUID입력
set /p useuuid=입력:
if %useuuid%==c goto main2
if %useuuid%==C goto main2

echo.
echo.
echo 교체 VM의 UUID입력
set /p chuuid=입력:

if %salist%==0 goto mcsvmvar1
if %salist%==1 goto mcsvmvar2

:mcsvmvar1
if %dbcon%==1 for /f "tokens=1" %%i in ('sqlcmd -S %userDBip%^,%dbport% -E -W -h -1 -Q "set nocount on; SELECT [HostedMachineName] FROM [%userDB%].[MonitorData].[Machine] where HostedMachineId='%useuuid%'"') do set usename=%%i
if %dbcon%==2 for /f "tokens=1" %%i in ('sqlcmd -S %userDBip%^,%dbport% -E -W -h -1 -Q "set nocount on; SELECT [HostedMachineName] FROM [%userMoDB%].[MonitorData].[Machine] where HostedMachineId='%useuuid%'"') do set usename=%%i

goto mcsvmvar3

:mcsvmvar2
if %dbcon%==1 for /f "tokens=1" %%i in ('sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -W -h -1 -Q "set nocount on; SELECT [HostedMachineName] FROM [%userDB%].[MonitorData].[Machine] where HostedMachineId='%useuuid%'"') do set usename=%%i
if %dbcon%==2 for /f "tokens=1" %%i in ('sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -W -h -1 -Q "set nocount on; SELECT [HostedMachineName] FROM [%userMoDB%].[MonitorData].[Machine] where HostedMachineId='%useuuid%'"') do set usename=%%i

:mcsvmvar3
echo SET QUOTED_IDENTIFIER ON > "%TMP%\MCS.sql"
echo. >> "%TMP%\MCS.sql"
echo GO >> "%TMP%\MCS.sql"
echo. >> "%TMP%\MCS.sql"
:: Monitoring DB 변경 구간
if %dbcon%==1 echo UPDATE [%userDB%].[MonitorData].[Machine] >> "%TMP%\MCS.sql"
if %dbcon%==2 echo UPDATE [%userMoDB%].[MonitorData].[Machine] >> "%TMP%\MCS.sql"
echo SET HostedMachineId = '%chuuid%' >> "%TMP%\MCS.sql"
echo WHERE HostedMachineId = '%useuuid%' >> "%TMP%\MCS.sql"
echo. >> "%TMP%\MCS.sql"

:: Site DB 변경 구간
if %dbcon%==1 echo UPDATE [%userDB%].[Chb_Config].[Workers] >> "%TMP%\MCS.sql"
if %dbcon%==2 echo UPDATE [%userSiteDB%].[Chb_Config].[Workers] >> "%TMP%\MCS.sql"
echo SET HostedMachineId = '%chuuid%' >> "%TMP%\MCS.sql"
echo WHERE HostedMachineId = '%useuuid%' >> "%TMP%\MCS.sql"
echo. >> "%TMP%\MCS.sql"
if %dbcon%==1 echo UPDATE [%userDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] >> "%TMP%\MCS.sql"
if %dbcon%==2 echo UPDATE [%userSiteDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] >> "%TMP%\MCS.sql"
echo SET VMId = '%chuuid%' >> "%TMP%\MCS.sql"
echo WHERE VMId = '%useuuid%' >> "%TMP%\MCS.sql"

if %salist%==0 sqlcmd -E -S %userDBip%,%dbport% -i "%TMP%\MCS.sql"
if %salist%==1 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -i "%TMP%\MCS.sql"

echo.
echo MCS VM(%usename%)이 기존 %useuuid%에서 %chuuid%로 변경되었습니다.


:VMBK
if %bkoption%==0 goto ch11
if exist "Backup\VM\" (echo.) ELSE (mkdir "Backup\VM\")
if exist "Backup\VM\MCSbak.sql" (echo.) ELSE (goto VMBKrenameskip)
for /f "tokens=3" %%i in ('findstr "일자" "Backup\VM\MCSbak.sql"') do set rename=%%i >nul
move "Backup\VM\MCSbak.sql" "Backup\VM\%rename::=%- MCSbak.sql" >nul
:VMBKrenameskip

:: VM backup 저장
echo -- 백업일자: %date:~2,2%%date:~5,2%%date:~8,2%-%time:~0,8% > "Backup\VM\MCSbak.sql"
echo -- 백업대상VM: VMUID:%useuuid% >> "Backup\VM\MCSbak.sql"
echo -- 변경내용:  MCS VM(%usename%)이 기존 %useuuid%에서 %chuuid%로 변경 >> "Backup\VM\MCSbak.sql"
echo SET QUOTED_IDENTIFIER ON >> "Backup\VM\MCSbak.sql"
echo. >> "Backup\VM\MCSbak.sql"
echo GO >> "Backup\VM\MCSbak.sql"
echo. >> "Backup\VM\MCSbak.sql"
:: Monitoring DB 구간
if %dbcon%==1 echo UPDATE [%userDB%].[MonitorData].[Machine] >> "Backup\VM\MCSbak.sql"
if %dbcon%==2 echo UPDATE [%userMoDB%].[MonitorData].[Machine] >> "Backup\VM\MCSbak.sql"
echo SET HostedMachineId = '%useuuid%' >> "Backup\VM\MCSbak.sql"
echo WHERE HostedMachineId = '%chuuid%' >> "Backup\VM\MCSbak.sql"
echo. >> "Backup\VM\MCSbak.sql"

:: Site DB 구간
if %dbcon%==1 echo UPDATE [%userDB%].[Chb_Config].[Workers] >> "Backup\VM\MCSbak.sql"
if %dbcon%==2 echo UPDATE [%userSiteDB%].[Chb_Config].[Workers] >> "Backup\VM\MCSbak.sql"
echo SET HostedMachineId = '%useuuid%' >> "Backup\VM\MCSbak.sql"
echo WHERE HostedMachineId = '%chuuid%' >> "Backup\VM\MCSbak.sql"
echo. >> "Backup\VM\MCSbak.sql"
if %dbcon%==1 echo UPDATE [%userDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] >> "Backup\VM\MCSbak.sql"
if %dbcon%==2 echo UPDATE [%userSiteDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] >> "Backup\VM\MCSbak.sql"
echo SET VMId = '%useuuid%' >> "Backup\VM\MCSbak.sql"
echo WHERE VMId = '%chuuid%' >> "Backup\VM\MCSbak.sql"

:ch11
pause
del "%TMP%\MCS.sql"

goto main2

:ch2
:: Pool 교체 스크립트 구간
cls 
set chuuid=c
echo 2. VM_POOL컨넥션 변경
echo 이전메뉴로 돌아가기 'c' 입력
echo.
echo 입력 예시) 07324359-868a-6459-2b7c-21ca8dc1e20a
echo.
echo 풀교체 대상 VM의 UUID입력
set /p chuuid=입력:
if %chuuid%==c goto main2
if %chuuid%==C goto main2
echo.
echo 선택된 VM에 현재 등록된 하이퍼바이저 Uid확인
echo.
if %salist%==0 goto poolvar1
if %salist%==1 goto poolvar2

:poolvar1
if %dbcon%==1 for /f "tokens=1" %%i in ('sqlcmd -S %userDBip%^,%dbport% -E -W -h -1 -Q "set nocount on; SELECT [HypervisorConnectionUid] FROM [%userDB%].[chb_Config].[Workers] where HostedMachineId='%chuuid%'"') do set vmp=%%i
if %dbcon%==1 for /f "tokens=1" %%i in ('sqlcmd -S %userDBip%^,%dbport% -E -W -h -1 -Q "set nocount on; SELECT [HypervisorConnectionId] FROM [%userDB%].[chb_Config].[HypervisorConnections] where Uid='%vmp%'"') do set vmp1=%%i
if %dbcon%==1 for /f "tokens=1" %%i in ('sqlcmd -S %userDBip%^,%dbport% -E -W -h -1 -Q "set nocount on; SELECT [HostedMachineName] FROM [%userDB%].[MonitorData].[Machine] where HostedMachineId='%chuuid%'"') do set chname=%%i
if %dbcon%==2 for /f "tokens=1" %%i in ('sqlcmd -S %userDBip%^,%dbport% -E -W -h -1 -Q "set nocount on; SELECT [HypervisorConnectionUid] FROM [%userSiteDB%].[chb_Config].[Workers] where HostedMachineId='%chuuid%'"') do set vmp=%%i
if %dbcon%==2 for /f "tokens=1" %%i in ('sqlcmd -S %userDBip%^,%dbport% -E -W -h -1 -Q "set nocount on; SELECT [HypervisorConnectionId] FROM [%userSiteDB%].[chb_Config].[HypervisorConnections] where Uid='%vmp%'"') do set vmp1=%%i
if %dbcon%==2 for /f "tokens=1" %%i in ('sqlcmd -S %userDBip%^,%dbport% -E -W -h -1 -Q "set nocount on; SELECT [HostedMachineName] FROM [%userMoDB%].[MonitorData].[Machine] where HostedMachineId='%chuuid%'"') do set chname=%%i

goto poolvar3

:poolvar2
if %dbcon%==1 for /f "tokens=1" %%i in ('sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -W -h -1 -Q "set nocount on; SELECT [HypervisorConnectionUid] FROM [%userDB%].[chb_Config].[Workers] where HostedMachineId='%chuuid%'"') do set vmp=%%i
if %dbcon%==1 for /f "tokens=1" %%i in ('sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -W -h -1 -Q "set nocount on; SELECT [HypervisorConnectionId] FROM [%userDB%].[chb_Config].[HypervisorConnections] where Uid='%vmp%'"') do set vmp1=%%i
if %dbcon%==1 for /f "tokens=1" %%i in ('sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -W -h -1 -Q "set nocount on; SELECT [HostedMachineName] FROM [%userDB%].[MonitorData].[Machine] where HostedMachineId='%chuuid%'"') do set chname=%%i
if %dbcon%==2 for /f "tokens=1" %%i in ('sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -W -h -1 -Q "set nocount on; SELECT [HypervisorConnectionUid] FROM [%userSiteDB%].[chb_Config].[Workers] where HostedMachineId='%chuuid%'"') do set vmp=%%i
if %dbcon%==2 for /f "tokens=1" %%i in ('sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -W -h -1 -Q "set nocount on; SELECT [HypervisorConnectionId] FROM [%userSiteDB%].[chb_Config].[HypervisorConnections] where Uid='%vmp%'"') do set vmp1=%%i
if %dbcon%==2 for /f "tokens=1" %%i in ('sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -W -h -1 -Q "set nocount on; SELECT [HostedMachineName] FROM [%userMoDB%].[MonitorData].[Machine] where HostedMachineId='%chuuid%'"') do set chname=%%i

:poolvar3
echo 현재 VM(%chname%)에 등록된 하이퍼바이저 Uid번호 는 %vmp: =%번 입니다.
echo.
echo DDC호스팅에 등록된 하이퍼바이저 목록

if %salist%==0 goto ch21 
if %salist%==1 goto ch22 

:ch21
if %dbcon%==1 sqlcmd -S %userDBip%,%dbport% -E -Q "select substring (DisplayName,0,30) AS HyperVisorName,[Uid] from [%userDB%].[chb_Config].[HypervisorConnections]"
if %dbcon%==2 sqlcmd -S %userDBip%,%dbport% -E -Q "select substring (DisplayName,0,30) AS HyperVisorName,[Uid] from [%userSiteDB%].[chb_Config].[HypervisorConnections]"
goto ch3

:ch22
if %dbcon%==1 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -Q "select substring (DisplayName,0,30) AS HyperVisorName,[Uid] from [%userDB%].[chb_Config].[HypervisorConnections]"
if %dbcon%==2 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -Q "select substring (DisplayName,0,30) AS HyperVisorName,[Uid] from [%userSiteDB%].[chb_Config].[HypervisorConnections]"


:ch3
echo 화면에 표시된 교체 진행 할 하이퍼바이저 Uid번호 지정하기
echo.
set /p poolin=입력:

if %salist%==0 goto ch31
if %salist%==1 goto ch32

:ch31
if %dbcon%==1 for /f "tokens=1" %%i in ('sqlcmd -S %userDBip%^,%dbport% -E -W -h -1 -Q "set nocount on; SELECT [HypervisorConnectionId] FROM [%userDB%].[chb_Config].[HypervisorConnections] where Uid='%poolin%'"') do set poolin1=%%i
if %dbcon%==2 for /f "tokens=1" %%i in ('sqlcmd -S %userDBip%^,%dbport% -E -W -h -1 -Q "set nocount on; SELECT [HypervisorConnectionId] FROM [%userSiteDB%].[chb_Config].[HypervisorConnections] where Uid='%poolin%'"') do set poolin1=%%i

goto ch33

:ch32
if %dbcon%==1 for /f "tokens=1" %%i in ('sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -W -h -1 -Q "set nocount on; SELECT [HypervisorConnectionId] FROM [%userDB%].[chb_Config].[HypervisorConnections] where Uid='%poolin%'"') do set poolin1=%%i
if %dbcon%==2 for /f "tokens=1" %%i in ('sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -W -h -1 -Q "set nocount on; SELECT [HypervisorConnectionId] FROM [%userSiteDB%].[chb_Config].[HypervisorConnections] where Uid='%poolin%'"') do set poolin1=%%i

:ch33
echo SET QUOTED_IDENTIFIER ON > "%TMP%\Pool.sql"
echo. >> "%TMP%\Pool.sql"
echo GO >> "%TMP%\Pool.sql"
echo. >> "%TMP%\Pool.sql"
echo. >> "%TMP%\Pool.sql"
:: Monitoring DB 변경 구간
if %dbcon%==1 echo UPDATE [%userDB%].[MonitorData].[Machine] >> "%TMP%\Pool.sql"
if %dbcon%==2 echo UPDATE [%userMoDB%].[MonitorData].[Machine] >> "%TMP%\Pool.sql"
echo SET HypervisorId = '%poolin1%' >> "%TMP%\Pool.sql"
echo WHERE HostedMachineId = '%chuuid%' >> "%TMP%\Pool.sql"
echo. >> "%TMP%\Pool.sql"
:: Site DB 변경 구간
if %dbcon%==1 echo UPDATE [%userDB%].[chb_Config].[Workers] >> "%TMP%\Pool.sql"
if %dbcon%==2 echo UPDATE [%userSiteDB%].[chb_Config].[Workers] >> "%TMP%\Pool.sql"
echo SET HypervisorConnectionUid = '%poolin%' >> "%TMP%\Pool.sql"
echo WHERE HostedMachineId = '%chuuid%' >> "%TMP%\Pool.sql"
echo. >> "%TMP%\Pool.sql"
if %dbcon%==1 echo UPDATE [%userDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] >> "%TMP%\Pool.sql"
if %dbcon%==2 echo UPDATE [%userSiteDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] >> "%TMP%\Pool.sql"
echo SET HypervisorConnectionUid = '%poolin1%' >> "%TMP%\Pool.sql"
echo WHERE VMId = '%chuuid%' >> "%TMP%\Pool.sql"
echo.

if %salist%==0 sqlcmd -E -S %userDBip%,%dbport% -i "%TMP%\Pool.sql"
if %salist%==1 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -i "%TMP%\Pool.sql"

echo VM(%chname%). %vmp: =%번에서 %poolin%번 풀 변경 완료!

:PoolBK
if %bkoption%==0 goto ch34
if exist "Backup\Pool\" (echo.) ELSE (mkdir "Backup\Pool\")
if exist "Backup\Pool\poolbak.sql" (echo.) ELSE (goto PBKrenameskip)
for /f "tokens=3" %%i in ('findstr "일자" "Backup\Pool\poolbak.sql"') do set rename=%%i >nul
move "Backup\Pool\poolbak.sql" "Backup\Pool\%rename::=% poolbak.sql" >nul
:PBKrenameskip
:: Pool backup 저장
echo -- 백업일자: %date:~2,2%%date:~5,2%%date:~8,2%-%time:~0,8% > "Backup\Pool\poolbak.sql"
echo -- 백업대상VM: VMUID:%chuuid% VMName:%chname% >> "Backup\Pool\poolbak.sql"
echo -- 변경내용: Hpervisor Pool %vmp: =%번에서 %poolin%번 풀 변경 >> "Backup\Pool\poolbak.sql"
echo SET QUOTED_IDENTIFIER ON >> "Backup\Pool\poolbak.sql"
echo. >> "Backup\Pool\poolbak.sql"
echo GO >> "Backup\Pool\poolbak.sql"
echo. >> "Backup\Pool\poolbak.sql"
echo. >> "Backup\Pool\poolbak.sql"
:: Monitoring DB 구간
if %dbcon%==1 echo UPDATE [%userDB%].[MonitorData].[Machine] >> "Backup\Pool\poolbak.sql"
if %dbcon%==2 echo UPDATE [%userMoDB%].[MonitorData].[Machine] >> "Backup\Pool\poolbak.sql"
echo SET HypervisorId = '%vmp1%' >> "Backup\Pool\poolbak.sql"
echo WHERE HostedMachineId = '%chuuid%' >> "Backup\Pool\poolbak.sql"
echo. >> "Backup\Pool\poolbak.sql"
:: Site DB 구간
if %dbcon%==1 echo UPDATE [%userDB%].[chb_Config].[Workers] >> "Backup\Pool\poolbak.sql"
if %dbcon%==2 echo UPDATE [%userSiteDB%].[chb_Config].[Workers] >> "Backup\Pool\poolbak.sql"
echo SET HypervisorConnectionUid = '%vmp: =%' >> "Backup\Pool\poolbak.sql"
echo WHERE HostedMachineId = '%chuuid%' >> "Backup\Pool\poolbak.sql"
echo. >> "Backup\Pool\poolbak.sql"
if %dbcon%==1 echo UPDATE [%userDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] >> "Backup\Pool\poolbak.sql"
if %dbcon%==2 echo UPDATE [%userSiteDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] >> "Backup\Pool\poolbak.sql"
echo SET HypervisorConnectionUid = '%vmp1%' >> "Backup\Pool\poolbak.sql"
echo WHERE VMId = '%chuuid%' >> "Backup\Pool\poolbak.sql"
echo.


:ch34
pause 

del "%TMP%\*.sql" "%TMP%\*.log"

goto main2


:ch4
:: Catalog Master VM 교체 스크립트 구간
cls 
set ctl=c
echo 3. Catalog Master VM 교체
echo 이전메뉴로 돌아가기 'c' 입력
echo.
echo ##참고
echo 1) 진행 전 바꿔치기 용 MCS Catalog 생성 후 진행
echo 2) 대상의 카탈로그 Name 입력 후 바꿔치기할 카탈로그 Name 입력
echo.
echo 카탈로그에 등록된 마스터 VM UUID 및 하이퍼바이저 Uid 목록 확인
if %salist%==0 goto mokrokc1
if %salist%==1 goto mokrokc2
:iprueck
echo.
echo 대상 카탈로그네임 입력
set /p ctl=입력:
if %ctl%==c goto main2
if %ctl%==C goto main2
echo.
echo 바꿔치기 할 카탈로그네임 입력
set /p chctl=입력:
echo.

::sqlcmd -S 192.168.201.67,1433 -E -Q "select substring (CatalogName,0,20) AS CatalogName,[ProvisioningSchemeId] AS ProvisioningUid,[HypervisorConnectionUid] AS Hypervisor from [leedkVDI].[chb_Config].[Catalogs]"


if %salist%==0 goto ch41
if %salist%==1 goto ch42

:mokrokc1
if %dbcon%==1 sqlcmd -S %userDBip%,%dbport% -E -Q "select substring (B.DisplayName,0,20) AS CatalogName,[ProvisioningSchemeId],substring (A.DisplayName,0,20) AS HypervisorName FROM [%userDB%].[chb_Config].[HypervisorConnections] A LEFT OUTER JOIN [%userDB%].[chb_Config].[Catalogs]  B ON A.Uid = B.HypervisorConnectionUid;"
if %dbcon%==2 sqlcmd -S %userDBip%,%dbport% -E -Q "select substring (B.DisplayName,0,20) AS CatalogName,[ProvisioningSchemeId],substring (A.DisplayName,0,20) AS HypervisorName FROM [%userSiteDB%].[chb_Config].[HypervisorConnections] A LEFT OUTER JOIN [%userSiteDB%].[chb_Config].[Catalogs]  B ON A.Uid = B.HypervisorConnectionUid;"
goto iprueck

:mokrokc2
if %dbcon%==1 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -Q "select substring (B.DisplayName,0,20) AS CatalogName,[ProvisioningSchemeId],substring (A.DisplayName,0,20) AS HypervisorName FROM [%userDB%].[chb_Config].[HypervisorConnections] A LEFT OUTER JOIN [%userDB%].[chb_Config].[Catalogs]  B ON A.Uid = B.HypervisorConnectionUid;"
if %dbcon%==2 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -Q "select substring (B.DisplayName,0,20) AS CatalogName,[ProvisioningSchemeId],substring (A.DisplayName,0,20) AS HypervisorName FROM [%userSiteDB%].[chb_Config].[HypervisorConnections] A LEFT OUTER JOIN [%userSiteDB%].[chb_Config].[Catalogs]  B ON A.Uid = B.HypervisorConnectionUid;"
goto iprueck

:ch41
if %dbcon%==1 sqlcmd -S %userDBip%,%dbport% -E -W -Q "select [ProvisioningSchemeId] From [%userDB%].[chb_Config].[Catalogs] where [DisplayName] like '%ctl%'" |more +2 > "%TMP%\ctluuid.log"
if %dbcon%==2 sqlcmd -S %userDBip%,%dbport% -E -W -Q "select [ProvisioningSchemeId] From [%userSiteDB%].[chb_Config].[Catalogs] where [DisplayName] like '%ctl%'" |more +2 > "%TMP%\ctluuid.log"
set /p ProvSID=<"%TMP%\ctluuid.log"

if %dbcon%==1 sqlcmd -S %userDBip%,%dbport% -E -W -Q "select [ProvisioningSchemeId] From [%userDB%].[chb_Config].[Catalogs] where [DisplayName] like '%chctl%'" |more +2 > "%TMP%\chctluuid.log"
if %dbcon%==2 sqlcmd -S %userDBip%,%dbport% -E -W -Q "select [ProvisioningSchemeId] From [%userSiteDB%].[chb_Config].[Catalogs] where [DisplayName] like '%chctl%'" |more +2 > "%TMP%\chctluuid.log"
set /p chProvSID=<"%TMP%\chctluuid.log"

if %dbcon%==1 sqlcmd -S %userDBip%,%dbport% -E -W -Q "select [HypervisorConnectionUid] From [%userDB%].[chb_Config].[Catalogs] where [DisplayName] like '%ctl%'" |more +2 > "%TMP%\hypuuid.log"
if %dbcon%==2 sqlcmd -S %userDBip%,%dbport% -E -W -Q "select [HypervisorConnectionUid] From [%userSiteDB%].[chb_Config].[Catalogs] where [DisplayName] like '%ctl%'" |more +2 > "%TMP%\hypuuid.log"
set /p HypUID=<"%TMP%\hypuuid.log"

if %dbcon%==1 sqlcmd -S %userDBip%,%dbport% -E -W -Q "select [HypervisorConnectionUid] From [%userDB%].[chb_Config].[Catalogs] where [DisplayName] like '%chctl%'" |more +2 > "%TMP%\chhypuuid.log"
if %dbcon%==2 sqlcmd -S %userDBip%,%dbport% -E -W -Q "select [HypervisorConnectionUid] From [%userSiteDB%].[chb_Config].[Catalogs] where [DisplayName] like '%chctl%'" |more +2 > "%TMP%\chhypuuid.log"
set /p chHypUID=<"%TMP%\chhypuuid.log"

goto ch5

:ch42
if %dbcon%==1 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -W -Q "select [ProvisioningSchemeId] From [%userDB%].[chb_Config].[Catalogs] where [DisplayName] like '%ctl%'" |more +2 > "%TMP%\ctluuid.log"
if %dbcon%==2 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -W -Q "select [ProvisioningSchemeId] From [%userSiteDB%].[chb_Config].[Catalogs] where [DisplayName] like '%ctl%'" |more +2 > "%TMP%\ctluuid.log"
set /p ProvSID=<"%TMP%\ctluuid.log"

if %dbcon%==1 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -W -Q "select [ProvisioningSchemeId] From [%userDB%].[chb_Config].[Catalogs] where [DisplayName] like '%chctl%'" |more +2 > "%TMP%\chctluuid.log"
if %dbcon%==2 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -W -Q "select [ProvisioningSchemeId] From [%userSiteDB%].[chb_Config].[Catalogs] where [DisplayName] like '%chctl%'" |more +2 > "%TMP%\chctluuid.log"
set /p chProvSID=<"%TMP%\chctluuid.log"

if %dbcon%==1 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -W -Q "select [HypervisorConnectionUid] From [%userDB%].[chb_Config].[Catalogs] where [DisplayName] like '%ctl%'" |more +2 > "%TMP%\hypuuid.log"
if %dbcon%==2 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -W -Q "select [HypervisorConnectionUid] From [%userSiteDB%].[chb_Config].[Catalogs] where [DisplayName] like '%ctl%'" |more +2 > "%TMP%\hypuuid.log"
set /p HypUID=<"%TMP%\hypuuid.log"

if %dbcon%==1 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -W -Q "select [HypervisorConnectionUid] From [%userDB%].[chb_Config].[Catalogs] where [DisplayName] like '%chctl%'" |more +2 > "%TMP%\chhypuuid.log"
if %dbcon%==2 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -W -Q "select [HypervisorConnectionUid] From [%userSiteDB%].[chb_Config].[Catalogs] where [DisplayName] like '%chctl%'" |more +2 > "%TMP%\chhypuuid.log"
set /p chHypUID=<"%TMP%\chhypuuid.log"

goto ch5

:ch5
echo.

echo SET QUOTED_IDENTIFIER ON > "%TMP%\MasterVM.sql"
echo. >> "%TMP%\MasterVM.sql"
echo GO >> "%TMP%\MasterVM.sql"
echo. >> "%TMP%\MasterVM.sql"
echo. >> "%TMP%\MasterVM.sql"

if %dbcon%==1 goto ch51
if %dbcon%==2 goto ch52

:ch51
echo UPDATE [%userDB%].[chb_Config].[Catalogs] >> "%TMP%\MasterVM.sql"
echo SET ProvisioningSchemeId = '%chProvSID%' >> "%TMP%\MasterVM.sql"
echo WHERE [DisplayName] = '%ctl%' >> "%TMP%\MasterVM.sql"

echo UPDATE [%userDB%].[chb_Config].[Catalogs] >> "%TMP%\MasterVM.sql"
echo SET HypervisorConnectionUid = '%chHypUID: =%' >> "%TMP%\MasterVM.sql"
echo WHERE [DisplayName] = '%ctl%' >> "%TMP%\MasterVM.sql"

echo UPDATE [%userDB%].[chb_Config].[Catalogs] >> "%TMP%\MasterVM.sql"
echo SET ProvisioningSchemeId = '%ProvSID%' >> "%TMP%\MasterVM.sql"
echo WHERE [DisplayName] = '%chctl%' >> "%TMP%\MasterVM.sql"

echo UPDATE [%userDB%].[chb_Config].[Catalogs] >> "%TMP%\MasterVM.sql"
echo SET HypervisorConnectionUid = '%HypUID: =%' >> "%TMP%\MasterVM.sql"
echo WHERE [DisplayName] = '%chctl%' >> "%TMP%\MasterVM.sql"

goto ch53

:ch52
echo UPDATE [%userSiteDB%].[chb_Config].[Catalogs] >> "%TMP%\MasterVM.sql"
echo SET ProvisioningSchemeId = '%chProvSID%' >> "%TMP%\MasterVM.sql"
echo WHERE [DisplayName] = '%ctl%' >> "%TMP%\MasterVM.sql"

echo UPDATE [%userSiteDB%].[chb_Config].[Catalogs] >> "%TMP%\MasterVM.sql"
echo SET HypervisorConnectionUid = '%chHypUID: =%' >> "%TMP%\MasterVM.sql"
echo WHERE [DisplayName] = '%ctl%' >> "%TMP%\MasterVM.sql"

echo UPDATE [%userSiteDB%].[chb_Config].[Catalogs] >> "%TMP%\MasterVM.sql"
echo SET ProvisioningSchemeId = '%ProvSID%' >> "%TMP%\MasterVM.sql"
echo WHERE [DisplayName] = '%chctl%' >> "%TMP%\MasterVM.sql"

echo UPDATE [%userSiteDB%].[chb_Config].[Catalogs] >> "%TMP%\MasterVM.sql"
echo SET HypervisorConnectionUid = '%HypUID: =%' >> "%TMP%\MasterVM.sql"
echo WHERE [DisplayName] = '%chctl%' >> "%TMP%\MasterVM.sql"

:ch53
echo. >> "%TMP%\MasterVM.sql"
echo.

if %salist%==0 sqlcmd -E -S %userDBip%,%dbport% -i "%TMP%\MasterVM.sql"
if %salist%==1 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -i "%TMP%\MasterVM.sql"

:: cls
echo 마스터 VM 변경 완료!
echo.
echo 변경된 항목 출력

if %salist%==0 goto ch54
if %salist%==1 goto ch55

:ch54
if %dbcon%==1 sqlcmd -S %userDBip%,%dbport% -E -Q "select substring (B.DisplayName,0,20) AS CatalogName,[ProvisioningSchemeId],substring (A.DisplayName,0,20) AS HypervisorName FROM [%userDB%].[chb_Config].[HypervisorConnections] A LEFT OUTER JOIN [%userDB%].[chb_Config].[Catalogs]  B ON A.Uid = B.HypervisorConnectionUid;"
if %dbcon%==2 sqlcmd -S %userDBip%,%dbport% -E -Q "select substring (B.DisplayName,0,20) AS CatalogName,[ProvisioningSchemeId],substring (A.DisplayName,0,20) AS HypervisorName FROM [%userSiteDB%].[chb_Config].[HypervisorConnections] A LEFT OUTER JOIN [%userSiteDB%].[chb_Config].[Catalogs]  B ON A.Uid = B.HypervisorConnectionUid;"

goto MasterBK

:ch55
if %dbcon%==1 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -Q "select substring (B.DisplayName,0,20) AS CatalogName,[ProvisioningSchemeId],substring (A.DisplayName,0,20) AS HypervisorName FROM [%userDB%].[chb_Config].[HypervisorConnections] A LEFT OUTER JOIN [%userDB%].[chb_Config].[Catalogs]  B ON A.Uid = B.HypervisorConnectionUid;"
if %dbcon%==2 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -Q "select substring (B.DisplayName,0,20) AS CatalogName,[ProvisioningSchemeId],substring (A.DisplayName,0,20) AS HypervisorName FROM [%userSiteDB%].[chb_Config].[HypervisorConnections] A LEFT OUTER JOIN [%userSiteDB%].[chb_Config].[Catalogs]  B ON A.Uid = B.HypervisorConnectionUid;"

:MasterBK
if %bkoption%==0 goto ch56
if exist "Backup\Master\" (echo.) ELSE (mkdir "Backup\Master\")
if exist "Backup\Master\imagebak.sql" (echo.) ELSE (goto MBKrenameskip)
for /f "tokens=3" %%i in ('findstr "일자" "Backup\Master\imagebak.sql"') do set rename=%%i >nul
move "Backup\Master\imagebak.sql" "Backup\Master\%rename::=%- imagebak.sql" >nul
:MBKrenameskip
:: Pool backup 저장
echo -- 백업일자: %date:~2,2%%date:~5,2%%date:~8,2%-%time:~0,8% > "Backup\Master\imagebak.sql"
echo -- 대상 카탈로그: %ctl% >> "Backup\Master\imagebak.sql"
echo -- 대상 Hypervisor : %HypUID: =% >> "Backup\Master\imagebak.sql"
echo -- 변경내용: 카탈로그 이미지(%ctl% -^> %chctl%) HypervisorUid(%HypUID: =% -^> %chHypUID: =%) 카탈로그 Uid(%ProvSID% -^> %chProvSID%)>> "Backup\Master\imagebak.sql"
echo SET QUOTED_IDENTIFIER ON >> "Backup\Master\imagebak.sql"
echo. >> "Backup\Master\imagebak.sql"
echo GO >> "Backup\Master\imagebak.sql"
echo. >> "Backup\Master\imagebak.sql"
echo. >> "Backup\Master\imagebak.sql"
if %dbcon%==1 goto MABK1
if %dbcon%==2 goto MABK2
:MABK1
echo UPDATE [%userDB%].[chb_Config].[Catalogs] >> "Backup\Master\imagebak.sql"
echo SET ProvisioningSchemeId = '%chProvSID%' >> "Backup\Master\imagebak.sql"
echo WHERE [DisplayName] = '%chctl%' >> "Backup\Master\imagebak.sql"

echo UPDATE [%userDB%].[chb_Config].[Catalogs] >> "Backup\Master\imagebak.sql"
echo SET HypervisorConnectionUid = '%chHypUID: =%' >> "Backup\Master\imagebak.sql"
echo WHERE [DisplayName] = '%chctl%' >> "Backup\Master\imagebak.sql"

echo UPDATE [%userDB%].[chb_Config].[Catalogs] >> "Backup\Master\imagebak.sql"
echo SET ProvisioningSchemeId = '%ProvSID%' >> "Backup\Master\imagebak.sql"
echo WHERE [DisplayName] = '%ctl%' >> "Backup\Master\imagebak.sql"

echo UPDATE [%userDB%].[chb_Config].[Catalogs] >> "Backup\Master\imagebak.sql"
echo SET HypervisorConnectionUid = '%HypUID: =%' >> "Backup\Master\imagebak.sql"
echo WHERE [DisplayName] = '%ctl%' >> "Backup\Master\imagebak.sql"

goto ch56

:MABK2
echo UPDATE [%userSiteDB%].[chb_Config].[Catalogs] >> "Backup\Master\imagebak.sql"
echo SET ProvisioningSchemeId = '%chProvSID%' >> "Backup\Master\imagebak.sql"
echo WHERE [DisplayName] = '%chctl%' >> "Backup\Master\imagebak.sql"

echo UPDATE [%userSiteDB%].[chb_Config].[Catalogs] >> "Backup\Master\imagebak.sql"
echo SET HypervisorConnectionUid = '%chHypUID: =%' >> "Backup\Master\imagebak.sql"
echo WHERE [DisplayName] = '%chctl%' >> "Backup\Master\imagebak.sql"

echo UPDATE [%userSiteDB%].[chb_Config].[Catalogs] >> "Backup\Master\imagebak.sql"
echo SET ProvisioningSchemeId = '%ProvSID%' >> "Backup\Master\imagebak.sql"
echo WHERE [DisplayName] = '%ctl%' >> "Backup\Master\imagebak.sql"

echo UPDATE [%userSiteDB%].[chb_Config].[Catalogs] >> "Backup\Master\imagebak.sql"
echo SET HypervisorConnectionUid = '%HypUID: =%' >> "Backup\Master\imagebak.sql"
echo WHERE [DisplayName] = '%ctl%' >> "Backup\Master\imagebak.sql"

:ch56
pause 

del "%TMP%\*.sql" "%TMP%\*.log"

goto main2


:selc1
setlocal enabledelayedexpansion
cls
set userDB=c
if %dbcon%==1 set singleDB=Enable
set salist=1
set sauser=sa
if %dbcon%==2 goto selc2
echo SQL Server 인증방식 DB 설정
echo 이전메뉴로 돌아가기 'c' 입력
echo.
echo 1.CVAD DB명 입력
set /p userDB=입력:
if %userDB%==c cls & goto main
if %userDB%==C cls & goto main
echo.
echo 2.DB user 입력 
echo 입력안하고 넘어갈 시 sa계정으로 자동 입력
set /p sauser=입력:
echo.
echo 3.DB %sauser% 계정 패스워드 입력
call :mssqlPass usersapass "입력: "
echo.
exit /b
:selc2
cls
set userSiteDB=c
if %dbcon%==2 set singleDB=Disable
echo DB접속정보 설정
echo 이전메뉴로 돌아가기 'c' 입력
echo.
echo 1.CVAD DB Site명 입력
set /p userSiteDB=입력:
if %userSiteDB%==c cls & goto main
if %userSiteDB%==C cls & goto main
echo.
echo 2.CVAD DB Monitor명 입력
set /p userMoDB=입력:
echo.
echo 3.DB user 입력 
echo 입력안하고 넘어갈 시 sa계정으로 자동 입력
set /p sauser=입력:
echo.
echo 4.DB %sauser% 계정 패스워드 입력
call :mssqlPass usersapass "입력: "
echo.
exit /b

:mssqlPass    
SetLocal DisableDelayedExpansion
echo 입력:
Set "Line="
For /F %%# In ('"Prompt;$H&For %%# in (1) Do Rem"') Do Set "BS=%%#"

:PassLoop
Set "Key="
For /F "delims=" %%# In (
'Xcopy /L /W "%~f0" "%~f0" 2^>Nul'
) Do If Not Defined Key Set "Key=%%#"
Set "Key=%Key:~-1%"
SetLocal EnableDelayedExpansion
If Not Defined Key Goto :PassEnd
If %BS%==^%Key% (Set /P "=%BS% %BS%" <Nul
Set "Key="
If Defined Line Set "Line=!Line:~0,-1!"
) Else Set /P "=*" <Nul
If Not Defined Line (EndLocal &Set "Line=%Key%"
) Else For /F delims^=^ eol^= %%# In (
"!Line!") Do EndLocal &Set "Line=%%#%Key%"
goto :PassLoop


:PassEnd
::암호화
echo(
for /f "tokens=1" %%i in ('echo !Line! ^|bin\openssl.exe enc -e -aes256 -a -k %COMPUTERNAME%') do set passenc=%%i
goto dbpassenc
:dbpassenc
set userDBip=%userDBip%

goto input3

::goto main2

:MVCBAK
set sel=vm
:: VM_UUID, Pool, MasterImage 등을 복원하는 구간
cls
echo 5. CitrixCVUC 복원
echo.
echo ##메뉴화면
echo 1) VM복원 
echo 2) VM Pool 컨넥션 복원
echo 3) Catalog Master VM 복원
echo 4) 모두 복원
echo c) 이전 메뉴로 돌아가기
echo x) 나가기

set /p sel=입력:

if %sel%==vm goto bakerr
if %sel%==1 goto mvcbak1
if %sel%==2 goto mvcbak2
if %sel%==3 goto mvcbak3
if %sel%==4 goto mvcbak4
if %sel%==c goto main2
if %sel%==C goto main2
if %sel%==x exit
if %sel%==X exit


:mvcbak1
cls
echo 5. CitrixCVUC 복원 1)VM 복원
set sel=skip
set baksql="Backup\VM\MCSbak.sql"
for /f "tokens=3" %%i in ('findstr "일자" "Backup\VM\MCSbak.sql"') do set bakdate=%%i >nul
echo.
echo 마지막으로 백업한 일자는 %bakdate% 입니다.
echo %bakdate% 이전으로 복원을 원하시면 값이 없는 상태로 입력창에 엔터만 누르십시오
echo.
echo 이전 메뉴로 돌아가기를 원하시면 C키를 입력하십시오
echo.

set /p baksql=입력:

if %baksql%==c goto MVCBAK
if %baksql%==C goto MVCBAK


if %salist%==0 sqlcmd -E -S %userDBip%,%dbport% -i %baksql%
if %salist%==1 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -i %baksql%
echo.
echo VM 복원 완료!
pause 
goto main2

:mvcbak2
cls
echo 5. CitrixCVUC 복원 2) VM Pool 컨넥션 복원
set sel=skip
set baksql="Backup\Pool\poolbak.sql"
for /f "tokens=3" %%i in ('findstr "일자" "Backup\Pool\poolbak.sql"') do set bakdate=%%i >nul
echo.
echo 마지막으로 백업한 일자는 %bakdate% 입니다.
echo %bakdate% 이전으로 복원을 원하시면 값이 없는 상태로 입력창에 엔터만 누르십시오
echo. 
echo 이전 메뉴로 돌아가기를 원하시면 C키를 입력하십시오
echo.

set /p baksql=입력:

if %baksql%==c goto MVCBAK
if %baksql%==C goto MVCBAK


if %salist%==0 sqlcmd -E -S %userDBip%,%dbport% -i %baksql%
if %salist%==1 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -i %baksql%
echo.
echo VM 복원 완료!
pause 
goto main2

:mvcbak3
cls
echo 5. CitrixCVUC 복원 3) Catalog Master VM 복원
set sel=skip
set baksql="Backup\Master\imagebak.sql"
for /f "tokens=3" %%i in ('findstr "일자" "Backup\Master\imagebak.sql"') do set bakdate=%%i >nul
echo.
echo 마지막으로 진행한 일자는 %bakdate% 입니다.
echo %bakdate% 이전으로 복원을 원하시면 값이 없는 상태로 입력창에 엔터만 누르십시오
echo. 
echo 이전 메뉴로 돌아가기를 원하시면 C키를 입력하십시오
echo.

set /p baksql=입력:

if %baksql%==c goto MVCBAK
if %baksql%==C goto MVCBAK


if %salist%==0 sqlcmd -E -S %userDBip%,%dbport% -i %baksql%
if %salist%==1 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -i %baksql%
echo.
echo VM 복원 완료!
pause 
goto main2

:mvcbak4
cls
echo 5. CitrixCVUC 복원 4) 모두 복원
set sel=skip
set baksql=skip
set Vbaksql="Backup\Master\imagebak.sql"
set Pbaksql="Backup\Pool\poolbak.sql"
set Mbaksql="Backup\Master\imagebak.sql"
for /f "tokens=3" %%i in ('findstr "일자" "Backup\VM\MCSbak.sql"') do set Vbakdate=%%i >nul
for /f "tokens=3" %%i in ('findstr "일자" "Backup\Pool\poolbak.sql"') do set Pbakdate=%%i >nul
for /f "tokens=3" %%i in ('findstr "일자" "Backup\Master\imagebak.sql"') do set Mbakdate=%%i >nul
echo.
echo 1. VM_UUID 진행을 마지막으로 진행한 일자는 %Vbakdate% 입니다.
echo 2. VM_UUID 진행을 마지막으로 진행한 일자는 %Pbakdate% 입니다.
echo 3. VM_UUID 진행을 마지막으로 진행한 일자는 %Mbakdate% 입니다.
echo 진행 이전으로 복원을 원하시면 값이 없는 상태로 입력창에 엔터만 누르십시오
echo. 
echo 이전 메뉴로 돌아가기를 원하시면 C키를 입력하십시오
echo.

set /p baksql=입력:

if %baksql%==c goto MVCBAK
if %baksql%==C goto MVCBAK
if %baksql%==skip goto mvcbaktotal

goto mvcbak4

:mvcbaktotal
if %salist%==0 sqlcmd -E -S %userDBip%,%dbport% -i %Vbaksql%
if %salist%==0 sqlcmd -E -S %userDBip%,%dbport% -i %Pbaksql%
if %salist%==0 sqlcmd -E -S %userDBip%,%dbport% -i %Mbaksql%
if %salist%==1 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -i %Vbaksql%
if %salist%==1 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -i %Pbaksql%
if %salist%==1 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -i %Mbaksql%
echo.
echo VM 복원 완료!
pause 
goto main2


:bakerr
echo 범위를 벗어난 입력입니다.
pause
goto MVCBAK


:CSVhome
setlocal EnableDelayedExpansion
set sel=vm
if exist "CSV\" (goto MVCCSV) ELSE (mkdir "CSV\")
:: VM_UUID, Pool, MasterImage CSV로 저장 및 불러오는 구간
:MVCCSV
cls
echo 6. 다량의 데이터 처리하기 (CSV파일 처리)
echo.
echo ##메뉴화면
echo 1) VM_UUID,VM_Pool 컨넥션 csv 양식 저장하기
echo 2) VM_UUID,VM_Pool 컨넥션 csv 불러오기
echo 3) Catalog Master VM csv 양식 저장하기
echo 4) Catalog Master VM csv 불러오기
echo c) 이전 메뉴로 돌아가기
echo x) 나가기
echo.
echo ## 주의사항! 
echo csv양식을 엑셀로 수정 후 저장 시 *.xlsx , *.xlsm , *.xls 등으로 저장 X
echo 반드시 저장은 *.csv 형식으로 저장!

set /p sel=입력:

if %sel%==vm goto csverr
if %sel%==1 goto mvccsv1
if %sel%==2 goto mvccsv2
if %sel%==3 goto mvccsv3
if %sel%==4 goto mvccsv4
if %sel%==c goto main2
if %sel%==C goto main2
if %sel%==x exit
if %sel%==X exit

:csverr
echo 범위를 벗어난 입력입니다.
pause
goto MVCCSV

:mvccsv1
echo 1) VM_UUID,VM_Pool 컨넥션 csv 양식 저장하기
echo.
echo 저장중...
if %salist%==0 goto mvccsv1ch1
if %salist%==1 goto mvccsv1ch2

:mvccsv1ch1
if %dbcon%==1 sqlcmd -E -S %userDBip%,%dbport% -s"," -W -Q "set nocount on; select row_number() over (order by A.Uid desc) AS Num,A.Uid,HostedMachineName AS VMName,A.HostedMachineId AS VMUid,substring (B.DisplayName,0,20) AS HypervisorName from [%userDB%].[Chb_Config].[Workers] A LEFT OUTER JOIN [%userDB%].[chb_Config].[HypervisorConnections] B ON A.HypervisorConnectionUid = B.Uid LEFT OUTER JOIN [%userDB%].[MonitorData].[Machine] C ON A.HostedMachineId = C.HostedMachineId" -o CSV\MVCCSV.csv -s ","
if %dbcon%==2 sqlcmd -E -S %userDBip%,%dbport% -s"," -W -Q "set nocount on; select row_number() over (order by A.Uid desc) AS Num,A.Uid,HostedMachineName AS VMName,A.HostedMachineId AS VMUid,substring (B.DisplayName,0,20) AS HypervisorName from [%userSiteDB%].[Chb_Config].[Workers] A LEFT OUTER JOIN [%userSiteDB%].[chb_Config].[HypervisorConnections] B ON A.HypervisorConnectionUid = B.Uid LEFT OUTER JOIN [%userMoDB%].[MonitorData].[Machine] C ON A.HostedMachineId = C.HostedMachineId" -o CSV\MVCCSV.csv -s ","

goto mvccsv1ch3

:mvccsv1ch2
if %dbcon%==1 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -s"," -W -Q "set nocount on; select row_number() over (order by A.Uid desc) AS Num,A.Uid,HostedMachineName AS VMName,A.HostedMachineId AS VMUid,substring (B.DisplayName,0,20) AS HypervisorName from [%userDB%].[Chb_Config].[Workers] A LEFT OUTER JOIN [%userDB%].[chb_Config].[HypervisorConnections] B ON A.HypervisorConnectionUid = B.Uid LEFT OUTER JOIN [%userDB%].[MonitorData].[Machine] C ON A.HostedMachineId = C.HostedMachineId" -o CSV\MVCCSV.csv -s ","
if %dbcon%==2 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -s"," -W -Q "set nocount on; select row_number() over (order by A.Uid desc) AS Num,A.Uid,HostedMachineName AS VMName,A.HostedMachineId AS VMUid,substring (B.DisplayName,0,20) AS HypervisorName from [%userSiteDB%].[Chb_Config].[Workers] A LEFT OUTER JOIN [%userSiteDB%].[chb_Config].[HypervisorConnections] B ON A.HypervisorConnectionUid = B.Uid LEFT OUTER JOIN [%userMoDB%].[MonitorData].[Machine] C ON A.HostedMachineId = C.HostedMachineId" -o CSV\MVCCSV.csv -s ","

:mvccsv1ch3
echo.
echo CSV\MVCCSV.csv 경로로 저장 완료하였습니다!
pause
goto MVCCSV

:mvccsv2
set sel=CSV\MVCCSV.csv
echo.
echo 2) VM_UUID,VM_Pool 컨넥션 csv 불러오기
echo.
echo CSV\MVCCSV.csv에서 불러오는 것이 아닌 지정 된 파일로 불러오기를 할 경우
echo csv파일의 경로를 입력하거나 파일을 드레그 앤 드랍하여 경로를 지정
echo 입력예시) C:\Users\user\Desktop\MVCCSV.csv
echo.
echo 이전 메뉴로 돌아가기 'C' 버튼 클릭, 나가기 'X' 버튼
echo.
echo.
set /p sel=입력 또는 드레그앤 드랍:

if %sel%==c goto MVCCSV
if %sel%==C goto MVCCSV
if %sel%==x goto exit
if %sel%==X goto exit

:mvccsv2home
echo 진행중...
for /f %%i in ('type %sel% ^|find /c /v ""') do set /a count=%%i-2

:: 첫번째 Uid 라인 구간
:workuidcsv
set "col=0"
for /f "skip=3 tokens=2 delims=," %%c in ('find /v "" %sel%') do (
    set "workuid!col!=%%c"
    set /a "col+=1"
    if !col! gtr %count% (
	goto workuidend
	)
)

:workuidend
for /l %%a in (1,1,%count%) do set "uid%%a=!workuid%%a!"

:: 두번째 VMName 구간
:vmnamecsv
set "col=0"
for /f "skip=3 tokens=3 delims=," %%c in ('find /v "" %sel%') do (
    set "vmname!col!=%%c"
    set /a "col+=1"
    if !col! gtr %count% (
	goto vmnameend
	)
)

:vmnameend
for /l %%a in (1,1,%count%) do set "vmn%%a=!vmname%%a!"

:: 세번째 VMUid 구간
:vmuidcsv
set "col=0"
for /f "skip=3 tokens=4 delims=," %%c in ('find /v "" %sel%') do (
    set "vmuid!col!=%%c"
    set /a "col+=1"
    if !col! gtr %count% (
	goto vmuidend
	)
)

:vmuidend
for /l %%a in (1,1,%count%) do set "vmu%%a=!vmuid%%a!"


:: 네번째 HypervisorName 구간
:hypernamecsv
set "col=0"
for /f "skip=3 tokens=5 delims=," %%c in ('find /v "" %sel%') do (
    set "hypername!col!=%%c"
    set /a "col+=1"
    if !col! gtr %count% (
	goto hypernameend
	)
)

:hypernameend
for /l %%a in (1,1,%count%) do set "hypn%%a=!hypername%%a!" 

:: 진행
if %dbcon%==1 goto mvccsv2ch1
if %dbcon%==2 goto mvccsv2ch2

:mvccsv2ch1
if %salist%==0 goto mvccsv2ch3
::VM 구간
for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[MonitorData].[Machine] Set HostedMachineId = '!vmu%%t!' WHERE HostedMachineName = '!vmn%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[Chb_Config].[Workers] Set HostedMachineId = '!vmu%%t!' FROM [%userDB%].[Chb_Config].[Workers] w Left Join [%userDB%].[MonitorData].[Machine] m ON w.HostedMachineId = m.HostedMachineId where m.HostedMachineName = '!vmn%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] Set VMId = '!vmu%%t!' WHERE VMName = '!vmn%%t!'"

::pool 구간
for /l %%t in (1,1,%count%) do for /f "tokens=*" %%i in ('sqlcmd -S %userDBip%^^^,%dbport% -U %sauser% -P !sapass! -s"=" -W -h -1 -Q "set nocount on; select Uid FROM [%userDB%].chb_Config.HypervisorConnections where DisplayName = '!hypn%%t!'"') do set hypu%%t=%%i
for /l %%t in (1,1,%count%) do for /f "tokens=*" %%i in ('sqlcmd -S %userDBip%^^^,%dbport% -U %sauser% -P !sapass! -s"=" -W -h -1 -Q "set nocount on; select HypervisorConnectionId FROM [%userDB%].chb_Config.HypervisorConnections where DisplayName = '!hypn%%t!'"') do set hypi%%t=%%i

for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[MonitorData].[Machine] Set HypervisorId = '!hypi%%t!' WHERE HostedMachineName = '!vmn%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[Chb_Config].[Workers] Set HypervisorConnectionUid = '!hypu%%t!' WHERE HostedMachineId = '!vmu%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] SET HypervisorConnectionUid = '!hypi%%t!' WHERE VMId = '!vmn%%t!'"

goto mvccsv2ch5

:mvccsv2ch2
if %salist%==0 goto mvccsv2ch4
::VM 구간
for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userMoDB%].[MonitorData].[Machine] Set HostedMachineId = '!vmu%%t!' WHERE HostedMachineName = '!vmn%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userSiteDB%].[Chb_Config].[Workers] Set HostedMachineId = '!vmu%%t!' FROM [%userSiteDB%].[Chb_Config].[Workers] w Left Join [%userMoDB%].[MonitorData].[Machine] m ON w.HostedMachineId = m.HostedMachineId where m.HostedMachineName = '!vmn%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userSiteDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] Set VMId = '!vmu%%t!' WHERE VMName = '!vmn%%t!'"

::pool 구간
for /l %%t in (1,1,%count%) do for /f "tokens=*" %%i in ('sqlcmd -S %userDBip%^^^,%dbport% -U %sauser% -P !sapass! -s"=" -W -h -1 -Q "set nocount on; select Uid FROM [%userSiteDB%].chb_Config.HypervisorConnections where DisplayName = '!hypn%%t!'"') do set hypu%%t=%%i
for /l %%t in (1,1,%count%) do for /f "tokens=*" %%i in ('sqlcmd -S %userDBip%^^^,%dbport% -U %sauser% -P !sapass! -s"=" -W -h -1 -Q "set nocount on; select HypervisorConnectionId FROM [%userSiteDB%].chb_Config.HypervisorConnections where DisplayName = '!hypn%%t!'"') do set hypi%%t=%%i

for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userMoDB%].[MonitorData].[Machine] Set HypervisorId = '!hypi%%t!' WHERE HostedMachineName = '!vmn%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userSiteDB%].[Chb_Config].[Workers] Set HypervisorConnectionUid = '!hypu%%t!' WHERE HostedMachineId = '!vmu%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userSiteDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] SET HypervisorConnectionUid = '!hypi%%t!' WHERE VMId = '!vmn%%t!'"

goto mvccsv2ch5

:mvccsv2ch3
::VM 구간
for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[MonitorData].[Machine] Set HostedMachineId = '!vmu%%t!' WHERE HostedMachineName = '!vmn%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[Chb_Config].[Workers] Set HostedMachineId = '!vmu%%t!' FROM [%userDB%].[Chb_Config].[Workers] w Left Join [%userDB%].[MonitorData].[Machine] m ON w.HostedMachineId = m.HostedMachineId where m.HostedMachineName = '!vmn%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] Set VMId = '!vmu%%t!' WHERE VMName = '!vmn%%t!'"

::pool 구간
for /l %%t in (1,1,%count%) do for /f "tokens=*" %%i in ('sqlcmd -E -S %userDBip%^^^,%dbport% -s"=" -W -h -1 -Q "set nocount on; select Uid FROM [%userDB%].chb_Config.HypervisorConnections where DisplayName = '!hypn%%t!'"') do set hypu%%t=%%i
for /l %%t in (1,1,%count%) do for /f "tokens=*" %%i in ('sqlcmd -E -S %userDBip%^^^,%dbport% -s"=" -W -h -1 -Q "set nocount on; select HypervisorConnectionId FROM [%userDB%].chb_Config.HypervisorConnections where DisplayName = '!hypn%%t!'"') do set hypi%%t=%%i

for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[MonitorData].[Machine] Set HypervisorId = '!hypi%%t!' WHERE HostedMachineName = '!vmn%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[Chb_Config].[Workers] Set HypervisorConnectionUid = '!hypu%%t!' WHERE HostedMachineId = '!vmu%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] SET HypervisorConnectionUid = '!hypi%%t!' WHERE VMId = '!vmn%%t!'"

goto mvccsv2ch5

:mvccsv2ch4
::VM 구간
for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userMoDB%].[MonitorData].[Machine] Set HostedMachineId = '!vmu%%t!' WHERE HostedMachineName = '!vmn%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userSiteDB%].[Chb_Config].[Workers] Set HostedMachineId = '!vmu%%t!' FROM [%userSiteDB%].[Chb_Config].[Workers] w Left Join [%userMoDB%].[MonitorData].[Machine] m ON w.HostedMachineId = m.HostedMachineId where m.HostedMachineName = '!vmn%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userSiteDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] Set VMId = '!vmu%%t!' WHERE VMName = '!vmn%%t!'"

::pool 구간
for /l %%t in (1,1,%count%) do for /f "tokens=*" %%i in ('sqlcmd -E -S %userDBip%^^^,%dbport% -s"=" -W -h -1 -Q "set nocount on; select Uid FROM [%userSiteDB%].chb_Config.HypervisorConnections where DisplayName = '!hypn%%t!'"') do set hypu%%t=%%i
for /l %%t in (1,1,%count%) do for /f "tokens=*" %%i in ('sqlcmd -E -S %userDBip%^^^,%dbport% -s"=" -W -h -1 -Q "set nocount on; select HypervisorConnectionId FROM [%userSiteDB%].chb_Config.HypervisorConnections where DisplayName = '!hypn%%t!'"') do set hypi%%t=%%i

for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userMoDB%].[MonitorData].[Machine] Set HypervisorId = '!hypi%%t!' WHERE HostedMachineName = '!vmn%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userSiteDB%].[Chb_Config].[Workers] Set HypervisorConnectionUid = '!hypu%%t!' WHERE HostedMachineId = '!vmu%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userSiteDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] SET HypervisorConnectionUid = '!hypi%%t!' WHERE VMId = '!vmn%%t!'"


goto mvccsv2ch5


:mvccsv2ch5
echo 불러오기가 완료되었습니다!
pause
goto MVCCSV


:mvccsv3
echo 3) Catalog Master VM csv 양식 저장하기
echo.
echo 저장중...
if %salist%==0 goto mvccsv3ch1
if %salist%==1 goto mvccsv3ch2

:mvccsv3ch1
if %dbcon%==1 sqlcmd -E -S %userDBip%,%dbport% -s"," -W -Q "set nocount on; select row_number() over (order by B.Uid desc) AS Num,substring (B.DisplayName,0,20) AS CatalogName,[ProvisioningSchemeId],substring (A.DisplayName,0,20) AS HypervisorName FROM [%userDB%].[chb_Config].[HypervisorConnections] A LEFT OUTER JOIN [%userDB%].[chb_Config].[Catalogs]  B ON A.Uid = B.HypervisorConnectionUid;" -o CSV\Master.csv -s ","
if %dbcon%==2 sqlcmd -E -S %userDBip%,%dbport% -s"," -W -Q "set nocount on; select row_number() over (order by B.Uid desc) AS Num,substring (B.DisplayName,0,20) AS CatalogName,[ProvisioningSchemeId],substring (A.DisplayName,0,20) AS HypervisorName FROM [%userSiteDB%].[chb_Config].[HypervisorConnections] A LEFT OUTER JOIN [%userSiteDB%].[chb_Config].[Catalogs]  B ON A.Uid = B.HypervisorConnectionUid;" -o CSV\Master.csv -s ","

goto mvccsv3ch3

:mvccsv3ch2
if %dbcon%==1 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -s"," -W -Q "set nocount on; select row_number() over (order by B.Uid desc) AS Num,substring (B.DisplayName,0,20) AS CatalogName,[ProvisioningSchemeId],substring (A.DisplayName,0,20) AS HypervisorName FROM [%userDB%].[chb_Config].[HypervisorConnections] A LEFT OUTER JOIN [%userDB%].[chb_Config].[Catalogs]  B ON A.Uid = B.HypervisorConnectionUid;" -o CSV\Master.csv -s ","
if %dbcon%==2 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -s"," -W -Q "set nocount on; select row_number() over (order by B.Uid desc) AS Num,substring (B.DisplayName,0,20) AS CatalogName,[ProvisioningSchemeId],substring (A.DisplayName,0,20) AS HypervisorName FROM [%userSiteDB%].[chb_Config].[HypervisorConnections] A LEFT OUTER JOIN [%userSiteDB%].[chb_Config].[Catalogs]  B ON A.Uid = B.HypervisorConnectionUid;" -o CSV\Master.csv -s ","

:mvccsv3ch3
echo.
echo CSV\Master.csv 경로로 저장 완료하였습니다!
pause
goto MVCCSV


:mvccsv4
echo.
set sel=CSV\Master.csv
echo 4) Catalog Master VM csv 불러오기
echo.
echo CSV\Master.csv에서 불러오는 것이 아닌 지정 된 파일로 불러오기를 할 경우
echo csv파일의 경로를 입력하거나 파일을 드레그 앤 드랍하여 경로를 지정
echo 입력예시) C:\Users\user\Desktop\Master.csv
echo.
echo 이전 메뉴로 돌아가기 'C' 버튼 클릭, 나가기 'X' 버튼
echo.
echo.
set /p sel=입력 또는 드레그앤 드랍:

if %sel%==c goto MVCCSV
if %sel%==C goto MVCCSV
if %sel%==x goto exit
if %sel%==X goto exit

:mvccsv4home
echo 진행중...
for /f %%i in ('type %sel% ^|find /c /v ""') do set /a count=%%i-2
:: 첫번째 카탈로그 네임 라인 구간
:catalncsv
set "col=0"
for /f "skip=3 tokens=2 delims=," %%c in ('find /v "" %sel%') do (
    set "cataln!col!=%%c"
    set /a "col+=1"
    if !col! gtr %count% (
	goto catalnend
	)
)

:catalnend
for /l %%a in (1,1,%count%) do set "catalogname%%a=!cataln%%a!"

:: 두번째 ProvisioningSchemeId 구간
:ProvSchId
set "col=0"
for /f "skip=3 tokens=3 delims=," %%c in ('find /v "" %sel%') do (
    set "proscid!col!=%%c"
    set /a "col+=1"
    if !col! gtr %count% (
	goto ProvSchIdend
	)
)

:ProvSchIdend
for /l %%a in (1,1,%count%) do set "provid%%a=!proscid%%a!"

:: 세번째 HypervisorName 구간
:Masterhypercsv
set "col=0"
for /f "skip=3 tokens=4 delims=," %%c in ('find /v "" %sel%') do (
    set "hypername!col!=%%c"
    set /a "col+=1"
    if !col! gtr %count% (
	goto Masterhyperend
	)
)

:Masterhyperend
for /l %%a in (1,1,%count%) do set "hypn%%a=!hypername%%a!"  

:: 진행
if %dbcon%==1 goto mvccsv4ch1
if %dbcon%==2 goto mvccsv4ch2

:mvccsv4ch1
if %salist%==0 goto mvccsv4ch3
::pool 구간
for /l %%t in (1,1,%count%) do for /f "tokens=*" %%i in ('sqlcmd -S %userDBip%^^^,%dbport% -U %sauser% -P !sapass! -s"=" -W -h -1 -Q "set nocount on; select Uid FROM [%userDB%].chb_Config.HypervisorConnections where DisplayName = '!hypn%%t!'"') do set hypu%%t=%%i

for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[chb_Config].[Catalogs] Set ProvisioningSchemeId = '!provid%%t!' WHERE DisplayName = '!catalogname%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[chb_Config].[Catalogs] Set HypervisorConnectionUid = '!hypu%%t!' WHERE DisplayName = '!catalogname%%t!'"

goto mvccsv4ch5

:mvccsv4ch2
if %salist%==0 goto mvccsv4ch4
::pool 구간
for /l %%t in (1,1,%count%) do for /f "tokens=*" %%i in ('sqlcmd -S %userDBip%^^^,%dbport% -U %sauser% -P !sapass! -s"=" -W -h -1 -Q "set nocount on; select Uid FROM [%userSiteDB%].chb_Config.HypervisorConnections where DisplayName = '!hypn%%t!'"') do set hypu%%t=%%i

for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userSiteDB%].[chb_Config].[Catalogs] Set ProvisioningSchemeId = '!provid%%t!' WHERE DisplayName = '!catalogname%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userSiteDB%].[chb_Config].[Catalogs] Set HypervisorConnectionUid = '!hypu%%t!' WHERE DisplayName = '!catalogname%%t!'"

goto mvccsv4ch5

:mvccsv4ch3
::pool 구간
for /l %%t in (1,1,%count%) do for /f "tokens=*" %%i in ('sqlcmd -E -S %userDBip%^^^,%dbport% -s"=" -W -h -1 -Q "set nocount on; select Uid FROM [%userDB%].chb_Config.HypervisorConnections where DisplayName = '!hypn%%t!'"') do set hypu%%t=%%i

for /l %%t in (1,1,%count%) do sqlcmd -S -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[chb_Config].[Catalogs] Set ProvisioningSchemeId = '!provid%%t!' WHERE DisplayName = '!catalogname%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -S -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[chb_Config].[Catalogs] Set HypervisorConnectionUid = '!hypu%%t!' WHERE DisplayName = '!catalogname%%t!'"

goto mvccsv4ch5

:mvccsv4ch4
::pool 구간
for /l %%t in (1,1,%count%) do for /f "tokens=*" %%i in ('sqlcmd -E -S %userDBip%^^^,%dbport% -s"=" -W -h -1 -Q "set nocount on; select Uid FROM [%userSiteDB%].chb_Config.HypervisorConnections where DisplayName = '!hypn%%t!'"') do set hypu%%t=%%i

for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userSiteDB%].[chb_Config].[Catalogs] Set ProvisioningSchemeId = '!provid%%t!' WHERE DisplayName = '!catalogname%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userSiteDB%].[chb_Config].[Catalogs] Set HypervisorConnectionUid = '!hypu%%t!' WHERE DisplayName = '!catalogname%%t!'"

goto mvccsv4ch5


:mvccsv4ch5
echo 불러오기가 완료되었습니다!
echo.
pause

goto MVCCSV


:ver
cls
echo 현재 버전 Citrix CVAD VDI UUID Changer v1.3.1a
echo Date 2023-07-27
echo Copyright ⓒ Leedk. All rights reserved.
echo.
pause
goto main2
echo ahlpa patch codename a
