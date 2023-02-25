@echo off 
del "%TMP%\*.sql" "%TMP%\*.log" >nul
echo Citrix CVAD VDI UUID Changer v1.2.1 Beta
title Citrix CVAD VDI UUID Changer v1.2.1 Beta
set salist=0
:: Citrix MCS VM UUID변경 툴

IF EXIST config.conf (
goto ODBC
) ELSE (
 goto input
)
:: pause

:input
cls
if %computername%==%userdomain% goto main
set indb=x
set dbport=1433
echo MVC 초기구성 Config 구성 
echo 구성 완료 시 MVC.bat 경로에 Config.conf 파일 생성
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
:: DB 싱글 및 분할 구성 선택
:main
set seldb=vm
echo.
:: echo %salist%
echo 3. DB구성 선택 메뉴
echo Citrix Controller에 설정 된 DB상태가 싱글 상태인지 Site/Monitoring/Logging으로 분할 구성 되어있는지 선택
echo.
echo 1. 싱글 구성    2. 분할 구성   x. 나가기  c.다시 입력
set /p seldb=입력:

if %seldb%==vm goto derr
if %seldb%==1 set dbcon=1 & goto input1
if %seldb%==2 set dbcon=2 & goto input2
if %seldb%==x exit
if %seldb%==X exit
if %seldb%==c goto input
if %seldb%==C goto input

:derr
echo 범위를 벗어난 입력입니다.
echo 잘못된 값으로 처음 화면으로 다시 돌아갑니다.
pause
goto input

:input1
:: 도메인 조인 여부 
:: 로컬 호스트에서 도메인 조인상태에 따라 DB조인 수동입력으로 자동 전환
if %computername%==%userdomain% goto selc1
:: DB 구성 (싱글 / 분할)
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
set /p userSiteDB=입력:
set /p userMoDB=입력:

:input3
if %dbcon%==1 set singleDB=Enable
if %dbcon%==2 set singleDB=Disable
echo userDBip= %userDBip% > config.conf
echo dbport= %dbport% >> config.conf
echo userDB= %userDB% >> config.conf
echo singleDB= %singleDB% >> config.conf
echo userSiteDB= %userSiteDB% >> config.conf
echo userMoDB= %userMoDB% >> config.conf
echo.
goto ODBC


:ODBC
IF EXIST "%ProgramFiles%\Microsoft SQL Server\Client SDK\ODBC\" (
goto confdb
) ELSE (
 goto install
)
pause



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

:confdb
for /f "tokens=2" %%i in ('findstr "userDBip" config.conf') do set userDBip=%%i
for /f "tokens=2" %%i in ('findstr "dbport" config.conf') do set dbport=%%i
for /f "tokens=2" %%i in ('findstr "userDB" config.conf') do set userDB=%%i
for /f "tokens=2" %%i in ('findstr "singleDB" config.conf') do set singleDB=%%i
for /f "tokens=2" %%i in ('findstr "userSiteDB" config.conf') do set userSiteDB=%%i
for /f "tokens=2" %%i in ('findstr "userMoDB" config.conf') do set userMoDB=%%i


:main2
if %singleDB%==Enable set dbcon=1
if %singleDB%==Disable set dbcon=2
set sel=vm
if %dbcon%==1 set bsel=싱글
if %dbcon%==2 set bsel=분할
if %salist%==0 set dbuserauto=자동
if %salist%==1 set dbuserauto=수동
cls
:: echo %salist%
echo VM UUID,Pool 컨넥션 변경 및 DB 구성 변경 메뉴
echo 옵션 선택
echo.
echo 현재 DB 구성은( %bsel% )방식입니다. 
echo DB 계정 구성은 ( %dbuserauto% ) 방식입니다.
echo.
echo.
echo 1. VM_UUID 변경    
echo 2. VM_POOL컨넥션 변경  
echo 3. Catalog Master VM 교체  
echo 4. DB조인 수동입력    
echo x. 나가기
echo.
set /p sel=입력:

