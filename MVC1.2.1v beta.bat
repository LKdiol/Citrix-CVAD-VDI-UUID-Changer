@echo off 
del "%TMP%\*.sql" "%TMP%\*.log" >nul
echo MCS VM Changer v1.2.1 Beta
title MCS VM Changer v1.2.1 Beta
set salist=0
:: Citrix MCS VM UUID���� ��

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
echo MVC �ʱⱸ�� Config ���� 
echo ���� �Ϸ� �� MVC.bat ��ο� Config.conf ���� ����
echo.
:: config ���� ------

:: DB���� IP or ������ ����
echo 1.DB���� IP �Է�
set /p userDBip=�Է�:
echo.
:: DB���� ��Ʈ ����
echo 2.DB����Port �Է�
echo �Է¾��ϰ� �Ѿ �� �⺻ 1433��Ʈ�� �ڵ� �Է�
set /p dbport=�Է�:
echo.
:: DB �̱� �� ���� ���� ����
:main
set seldb=vm
echo.
:: echo %salist%
echo 3. DB���� ���� �޴�
echo Citrix Controller�� ���� �� DB���°� �̱� �������� Site/Monitoring/Logging���� ���� ���� �Ǿ��ִ��� ����
echo.
echo 1. �̱� ����    2. ���� ����   x. ������  c.�ٽ� �Է�
set /p seldb=�Է�:

if %seldb%==vm goto derr
if %seldb%==1 set dbcon=1 & goto input1
if %seldb%==2 set dbcon=2 & goto input2
if %seldb%==x exit
if %seldb%==X exit
if %seldb%==c goto input
if %seldb%==C goto input

:derr
echo ������ ��� �Է��Դϴ�.
echo �߸��� ������ ó�� ȭ������ �ٽ� ���ư��ϴ�.
pause
goto input

:input1
:: ������ ���� ���� 
:: ���� ȣ��Ʈ���� ������ ���λ��¿� ���� DB���� �����Է����� �ڵ� ��ȯ
if %computername%==%userdomain% goto selc1
:: DB ���� (�̱� / ����)
echo.
echo 3-1. �̱� DB ����
set /p userDB=�Է�:
set userSiteDB=null
set userMoDB=null
goto input3

:input2
:: ������ ���� ���� 
:: ���� ȣ��Ʈ���� ������ ���λ��¿� ���� DB���� �����Է����� �ڵ� ��ȯ
if %computername%==%userdomain% goto selc1
echo 3-2. ���� DB ���� 
set /p userSiteDB=�Է�:
set /p userMoDB=�Է�:

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
echo ���� ȣ��Ʈ�� SQL Server ODBC ����̹� �� SQLCMD��ƿ�� ��ġ �Ǿ����� �ʽ��ϴ�.
echo.
echo ���� URL���� ��ġ �� ����ٶ��ϴ�.
echo ODBC ����̹� : https://docs.microsoft.com/ko-kr/sql/connect/odbc/download-odbc-driver-for-sql-server?view=sql-server-ver15
echo.
echo sqlcmd ��ƿ : https://docs.microsoft.com/ko-kr/sql/tools/sqlcmd-utility?view=sql-server-ver15

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
if %dbcon%==1 set bsel=�̱�
if %dbcon%==2 set bsel=����
if %salist%==0 set dbuserauto=�ڵ�
if %salist%==1 set dbuserauto=����
cls
:: echo %salist%
echo VM UUID,Pool ���ؼ� ���� �� DB ���� ���� �޴�
echo �ɼ� ����
echo.
echo ���� DB ������( %bsel% )����Դϴ�. 
echo DB ���� ������ ( %dbuserauto% ) ����Դϴ�.
echo.
echo.
echo 1. VM_UUID ����    
echo 2. VM_POOL���ؼ� ����  
echo 3. Catalog Master VM ��ü  
echo 4. DB���� �����Է�    
echo x. ������
echo.
set /p sel=�Է�:

if %sel%==vm goto err
if %sel%==1 goto ch1
if %sel%==2 goto ch2
if %sel%==3 goto ch4
if %sel%==4 goto selc1
if %sel%==x exit
if %sel%==X exit

:err
echo ������ ��� �Է��Դϴ�.
pause
goto main2

:ch1
:: VM_UUID ��ü ��ũ��Ʈ ���� 
cls 
echo 1. VM_UUID ����
echo.
echo �Է� ����) 07324359-868a-6459-2b7c-21ca8dc1e20a
echo.
echo ���� VM�� UUID�Է�
set /p useuuid=�Է�:

echo.
echo.
echo ��ü VM�� UUID�Է�
set /p chuuid=�Է�:

echo SET QUOTED_IDENTIFIER ON > "%TMP%\MCS.sql"
echo. >> "%TMP%\MCS.sql"
echo GO >> "%TMP%\MCS.sql"
echo. >> "%TMP%\MCS.sql"
:: Monitoring DB ���� ����
if %dbcon%==1 echo UPDATE [%userDB%].[MonitorData].[Machine] >> "%TMP%\MCS.sql"
if %dbcon%==2 echo UPDATE [%userMoDB%].[MonitorData].[Machine] >> "%TMP%\MCS.sql"
echo SET HostedMachineId = '%chuuid%' >> "%TMP%\MCS.sql"
echo WHERE HostedMachineId = '%useuuid%' >> "%TMP%\MCS.sql"
echo. >> "%TMP%\MCS.sql"

