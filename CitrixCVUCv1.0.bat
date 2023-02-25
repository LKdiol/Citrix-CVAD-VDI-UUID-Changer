@echo off 
echo Citrix CVAD VDI UUID Changer v1.0
title Citrix CVAD VDI UUID Changer v1.0
set salist=0
::Citrix MCS VM UUID변경 툴

:: config 설정 ------

:: DB서버 포트 설정
set dbport=1433

:: DB서버 IP or 도메인 설정
set userDBip=192.168.201.67

:: DB 구성 (싱글 / 분할)
:: 1. 싱글 DB 설정 (Default)
set userDB=leedkVDI

:: 2. 분할 DB 설정 
set userSiteDB=CitrixLKVDISite
set userMoDB=CitrixLKVDIMonitoring

:: -----------------

IF EXIST "%ProgramFiles%\Microsoft SQL Server\Client SDK\ODBC\" (
goto main
) ELSE (
 goto install
)
pause

:: 도메인 조인 여부 
:: 로컬 호스트에서 도메인 조인상태에 따라 DB조인 수동입력으로 자동 전환
if %computername%==%userdomain% goto selc1

:install
cls
echo 현재 호스트에 SQL Server ODBC 드라이버 및 SQLCMD유틸이 설치 되어있지 않습니다.
echo.
echo 다음 URL에서 설치 후 진행바랍니다.
echo ODBC 드라이버 : https://docs.microsoft.com/ko-kr/sql/connect/odbc/download-odbc-driver-for-sql-server?view=sql-server-ver15
echo.
echo sqlcmd 유틸 : https://docs.microsoft.com/ko-kr/sql/tools/sqlcmd-utility?view=sql-server-ver15

pause

exit

:main
set seldb=vm
cls
:: echo %salist%
echo DB구성 선택 메뉴
echo Citrix Controller에 설정 된 DB상태가 싱글 상태인지 Site/Monitoring/Logging으로 분할 구성 되어있는지 선택
echo.
echo 1. 싱글 구성    2. 분할 구성   x. 나가기
set /p seldb=입력:

if %seldb%==vm goto derr
if %seldb%==1 set dbcon=1 & goto main2
if %seldb%==2 set dbcon=2 & goto main2
if %seldb%==x exit
if %seldb%==X exit

:derr
echo 범위를 벗어난 입력입니다.
pause
goto main

:main2
set sel=vm
if %dbcon%==1 set bsel=싱글
if %dbcon%==2 set bsel=분할
cls
:: echo %salist%
echo VM UUID,Pool 컨넥션 변경 및 DB 구성 변경 메뉴
echo 옵션 선택
echo.
echo 현재 DB 구성은( %bsel% )방식입니다. 재변경이 필요할 시 C버튼을 클릭하십시오.
echo.
echo 1. VM_UUID 변경    2. VM_POOL컨넥션 변경    3. DB조인 수동입력   c.DB 구성 메뉴로 돌아가기   x. 나가기
set /p sel=입력:

if %sel%==vm goto err
if %sel%==1 goto ch1
if %sel%==2 goto ch2
if %sel%==3 goto selc1
if %sel%==c goto main
if %sel%==C goto main
if %sel%==x exit
if %sel%==X exit

:err
echo 범위를 벗어난 입력입니다.
pause
goto main2

:ch1
:: VM_UUID 교체 스크립트 구간 
cls 
echo 1. VM_UUID 변경
echo.
echo 입력 예시) 07324359-868a-6459-2b7c-21ca8dc1e20a
echo.
echo 현재 VM의 UUID입력
set /p useuuid=입력:

echo.
echo.
echo 교체 VM의 UUID입력
set /p chuuid=입력:

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
if %salist%==1 sqlcmd -S %saip%,%saport% -U %sauser% -P "%sapass%" -i "%TMP%\MCS.sql"

echo.
echo MCS VM이 기존 %useuuid%에서 %chuuid%로 변경되었습니다.

pause

del "%TMP%\MCS.sql"

exit

:ch2
:: Pool 교체 스크립트 구간
cls 
echo 2. VM_POOL컨넥션 변경
echo.
echo 입력 예시) 07324359-868a-6459-2b7c-21ca8dc1e20a
echo.
echo 풀교체 대상 VM의 UUID입력
set /p chuuid=입력:
echo.
echo 선택된 VM에 현재 등록된 하이퍼바이저 Uid확인
if %dbcon%==1 echo SELECT [HypervisorConnectionUid] FROM [%userDB%].[chb_Config].[Workers] where HostedMachineId='%chuuid%' > "%TMP%\vmpool.sql"
if %dbcon%==2 echo SELECT [HypervisorConnectionUid] FROM [%userSiteDB%].[chb_Config].[Workers] where HostedMachineId='%chuuid%' > "%TMP%\vmpool.sql"
if %salist%==0 sqlcmd -E -S %userDBip%,%dbport% -i "%TMP%\vmpool.sql" > "%TMP%\vmpool.log"
if %salist%==1 sqlcmd -S %saip%,%saport% -U %sauser% -P "%sapass%" -i "%TMP%\vmpool.sql" > "%TMP%\vmpool.log"
type "%TMP%\vmpool.log" |findstr /v Hyper |findstr /v "^-" |findstr /v "(" > "%TMP%\script.log"
set /p vmp=<"%TMP%\script.log"