if %sel%==vm goto err
if %sel%==1 goto ch1
if %sel%==2 goto ch2
if %sel%==3 goto ch4
if %sel%==4 goto selc1
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
if %dbcon%==1 sqlcmd -S %userDBip%,%dbport% -E -Q "select substring (DisplayName,0,30) AS HyperVisorName,[Uid] from [%userDB%].[chb_Config].[HypervisorConnections]"
if %dbcon%==2 sqlcmd -S %userDBip%,%dbport% -E -Q "select substring (DisplayName,0,30) AS HyperVisorName,[Uid] from [%userSiteDB%].[chb_Config].[HypervisorConnections]"
goto ch3

:ch22
if %dbcon%==1 sqlcmd -S %saip%,%saport% -U %sauser% -P "%sapass%" -Q "select substring (DisplayName,0,30) AS HyperVisorName,[Uid] from [%userDB%].[chb_Config].[HypervisorConnections]"
if %dbcon%==2 sqlcmd -S %saip%,%saport% -U %sauser% -P "%sapass%" -Q "select substring (DisplayName,0,30) AS HyperVisorName,[Uid] from [%userSiteDB%].[chb_Config].[HypervisorConnections]"
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


:ch4
:: Catalog Master VM 교체 스크립트 구간
cls 
echo 3. Catalog Master VM 교체
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
echo.
echo 바꿔치기 할 카탈로그네임 입력
set /p chctl=입력:
echo.

::sqlcmd -S 192.168.201.67,1433 -E -Q "select substring (CatalogName,0,20) AS CatalogName,[ProvisioningSchemeId] AS ProvisioningUid,[HypervisorConnectionUid] AS Hypervisor from [leedkVDI].[chb_Config].[Catalogs]"


if %salist%==0 goto ch41
if %salist%==1 goto ch42

:mokrokc1
if %dbcon%==1 sqlcmd -S %userDBip%,%dbport% -E -Q "select substring (CatalogName,0,20) AS CatalogName,[ProvisioningSchemeId],substring (A.DisplayName,0,20) AS HypervisorName FROM [%userDB%].[chb_Config].[HypervisorConnections] A LEFT OUTER JOIN [%userDB%].[chb_Config].[Catalogs]  B ON A.Uid = B.HypervisorConnectionUid;"
if %dbcon%==2 sqlcmd -S %userDBip%,%dbport% -E -Q "select substring (CatalogName,0,20) AS CatalogName,[ProvisioningSchemeId],substring (A.DisplayName,0,20) AS HypervisorName FROM [%userSiteDB%].[chb_Config].[HypervisorConnections] A LEFT OUTER JOIN [%userSiteDB%].[chb_Config].[Catalogs]  B ON A.Uid = B.HypervisorConnectionUid;"
goto iprueck

:mokrokc2
if %dbcon%==1 sqlcmd -S %saip%,%saport% -U %sauser% -P "%sapass%" -Q "select substring (CatalogName,0,20) AS CatalogName,[ProvisioningSchemeId],substring (A.DisplayName,0,20) AS HypervisorName FROM [%userDB%].[chb_Config].[HypervisorConnections] A LEFT OUTER JOIN [%userDB%].[chb_Config].[Catalogs]  B ON A.Uid = B.HypervisorConnectionUid;"
if %dbcon%==2 sqlcmd -S %saip%,%saport% -U %sauser% -P "%sapass%" -Q "select substring (CatalogName,0,20) AS CatalogName,[ProvisioningSchemeId],substring (A.DisplayName,0,20) AS HypervisorName FROM [%userSiteDB%].[chb_Config].[HypervisorConnections] A LEFT OUTER JOIN [%userSiteDB%].[chb_Config].[Catalogs]  B ON A.Uid = B.HypervisorConnectionUid;"
goto iprueck