:: Site DB ���� ����
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
echo MCS VM�� ���� %useuuid%���� %chuuid%�� ����Ǿ����ϴ�.

pause

del "%TMP%\MCS.sql"

exit

:ch2
:: Pool ��ü ��ũ��Ʈ ����
cls 
echo 2. VM_POOL���ؼ� ����
echo.
echo �Է� ����) 07324359-868a-6459-2b7c-21ca8dc1e20a
echo.
echo Ǯ��ü ��� VM�� UUID�Է�
set /p chuuid=�Է�:
echo.
echo ���õ� VM�� ���� ��ϵ� �����۹����� UidȮ��
if %dbcon%==1 echo SELECT [HypervisorConnectionUid] FROM [%userDB%].[chb_Config].[Workers] where HostedMachineId='%chuuid%' > "%TMP%\vmpool.sql"
if %dbcon%==2 echo SELECT [HypervisorConnectionUid] FROM [%userSiteDB%].[chb_Config].[Workers] where HostedMachineId='%chuuid%' > "%TMP%\vmpool.sql"
if %salist%==0 sqlcmd -E -S %userDBip%,%dbport% -i "%TMP%\vmpool.sql" > "%TMP%\vmpool.log"
if %salist%==1 sqlcmd -S %saip%,%saport% -U %sauser% -P "%sapass%" -i "%TMP%\vmpool.sql" > "%TMP%\vmpool.log"
type "%TMP%\vmpool.log" |findstr /v Hyper |findstr /v "^-" |findstr /v "(" > "%TMP%\script.log"
set /p vmp=<"%TMP%\script.log"

echo ���� VM�� ��ϵ� �����۹����� Uid��ȣ �� %vmp: =%�� �Դϴ�.
echo.
echo DDCȣ���ÿ� ��ϵ� �����۹����� ���

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
echo ȭ�鿡 ǥ�õ� ��ü ���� �� �����۹����� Uid��ȣ �����ϱ�
echo.
set /p poolin=�Է�:

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

echo %vmp: =%������ %poolin%�� Ǯ ���� �Ϸ�!

pause 

del "%TMP%\*.sql" "%TMP%\*.log"

exit


:ch4
:: Catalog Master VM ��ü ��ũ��Ʈ ����
cls 
echo 3. Catalog Master VM ��ü
echo.
echo ##����
echo 1) ���� �� �ٲ�ġ�� �� MCS Catalog ���� �� ����
echo 2) ����� īŻ�α� Name �Է� �� �ٲ�ġ���� īŻ�α� Name �Է�
echo.
echo īŻ�α׿� ��ϵ� ������ VM UUID �� �����۹����� Uid ��� Ȯ��
if %salist%==0 goto mokrokc1
if %salist%==1 goto mokrokc2
:iprueck
echo.
echo ��� īŻ�α׳��� �Է�
set /p ctl=�Է�:
echo.
echo �ٲ�ġ�� �� īŻ�α׳��� �Է�
set /p chctl=�Է�:
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
echo ������ VM ���� �Ϸ�!
echo.
echo ����� �׸� ���

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
echo DB���� ���� �����Է�
echo.
echo 1.DB����IP �Է�
set /p saip=�Է�:
echo.
echo 2.DB����Port �Է�
echo �Է¾��ϰ� �Ѿ �� �⺻ 1433��Ʈ�� �ڵ� �Է�
set /p saport=�Է�:
echo.
echo 3.CVAD DB�� �Է�
set /p userDB=�Է�:
echo.
echo 4.DB user �Է� 
echo �Է¾��ϰ� �Ѿ �� sa�������� �ڵ� �Է�
set /p sauser=�Է�:
echo.
echo 5.DB %sauser% ���� �н����� �Է�
call :getPassword usersapass "�Է�: "
echo.

:selc2
cls
if %dbcon%==2 set singleDB=Disable
echo DB���� ���� �����Է�
echo.
echo 1.DB����IP �Է�
set /p saip=�Է�:
echo.
echo 2.DB����Port �Է�
echo �Է¾��ϰ� �Ѿ �� �⺻ 1433��Ʈ�� �ڵ� �Է�
set /p saport=�Է�:
echo.
echo 3.CVAD DB Site�� �Է�
set /p userSiteDB=�Է�:
echo.
echo 4.CVAD DB Monitor�� �Է�
set /p userMoDB=�Է�:
echo.
echo 5.DB user �Է� 
echo �Է¾��ϰ� �Ѿ �� sa�������� �ڵ� �Է�
set /p sauser=�Է�:
echo.
echo 6.DB %sauser% ���� �н����� �Է�
call :getPassword usersapass "�Է�: "
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