echo 현재 VM에 등록된 하이퍼바이저 Uid번호 는 %vmp: =%번 입니다.
echo.
echo DDC호스팅에 등록된 하이퍼바이저 목록

if %salist%==0 goto ch21 
if %salist%==1 goto ch22 

:ch21
if %dbcon%==1 sqlcmd -S %userDBip%,%dbport% -E -Q "select [DisplayName],[Uid] from [%userDB%].[chb_Config].[HypervisorConnections]"
if %dbcon%==2 sqlcmd -S %userDBip%,%dbport% -E -Q "select [DisplayName],[Uid] from [%userSiteDB%].[chb_Config].[HypervisorConnections]"
goto ch3

:ch22
if %dbcon%==1 sqlcmd -S %saip%,%saport% -U %sauser% -P "%sapass%" -Q "select [DisplayName],[Uid] from [%userDB%].[chb_Config].[HypervisorConnections]"
if %dbcon%==2 sqlcmd -S %saip%,%saport% -U %sauser% -P "%sapass%" -Q "select [DisplayName],[Uid] from [%userSiteDB%].[chb_Config].[HypervisorConnections]"
goto ch3

:ch3
echo 화면에 표시된 교체 진행 할 하이퍼바이저 Uid번호 지정하기
echo.
set /p poolin=입력:

echo SET QUOTED_IDENTIFIER ON > "%TMP%\Pool.sql"
echo. >> "%TMP%\Pool.sql"
echo GO >> "%TMP%\Pool.sql"
echo. >> "%TMP%\Pool.sql"
echo. >> "%TMP%\Pool.sql"
if %dbcon%==1 echo UPDATE [%userDB%].[chb_Config].[Workers] >> "%TMP%\Pool.sql"
if %dbcon%==2 echo UPDATE [%userSiteDB%].[chb_Config].[Workers] >> "%TMP%\Pool.sql"
echo SET HypervisorConnectionUid = '%poolin%' >> "%TMP%\Pool.sql"
echo WHERE HostedMachineId = '%chuuid%' >> "%TMP%\Pool.sql"
echo. >> "%TMP%\Pool.sql"
echo.

if %salist%==0 sqlcmd -E -S %userDBip%,%dbport% -i "%TMP%\Pool.sql"
if %salist%==1 sqlcmd -S %saip%,%saport% -U %sauser% -P "%sapass%" -i "%TMP%\Pool.sql"

echo %vmp: =%번에서 %poolin%번 풀 변경 완료!

pause 

del "%TMP%\*.sql" "%TMP%\*.log"

exit
:selc1
cls
set salist=1
set sauser=sa
set dbport=1433
if %dbcon%==2 goto selc2
echo DB서버 조인 수동입력
echo.
echo 1.DB서버IP 입력
set /p saip=입력:
echo.
echo 2.DB서버Port 입력
echo 입력안하고 넘어갈 시 기본 1433포트로 자동 입력
set /p saport=입력:
echo.
echo 3.DB user 입력 
echo 입력안하고 넘어갈 시 sa계정으로 자동 입력
set /p sauser=입력:
echo.
echo 4.DB %sauser% 계정 패스워드 입력
set /p sapass=입력:
echo.
echo 5.CVAD DB명 입력
set /p userDB=입력:
echo.
goto main2

:selc2
cls
echo DB서버 조인 수동입력
echo.
echo 1.DB서버IP 입력
set /p saip=입력:
echo.
echo 2.DB서버Port 입력
echo 입력안하고 넘어갈 시 기본 1433포트로 자동 입력
set /p saport=입력:
echo.
echo 3.DB user 입력 
echo 입력안하고 넘어갈 시 sa계정으로 자동 입력
set /p sauser=입력:
echo.
echo 4.DB %sauser% 계정 패스워드 입력
set /p sapass=입력:
echo.
echo 5.CVAD DB Site명 입력
set /p userSiteDB=입력:
echo.
echo 6.CVAD DB Monitor명 입력
set /p userMoDB=입력:
goto main2