:ch41
if %dbcon%==1 sqlcmd -S %userDBip%,%dbport% -E -Q "select [ProvisioningSchemeId] From [%userDB%].[chb_Config].[Catalogs] where [CatalogName] like '%ctl%'" |more +2 > "%TMP%\ctluuid.log"
if %dbcon%==2 sqlcmd -S %userDBip%,%dbport% -E -Q "select [ProvisioningSchemeId] From [%userSiteDB%].[chb_Config].[Catalogs] where [CatalogName] like '%ctl%'" |more +2 > "%TMP%\ctluuid.log"
set /p ProvSID=<"%TMP%\ctluuid.log"

if %dbcon%==1 sqlcmd -S %userDBip%,%dbport% -E -Q "select [ProvisioningSchemeId] From [%userDB%].[chb_Config].[Catalogs] where [CatalogName] like '%chctl%'" |more +2 > "%TMP%\chctluuid.log"
if %dbcon%==2 sqlcmd -S %userDBip%,%dbport% -E -Q "select [ProvisioningSchemeId] From [%userSiteDB%].[chb_Config].[Catalogs] where [CatalogName] like '%chctl%'" |more +2 > "%TMP%\chctluuid.log"
set /p chProvSID=<"%TMP%\chctluuid.log"

if %dbcon%==1 sqlcmd -S %userDBip%,%dbport% -E -Q "select [HypervisorConnectionUid] From [%userDB%].[chb_Config].[Catalogs] where [CatalogName] like '%ctl%'" |more +2 > "%TMP%\hypuuid.log"
if %dbcon%==2 sqlcmd -S %userDBip%,%dbport% -E -Q "select [HypervisorConnectionUid] From [%userSiteDB%].[chb_Config].[Catalogs] where [CatalogName] like '%ctl%'" |more +2 > "%TMP%\hypuuid.log"
set /p HypUID=<"%TMP%\hypuuid.log"

if %dbcon%==1 sqlcmd -S %userDBip%,%dbport% -E -Q "select [HypervisorConnectionUid] From [%userDB%].[chb_Config].[Catalogs] where [CatalogName] like '%chctl%'" |more +2 > "%TMP%\chhypuuid.log"
if %dbcon%==2 sqlcmd -S %userDBip%,%dbport% -E -Q "select [HypervisorConnectionUid] From [%userSiteDB%].[chb_Config].[Catalogs] where [CatalogName] like '%chctl%'" |more +2 > "%TMP%\chhypuuid.log"
set /p chHypUID=<"%TMP%\chhypuuid.log"

goto ch5

:ch42
if %dbcon%==1 sqlcmd -S %saip%,%saport% -U %sauser% -P "%sapass%" -Q "select [ProvisioningSchemeId] From [%userDB%].[chb_Config].[Catalogs] where [CatalogName] like '%ctl%'" |more +2 > "%TMP%\ctluuid.log"
if %dbcon%==2 sqlcmd -S %saip%,%saport% -U %sauser% -P "%sapass%" -Q "select [ProvisioningSchemeId] From [%userSiteDB%].[chb_Config].[Catalogs] where [CatalogName] like '%ctl%'" |more +2 > "%TMP%\ctluuid.log"
set /p ProvSID=<"%TMP%\ctluuid.log"

if %dbcon%==1 sqlcmd -S %saip%,%saport% -U %sauser% -P "%sapass%" -Q "select [ProvisioningSchemeId] From [%userDB%].[chb_Config].[Catalogs] where [CatalogName] like '%chctl%'" |more +2 > "%TMP%\chctluuid.log"
if %dbcon%==2 sqlcmd -S %saip%,%saport% -U %sauser% -P "%sapass%" -Q "select [ProvisioningSchemeId] From [%userSiteDB%].[chb_Config].[Catalogs] where [CatalogName] like '%chctl%'" |more +2 > "%TMP%\chctluuid.log"
set /p chProvSID=<"%TMP%\chctluuid.log"

if %dbcon%==1 sqlcmd -S %saip%,%saport% -U %sauser% -P "%sapass%" -Q "select [HypervisorConnectionUid] From [%userDB%].[chb_Config].[Catalogs] where [CatalogName] like '%ctl%'" |more +2 > "%TMP%\hypuuid.log"
if %dbcon%==2 sqlcmd -S %saip%,%saport% -U %sauser% -P "%sapass%" -Q "select [HypervisorConnectionUid] From [%userSiteDB%].[chb_Config].[Catalogs] where [CatalogName] like '%ctl%'" |more +2 > "%TMP%\hypuuid.log"
set /p HypUID=<"%TMP%\hypuuid.log"

if %dbcon%==1 sqlcmd -S %saip%,%saport% -U %sauser% -P "%sapass%" -Q "select [HypervisorConnectionUid] From [%userDB%].[chb_Config].[Catalogs] where [CatalogName] like '%chctl%'" |more +2 > "%TMP%\chhypuuid.log"
if %dbcon%==2 sqlcmd -S %saip%,%saport% -U %sauser% -P "%sapass%" -Q "select [HypervisorConnectionUid] From [%userSiteDB%].[chb_Config].[Catalogs] where [CatalogName] like '%chctl%'" |more +2 > "%TMP%\chhypuuid.log"
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
echo WHERE [CatalogName] = '%ctl%' >> "%TMP%\MasterVM.sql"

echo UPDATE [%userDB%].[chb_Config].[Catalogs] >> "%TMP%\MasterVM.sql"
echo SET HypervisorConnectionUid = '%chHypUID%' >> "%TMP%\MasterVM.sql"
echo WHERE [CatalogName] = '%ctl%' >> "%TMP%\MasterVM.sql"

echo UPDATE [%userDB%].[chb_Config].[Catalogs] >> "%TMP%\MasterVM.sql"
echo SET ProvisioningSchemeId = '%ProvSID%' >> "%TMP%\MasterVM.sql"
echo WHERE [CatalogName] = '%chctl%' >> "%TMP%\MasterVM.sql"

echo UPDATE [%userDB%].[chb_Config].[Catalogs] >> "%TMP%\MasterVM.sql"
echo SET HypervisorConnectionUid = '%HypUID%' >> "%TMP%\MasterVM.sql"
echo WHERE [CatalogName] = '%chctl%' >> "%TMP%\MasterVM.sql"

goto ch53

:ch52
echo UPDATE [%userSiteDB%].[chb_Config].[Catalogs] >> "%TMP%\MasterVM.sql"
echo SET ProvisioningSchemeId = '%chProvSID%' >> "%TMP%\MasterVM.sql"
echo WHERE [CatalogName] = '%ctl%' >> "%TMP%\MasterVM.sql"

echo UPDATE [%userSiteDB%].[chb_Config].[Catalogs] >> "%TMP%\MasterVM.sql"
echo SET HypervisorConnectionUid = '%chHypUID%' >> "%TMP%\MasterVM.sql"
echo WHERE [CatalogName] = '%ctl%' >> "%TMP%\MasterVM.sql"

echo UPDATE [%userSiteDB%].[chb_Config].[Catalogs] >> "%TMP%\MasterVM.sql"
echo SET ProvisioningSchemeId = '%ProvSID%' >> "%TMP%\MasterVM.sql"
echo WHERE [CatalogName] = '%chctl%' >> "%TMP%\MasterVM.sql"

echo UPDATE [%userSiteDB%].[chb_Config].[Catalogs] >> "%TMP%\MasterVM.sql"
echo SET HypervisorConnectionUid = '%HypUID%' >> "%TMP%\MasterVM.sql"
echo WHERE [CatalogName] = '%chctl%' >> "%TMP%\MasterVM.sql"

:ch53
echo. >> "%TMP%\MasterVM.sql"
echo.

if %salist%==0 sqlcmd -E -S %userDBip%,%dbport% -i "%TMP%\MasterVM.sql"
if %salist%==1 sqlcmd -S %saip%,%saport% -U %sauser% -P "%sapass%" -i "%TMP%\MasterVM.sql"

:: cls
echo 마스터 VM 변경 완료!
echo.
echo 변경된 항목 출력

if %salist%==0 goto ch54
if %salist%==1 goto ch55

:ch54
if %dbcon%==1 sqlcmd -S %userDBip%,%dbport% -E -Q "select substring (CatalogName,0,20) AS CatalogName,[ProvisioningSchemeId],substring (A.DisplayName,0,20) AS HypervisorName FROM [%userDB%].[chb_Config].[HypervisorConnections] A LEFT OUTER JOIN [%userDB%].[chb_Config].[Catalogs]  B ON A.Uid = B.HypervisorConnectionUid;"
if %dbcon%==2 sqlcmd -S %userDBip%,%dbport% -E -Q "select substring (CatalogName,0,20) AS CatalogName,[ProvisioningSchemeId],substring (A.DisplayName,0,20) AS HypervisorName FROM [%userSiteDB%].[chb_Config].[HypervisorConnections] A LEFT OUTER JOIN [%userSiteDB%].[chb_Config].[Catalogs]  B ON A.Uid = B.HypervisorConnectionUid;"

goto ch56

:ch55
if %dbcon%==1 sqlcmd -S %saip%,%saport% -U %sauser% -P "%sapass%" -Q "select substring (CatalogName,0,20) AS CatalogName,[ProvisioningSchemeId],substring (A.DisplayName,0,20) AS HypervisorName FROM [%userDB%].[chb_Config].[HypervisorConnections] A LEFT OUTER JOIN [%userDB%].[chb_Config].[Catalogs]  B ON A.Uid = B.HypervisorConnectionUid;"
if %dbcon%==2 sqlcmd -S %saip%,%saport% -U %sauser% -P "%sapass%" -Q "select substring (CatalogName,0,20) AS CatalogName,[ProvisioningSchemeId],substring (A.DisplayName,0,20) AS HypervisorName FROM [%userSiteDB%].[chb_Config].[HypervisorConnections] A LEFT OUTER JOIN [%userSiteDB%].[chb_Config].[Catalogs]  B ON A.Uid = B.HypervisorConnectionUid;"

:ch56
pause 

del "%TMP%\*.sql" "%TMP%\*.log"

exit


:selc1
setlocal enabledelayedexpansion
cls
if %dbcon%==1 set singleDB=Enable
set salist=1
set sauser=sa
set saport=1433
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
echo 3.CVAD DB명 입력
set /p userDB=입력:
echo.
echo 4.DB user 입력 
echo 입력안하고 넘어갈 시 sa계정으로 자동 입력
set /p sauser=입력:
echo.
echo 5.DB %sauser% 계정 패스워드 입력
call :getPassword usersapass "입력: "
echo.

:selc2
cls
if %dbcon%==2 set singleDB=Disable
echo DB서버 조인 수동입력
echo.
echo 1.DB서버IP 입력
set /p saip=입력:
echo.
echo 2.DB서버Port 입력
echo 입력안하고 넘어갈 시 기본 1433포트로 자동 입력
set /p saport=입력:
echo.
echo 3.CVAD DB Site명 입력
set /p userSiteDB=입력:
echo.
echo 4.CVAD DB Monitor명 입력
set /p userMoDB=입력:
echo.
echo 5.DB user 입력 
echo 입력안하고 넘어갈 시 sa계정으로 자동 입력
set /p sauser=입력:
echo.
echo 6.DB %sauser% 계정 패스워드 입력
call :getPassword usersapass "입력: "
echo.


:getPassword
set "sapass="

for /f %%a in ('"prompt;$H&for %%b in (0) do rem"') do set "BS=%%a"


set /p "=%~2" <nul 

:keyLoop
set "key="
for /f "delims=" %%a in ('xcopy /l /w "%~f0" "%~f0" 2^>nul') do if not defined key set "key=%%a"
set "key=%key:~-1%"

if defined key (
    if "%key%"=="%BS%" (
        if defined sapass (
            set "sapass=%sapass:~0,-1%"
            set /p "=!BS! !BS!"<nul
        )
    ) else (
        set "sapass=%sapass%%key%"
        set /p "="<nul
    )
    goto :keyLoop
)
echo/

set "%~1=%sapass%"
goto main2
