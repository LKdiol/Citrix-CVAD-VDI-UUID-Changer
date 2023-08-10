@echo off 
setlocal enabledelayedexpansion
del "%TMP%\*.sql" "%TMP%\*.log" >nul 2>&1
set seldb=vm
echo Citrix CVAD VDI UUID Changer v1.3.2
echo �������� 2023-08-03
title Citrix CVAD VDI UUID Changer v1.3.2
set location=%~dp0
cd %location%
:: ������� 0�̸� AD������ ����, 1�̸� SQL Server ����
set salist=0
:: Citrix MCS VM UUID���� ��

::��� �ɼ��� �⺻ �ɼ���'1' (1�� Ȱ��ȭ 0�� ��Ȱ��ȭ)
set bkoption=1

:: bin ���� ����
IF EXIST bin (
goto mvcconfig
) ELSE (
 goto notbin
)

:notbin
echo.
echo bin ������ �������� �ʽ��ϴ�. 
echo ����� ��ο��� bin���� ������ �ʾҴ��� �ٽ��ѹ� Ȯ�����ּ���. 
pause 
exit

:mvcconfig
:: config ���� ����
IF EXIST config.conf (
goto ODBC
) ELSE (
 goto main
)
:: pause


:input
cls
set dbport=1433
echo CitrixCVUC �ʱⱸ�� Config ���� 
echo ���� �Ϸ� �� CitrixCVUC.bat ��ο� Config.conf ���� ����
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
if %seldb%==vm goto main
if %seldb%==1 set dbcon=1 & goto input1
if %seldb%==2 set dbcon=1 & goto selc1
if %seldb%==3 set dbcon=2 & goto input2
if %seldb%==4 set dbcon=2 & goto selc1

:: DB �̱� �� ���� ���� ����
:main
set seldb=vm
echo.
:: echo %salist%
echo ## DB�������� ���� �޴�
echo.
echo 1) DB ������ AD������ �� SQL Server ������ ���� �� �� �ֽ��ϴ�.
echo   -- ������ ������ �ƴ� ȣ��Ʈ������ AD������ ������ �ص� �ڵ����� SQL Server �������� ����
echo 2) Citrix Controller�� ���� �� DB���°� �̱� �������� Site/Monitoring/Logging���� ���� ���� �Ǿ��ִ��� ����
echo.
echo 1. �̱� ���� (AD����������)
echo 2. �̱� ���� (SQL Server ����)
echo 3. ���� ���� (AD����������)
echo 4. ���� ���� (SQL Server ����)
echo.
echo x. ������  
echo c.���� �޴�
echo.
set /p seldb=�Է�:

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
echo ������ ��� �Է��Դϴ�.
echo �߸��� ������ ó�� ȭ������ �ٽ� ���ư��ϴ�.
pause
goto input

:: DB ���� (�̱� / ����)
:input1
:: ������ ���� ���� 
:: ���� ȣ��Ʈ���� ������ ���λ��¿� ���� DB���� �����Է����� �ڵ� ��ȯ
if %computername%==%userdomain% goto selc1

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
echo 1. CVAD DB Site�� �Է�
set /p userSiteDB=�Է�:
echo.
echo 2. CVAD DB Monitor�� �Է�
set /p userMoDB=�Է�:

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
::������ ���� Ȯ��
bcdedit >nul 2>&1
if not %errorlevel%==0 goto Adminstart
goto sqlcmdisntall
:Adminstart
cls
echo.
timeout 1 >nul
echo.
::������ ���� VBS ����
echo Set UAC = CreateObject^("Shell.Application"^) > "%TMP%\mvcadmin.vbs"
echo UAC.ShellExecute "cmd", "/c """"%~f0"" """ + Wscript.Arguments.Item(0) + """ ""%user%""""", "%CD%", "runas", 1 >> "%TMP%\mvcadmin.vbs"
"%TMP%\mvcadmin.vbs" "%file%"

::������ ���� �Ϸ� �� VBS���� ����
del "%TMP%\mvcadmin.vbs"
exit /b

:sqlcmdisntall
cd %location%
cls
echo.
echo SQLCMD �� ODBC �̼�ġ�� �ڵ� �������Դϴ�. ��ø� ��ٷ� �ּ���
echo ������ %%00
timeout /t 2 /nobreak >nul 2>&1
if %PROCESSOR_ARCHITECTURE%==x86 goto install32
:: msiexec /quiet /passive /qn /i "bin\vcredist\x64\vc_runtimeAdditional_x64.msi"
timeout /t 2 /nobreak >nul 2>&1
cls
echo.
echo SQLCMD �� ODBC �̼�ġ�� �ڵ� �������Դϴ�. ��ø� ��ٷ� �ּ���
echo ������ %%35
:: msiexec /quiet /passive /qn /i "bin\vcredist\x64\vc_runtimeMinimum_x64.msi"
timeout /t 2 /nobreak >nul 2>&1
cls
echo.
echo SQLCMD �� ODBC �̼�ġ�� �ڵ� �������Դϴ�. ��ø� ��ٷ� �ּ���
echo ������ %%55
msiexec /quiet /passive /qn /i "bin\odbc_x64.msi" IACCEPTMSODBCSQLLICENSETERMS=YES 
cls
echo.
echo SQLCMD �� ODBC �̼�ġ�� �ڵ� �������Դϴ�. ��ø� ��ٷ� �ּ���
echo ������ %%75
timeout /t 5 /nobreak >nul 2>&1
cls
echo.
echo SQLCMD �� ODBC �̼�ġ�� �ڵ� �������Դϴ�. ��ø� ��ٷ� �ּ���
echo ����Ϸ�! %%100
msiexec /quiet /passive /qn /i "bin\MsSqlCmdLnUtils_x64.msi" IACCEPTMSSQLCMDLNUTILSLICENSETERMS=YES
echo.
echo.
echo ��� �� CitrixCVUC���� ����� �˴ϴ�.
timeout /t 5 /nobreak 
echo.
set Path=%Path%;%ProgramFiles%\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn
goto confdb

:install32
:: msiexec /quiet /passive /qn /i "bin\vcredist\x86\vc_runtimeAdditional_x86.msi"
cls
echo.
echo SQLCMD �� ODBC �̼�ġ�� �ڵ� �������Դϴ�. ��ø� ��ٷ� �ּ���
echo ������ %%35
timeout /t 2 /nobreak >nul 2>&1
:: msiexec /quiet /passive /qn /i "bin\vcredist\x86\vc_runtimeMinimum_x86.msi"
timeout /t 2 /nobreak >nul 2>&1
cls
echo.
echo SQLCMD �� ODBC �̼�ġ�� �ڵ� �������Դϴ�. ��ø� ��ٷ� �ּ���
echo ������ %%55
msiexec /quiet /passive /qn /i "bin\odbc_x32.msi" IACCEPTMSODBCSQLLICENSETERMS=YES 
cls
echo.
echo SQLCMD �� ODBC �̼�ġ�� �ڵ� �������Դϴ�. ��ø� ��ٷ� �ּ���
echo ������ %%75
timeout /t 5 /nobreak >nul 2>&1
cls
echo.
echo SQLCMD �� ODBC �̼�ġ�� �ڵ� �������Դϴ�. ��ø� ��ٷ� �ּ���
echo ����Ϸ�! %%100
msiexec /quiet /passive /qn /i "bin\MsSqlCmdLnUtils_x86.msi" IACCEPTMSSQLCMDLNUTILSLICENSETERMS=YES
echo.
echo.
echo ��� �� CitrixCVUC���� ����� �˴ϴ�.
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
if %dbcon%==1 set bsel=�̱�
if %dbcon%==2 set bsel=����
if %salist%==0 set dbuserauto=AD����������
if %salist%==1 set dbuserauto=SQL Server ����
cls
:: echo Ȯ�ο뵵 %salist%
echo VM UUID,Pool ���ؼ� ����,īŻ�α� ������ VM ���� �� DB ���� ���� �޴�
echo.
echo ## CitrixCVUC Tools ���� ���
echo -- ���� ���� �ʿ� �� '4'�� �Է� �Ǵ� config.conf ���� ����
echo ���� Citrix Controller DB �����( %bsel% )����Դϴ�. 
echo ���� CitrixCVUC Tools DB ���� ����� ( %dbuserauto% ) ����Դϴ�.
:: echo �н����� !sapass! 
echo.
echo ## �ɼ� ����
echo.
echo 1. VM_UUID ����    
echo 2. VM_POOL���ؼ� ����  
echo 3. Catalog Master VM ��ü  
echo 4. DB�������� ����
echo 5. CitrixCVUC ����
echo 6. �ٷ��� ������ ó���ϱ� (CSV���� ó��) 
echo x. ������
echo.
set /p sel=�Է�:

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
echo ������ ��� �Է��Դϴ�.
pause
goto main2

:ch1
set useruuid=c
:: VM_UUID ��ü ��ũ��Ʈ ���� 
cls 
echo 1. VM_UUID ����
echo �����޴��� ���ư��� 'c' �Է�
echo.
echo �Է� ����) 07324359-868a-6459-2b7c-21ca8dc1e20a
echo.
echo ���� VM�� UUID�Է�
set /p useuuid=�Է�:
if %useuuid%==c goto main2
if %useuuid%==C goto main2

echo.
echo.
echo ��ü VM�� UUID�Է�
set /p chuuid=�Է�:

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
if %salist%==1 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -i "%TMP%\MCS.sql"

echo.
echo MCS VM(%usename%)�� ���� %useuuid%���� %chuuid%�� ����Ǿ����ϴ�.


:VMBK
if %bkoption%==0 goto ch11
if exist "Backup\VM\" (echo.) ELSE (mkdir "Backup\VM\")
if exist "Backup\VM\MCSbak.sql" (echo.) ELSE (goto VMBKrenameskip)
for /f "tokens=3" %%i in ('findstr "����" "Backup\VM\MCSbak.sql"') do set rename=%%i >nul
move "Backup\VM\MCSbak.sql" "Backup\VM\%rename::=%- MCSbak.sql" >nul
:VMBKrenameskip

:: VM backup ����
echo -- �������: %date:~2,2%%date:~5,2%%date:~8,2%-%time:~0,8% > "Backup\VM\MCSbak.sql"
echo -- ������VM: VMUID:%useuuid% >> "Backup\VM\MCSbak.sql"
echo -- ���泻��:  MCS VM(%usename%)�� ���� %useuuid%���� %chuuid%�� ���� >> "Backup\VM\MCSbak.sql"
echo SET QUOTED_IDENTIFIER ON >> "Backup\VM\MCSbak.sql"
echo. >> "Backup\VM\MCSbak.sql"
echo GO >> "Backup\VM\MCSbak.sql"
echo. >> "Backup\VM\MCSbak.sql"
:: Monitoring DB ����
if %dbcon%==1 echo UPDATE [%userDB%].[MonitorData].[Machine] >> "Backup\VM\MCSbak.sql"
if %dbcon%==2 echo UPDATE [%userMoDB%].[MonitorData].[Machine] >> "Backup\VM\MCSbak.sql"
echo SET HostedMachineId = '%useuuid%' >> "Backup\VM\MCSbak.sql"
echo WHERE HostedMachineId = '%chuuid%' >> "Backup\VM\MCSbak.sql"
echo. >> "Backup\VM\MCSbak.sql"

:: Site DB ����
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
:: Pool ��ü ��ũ��Ʈ ����
cls 
set chuuid=c
echo 2. VM_POOL���ؼ� ����
echo �����޴��� ���ư��� 'c' �Է�
echo.
echo �Է� ����) 07324359-868a-6459-2b7c-21ca8dc1e20a
echo.
echo Ǯ��ü ��� VM�� UUID�Է�
set /p chuuid=�Է�:
if %chuuid%==c goto main2
if %chuuid%==C goto main2
echo.
echo ���õ� VM�� ���� ��ϵ� �����۹����� UidȮ��
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
echo ���� VM(%chname%)�� ��ϵ� �����۹����� Uid��ȣ �� %vmp: =%�� �Դϴ�.
echo.
echo DDCȣ���ÿ� ��ϵ� �����۹����� ���

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
echo ȭ�鿡 ǥ�õ� ��ü ���� �� �����۹����� Uid��ȣ �����ϱ�
echo.
set /p poolin=�Է�:

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
:: Monitoring DB ���� ����
if %dbcon%==1 echo UPDATE [%userDB%].[MonitorData].[Machine] >> "%TMP%\Pool.sql"
if %dbcon%==2 echo UPDATE [%userMoDB%].[MonitorData].[Machine] >> "%TMP%\Pool.sql"
echo SET HypervisorId = '%poolin1%' >> "%TMP%\Pool.sql"
echo WHERE HostedMachineId = '%chuuid%' >> "%TMP%\Pool.sql"
echo. >> "%TMP%\Pool.sql"
:: Site DB ���� ����
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

echo VM(%chname%). %vmp: =%������ %poolin%�� Ǯ ���� �Ϸ�!

:PoolBK
if %bkoption%==0 goto ch34
if exist "Backup\Pool\" (echo.) ELSE (mkdir "Backup\Pool\")
if exist "Backup\Pool\poolbak.sql" (echo.) ELSE (goto PBKrenameskip)
for /f "tokens=3" %%i in ('findstr "����" "Backup\Pool\poolbak.sql"') do set rename=%%i >nul
move "Backup\Pool\poolbak.sql" "Backup\Pool\%rename::=% poolbak.sql" >nul
:PBKrenameskip
:: Pool backup ����
echo -- �������: %date:~2,2%%date:~5,2%%date:~8,2%-%time:~0,8% > "Backup\Pool\poolbak.sql"
echo -- ������VM: VMUID:%chuuid% VMName:%chname% >> "Backup\Pool\poolbak.sql"
echo -- ���泻��: Hpervisor Pool %vmp: =%������ %poolin%�� Ǯ ���� >> "Backup\Pool\poolbak.sql"
echo SET QUOTED_IDENTIFIER ON >> "Backup\Pool\poolbak.sql"
echo. >> "Backup\Pool\poolbak.sql"
echo GO >> "Backup\Pool\poolbak.sql"
echo. >> "Backup\Pool\poolbak.sql"
echo. >> "Backup\Pool\poolbak.sql"
:: Monitoring DB ����
if %dbcon%==1 echo UPDATE [%userDB%].[MonitorData].[Machine] >> "Backup\Pool\poolbak.sql"
if %dbcon%==2 echo UPDATE [%userMoDB%].[MonitorData].[Machine] >> "Backup\Pool\poolbak.sql"
echo SET HypervisorId = '%vmp1%' >> "Backup\Pool\poolbak.sql"
echo WHERE HostedMachineId = '%chuuid%' >> "Backup\Pool\poolbak.sql"
echo. >> "Backup\Pool\poolbak.sql"
:: Site DB ����
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
:: Catalog Master VM ��ü ��ũ��Ʈ ����
cls 
set ctl=c
echo 3. Catalog Master VM ��ü
echo �����޴��� ���ư��� 'c' �Է�
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
if %ctl%==c goto main2
if %ctl%==C goto main2
echo.
echo �ٲ�ġ�� �� īŻ�α׳��� �Է�
set /p chctl=�Է�:
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
echo ������ VM ���� �Ϸ�!
echo.
echo ����� �׸� ���

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
for /f "tokens=3" %%i in ('findstr "����" "Backup\Master\imagebak.sql"') do set rename=%%i >nul
move "Backup\Master\imagebak.sql" "Backup\Master\%rename::=%- imagebak.sql" >nul
:MBKrenameskip
:: Pool backup ����
echo -- �������: %date:~2,2%%date:~5,2%%date:~8,2%-%time:~0,8% > "Backup\Master\imagebak.sql"
echo -- ��� īŻ�α�: %ctl% >> "Backup\Master\imagebak.sql"
echo -- ��� Hypervisor : %HypUID: =% >> "Backup\Master\imagebak.sql"
echo -- ���泻��: īŻ�α� �̹���(%ctl% -^> %chctl%) HypervisorUid(%HypUID: =% -^> %chHypUID: =%) īŻ�α� Uid(%ProvSID% -^> %chProvSID%)>> "Backup\Master\imagebak.sql"
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
echo SQL Server ������� DB ����
echo �����޴��� ���ư��� 'c' �Է�
echo.
echo 1.CVAD DB�� �Է�
set /p userDB=�Է�:
if %userDB%==c cls & goto main
if %userDB%==C cls & goto main
echo.
echo 2.DB user �Է� 
echo �Է¾��ϰ� �Ѿ �� sa�������� �ڵ� �Է�
set /p sauser=�Է�:
echo.
echo 3.DB %sauser% ���� �н����� �Է�
call :mssqlPass usersapass "�Է�: "
echo.
exit /b
:selc2
cls
set userSiteDB=c
if %dbcon%==2 set singleDB=Disable
echo DB�������� ����
echo �����޴��� ���ư��� 'c' �Է�
echo.
echo 1.CVAD DB Site�� �Է�
set /p userSiteDB=�Է�:
if %userSiteDB%==c cls & goto main
if %userSiteDB%==C cls & goto main
echo.
echo 2.CVAD DB Monitor�� �Է�
set /p userMoDB=�Է�:
echo.
echo 3.DB user �Է� 
echo �Է¾��ϰ� �Ѿ �� sa�������� �ڵ� �Է�
set /p sauser=�Է�:
echo.
echo 4.DB %sauser% ���� �н����� �Է�
call :mssqlPass usersapass "�Է�: "
echo.
exit /b

:mssqlPass    
SetLocal DisableDelayedExpansion
echo �Է�:
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
::��ȣȭ
echo(
for /f "tokens=1" %%i in ('echo !Line! ^|bin\openssl.exe enc -e -aes256 -a -k %COMPUTERNAME%') do set passenc=%%i
goto dbpassenc
:dbpassenc
set userDBip=%userDBip%

goto input3

::goto main2

:MVCBAK
set sel=vm
:: VM_UUID, Pool, MasterImage ���� �����ϴ� ����
cls
echo 5. CitrixCVUC ����
echo.
echo ##�޴�ȭ��
echo 1) VM���� 
echo 2) VM Pool ���ؼ� ����
echo 3) Catalog Master VM ����
echo 4) ��� ����
echo c) ���� �޴��� ���ư���
echo x) ������

set /p sel=�Է�:

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
echo 5. CitrixCVUC ���� 1)VM ����
set sel=skip
set baksql="Backup\VM\MCSbak.sql"
for /f "tokens=3" %%i in ('findstr "����" "Backup\VM\MCSbak.sql"') do set bakdate=%%i >nul
echo.
echo ���������� ����� ���ڴ� %bakdate% �Դϴ�.
echo %bakdate% �������� ������ ���Ͻø� ���� ���� ���·� �Է�â�� ���͸� �����ʽÿ�
echo.
echo ���� �޴��� ���ư��⸦ ���Ͻø� CŰ�� �Է��Ͻʽÿ�
echo.

set /p baksql=�Է�:

if %baksql%==c goto MVCBAK
if %baksql%==C goto MVCBAK


if %salist%==0 sqlcmd -E -S %userDBip%,%dbport% -i %baksql%
if %salist%==1 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -i %baksql%
echo.
echo VM ���� �Ϸ�!
pause 
goto main2

:mvcbak2
cls
echo 5. CitrixCVUC ���� 2) VM Pool ���ؼ� ����
set sel=skip
set baksql="Backup\Pool\poolbak.sql"
for /f "tokens=3" %%i in ('findstr "����" "Backup\Pool\poolbak.sql"') do set bakdate=%%i >nul
echo.
echo ���������� ����� ���ڴ� %bakdate% �Դϴ�.
echo %bakdate% �������� ������ ���Ͻø� ���� ���� ���·� �Է�â�� ���͸� �����ʽÿ�
echo. 
echo ���� �޴��� ���ư��⸦ ���Ͻø� CŰ�� �Է��Ͻʽÿ�
echo.

set /p baksql=�Է�:

if %baksql%==c goto MVCBAK
if %baksql%==C goto MVCBAK


if %salist%==0 sqlcmd -E -S %userDBip%,%dbport% -i %baksql%
if %salist%==1 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -i %baksql%
echo.
echo VM ���� �Ϸ�!
pause 
goto main2

:mvcbak3
cls
echo 5. CitrixCVUC ���� 3) Catalog Master VM ����
set sel=skip
set baksql="Backup\Master\imagebak.sql"
for /f "tokens=3" %%i in ('findstr "����" "Backup\Master\imagebak.sql"') do set bakdate=%%i >nul
echo.
echo ���������� ������ ���ڴ� %bakdate% �Դϴ�.
echo %bakdate% �������� ������ ���Ͻø� ���� ���� ���·� �Է�â�� ���͸� �����ʽÿ�
echo. 
echo ���� �޴��� ���ư��⸦ ���Ͻø� CŰ�� �Է��Ͻʽÿ�
echo.

set /p baksql=�Է�:

if %baksql%==c goto MVCBAK
if %baksql%==C goto MVCBAK


if %salist%==0 sqlcmd -E -S %userDBip%,%dbport% -i %baksql%
if %salist%==1 sqlcmd -S %userDBip%,%dbport% -U %sauser% -P !sapass! -i %baksql%
echo.
echo VM ���� �Ϸ�!
pause 
goto main2

:mvcbak4
cls
echo 5. CitrixCVUC ���� 4) ��� ����
set sel=skip
set baksql=skip
set Vbaksql="Backup\Master\imagebak.sql"
set Pbaksql="Backup\Pool\poolbak.sql"
set Mbaksql="Backup\Master\imagebak.sql"
for /f "tokens=3" %%i in ('findstr "����" "Backup\VM\MCSbak.sql"') do set Vbakdate=%%i >nul
for /f "tokens=3" %%i in ('findstr "����" "Backup\Pool\poolbak.sql"') do set Pbakdate=%%i >nul
for /f "tokens=3" %%i in ('findstr "����" "Backup\Master\imagebak.sql"') do set Mbakdate=%%i >nul
echo.
echo 1. VM_UUID ������ ���������� ������ ���ڴ� %Vbakdate% �Դϴ�.
echo 2. VM_UUID ������ ���������� ������ ���ڴ� %Pbakdate% �Դϴ�.
echo 3. VM_UUID ������ ���������� ������ ���ڴ� %Mbakdate% �Դϴ�.
echo ���� �������� ������ ���Ͻø� ���� ���� ���·� �Է�â�� ���͸� �����ʽÿ�
echo. 
echo ���� �޴��� ���ư��⸦ ���Ͻø� CŰ�� �Է��Ͻʽÿ�
echo.

set /p baksql=�Է�:

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
echo VM ���� �Ϸ�!
pause 
goto main2


:bakerr
echo ������ ��� �Է��Դϴ�.
pause
goto MVCBAK


:CSVhome
setlocal EnableDelayedExpansion
set sel=vm
if exist "CSV\" (goto MVCCSV) ELSE (mkdir "CSV\")
:: VM_UUID, Pool, MasterImage CSV�� ���� �� �ҷ����� ����
:MVCCSV
cls
echo 6. �ٷ��� ������ ó���ϱ� (CSV���� ó��)
echo.
echo ##�޴�ȭ��
echo 1) VM_UUID,VM_Pool ���ؼ� csv ��� �����ϱ�
echo 2) VM_UUID,VM_Pool ���ؼ� csv �ҷ�����
echo 3) Catalog Master VM csv ��� �����ϱ�
echo 4) Catalog Master VM csv �ҷ�����
echo c) ���� �޴��� ���ư���
echo x) ������
echo.
echo ## ���ǻ���! 
echo csv����� ������ ���� �� ���� �� *.xlsx , *.xlsm , *.xls ������ ���� X
echo �ݵ�� ������ *.csv �������� ����!

set /p sel=�Է�:

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
echo ������ ��� �Է��Դϴ�.
pause
goto MVCCSV

:mvccsv1
echo 1) VM_UUID,VM_Pool ���ؼ� csv ��� �����ϱ�
echo.
echo ������...
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
echo CSV\MVCCSV.csv ��η� ���� �Ϸ��Ͽ����ϴ�!
pause
goto MVCCSV

:mvccsv2
set sel=CSV\MVCCSV.csv
echo.
echo 2) VM_UUID,VM_Pool ���ؼ� csv �ҷ�����
echo.
echo CSV\MVCCSV.csv���� �ҷ����� ���� �ƴ� ���� �� ���Ϸ� �ҷ����⸦ �� ���
echo csv������ ��θ� �Է��ϰų� ������ �巹�� �� ����Ͽ� ��θ� ����
echo �Է¿���) C:\Users\user\Desktop\MVCCSV.csv
echo.
echo ���� �޴��� ���ư��� 'C' ��ư Ŭ��, ������ 'X' ��ư
echo.
echo.
set /p sel=�Է� �Ǵ� �巹�׾� ���:

if %sel%==c goto MVCCSV
if %sel%==C goto MVCCSV
if %sel%==x goto exit
if %sel%==X goto exit

:mvccsv2home
echo ������...
for /f %%i in ('type %sel% ^|find /c /v ""') do set /a count=%%i-2

:: ù��° Uid ���� ����
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

:: �ι�° VMName ����
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

:: ����° VMUid ����
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


:: �׹�° HypervisorName ����
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

:: ����
if %dbcon%==1 goto mvccsv2ch1
if %dbcon%==2 goto mvccsv2ch2

:mvccsv2ch1
if %salist%==0 goto mvccsv2ch3
::VM ����
for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[Chb_Config].[Workers] Set HostedMachineId = '!vmu%%t!' FROM [%userDB%].[Chb_Config].[Workers] w Left Join [%userDB%].[MonitorData].[Machine] m ON w.HostedMachineId = m.HostedMachineId where m.HostedMachineName = '!vmn%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[MonitorData].[Machine] Set HostedMachineId = '!vmu%%t!' WHERE HostedMachineName = '!vmn%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] Set VMId = '!vmu%%t!' FROM [%userDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] w Left Join [%userDB%].[MonitorData].[Machine] m ON w.ADAccountSid = m.Sid WHERE m.HostedMachineName = '!vmn%%t!'"

::pool ����
for /l %%t in (1,1,%count%) do for /f "tokens=*" %%i in ('sqlcmd -S %userDBip%^^^,%dbport% -U %sauser% -P !sapass! -s"=" -W -h -1 -Q "set nocount on; select Uid FROM [%userDB%].chb_Config.HypervisorConnections where DisplayName = '!hypn%%t!'"') do set hypu%%t=%%i
for /l %%t in (1,1,%count%) do for /f "tokens=*" %%i in ('sqlcmd -S %userDBip%^^^,%dbport% -U %sauser% -P !sapass! -s"=" -W -h -1 -Q "set nocount on; select HypervisorConnectionId FROM [%userDB%].chb_Config.HypervisorConnections where DisplayName = '!hypn%%t!'"') do set hypi%%t=%%i

for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[MonitorData].[Machine] Set HypervisorId = '!hypi%%t!' WHERE HostedMachineName = '!vmn%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[Chb_Config].[Workers] Set HypervisorConnectionUid = '!hypu%%t!' WHERE HostedMachineId = '!vmu%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] SET HypervisorConnectionUid = '!hypi%%t!' WHERE VMId = '!vmu%%t!'"

goto mvccsv2ch5

:mvccsv2ch2
if %salist%==0 goto mvccsv2ch4
::VM ����
for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userSiteDB%].[Chb_Config].[Workers] Set HostedMachineId = '!vmu%%t!' FROM [%userSiteDB%].[Chb_Config].[Workers] w Left Join [%userMoDB%].[MonitorData].[Machine] m ON w.HostedMachineId = m.HostedMachineId where m.HostedMachineName = '!vmn%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userMoDB%].[MonitorData].[Machine] Set HostedMachineId = '!vmu%%t!' WHERE HostedMachineName = '!vmn%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userSiteDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] Set VMId = '!vmu%%t!' FROM [%userSiteDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] w Left Join [%userMoDB%].[MonitorData].[Machine] m ON w.ADAccountSid = m.Sid WHERE m.HostedMachineName = '!vmn%%t!'"

::pool ����
for /l %%t in (1,1,%count%) do for /f "tokens=*" %%i in ('sqlcmd -S %userDBip%^^^,%dbport% -U %sauser% -P !sapass! -s"=" -W -h -1 -Q "set nocount on; select Uid FROM [%userSiteDB%].chb_Config.HypervisorConnections where DisplayName = '!hypn%%t!'"') do set hypu%%t=%%i
for /l %%t in (1,1,%count%) do for /f "tokens=*" %%i in ('sqlcmd -S %userDBip%^^^,%dbport% -U %sauser% -P !sapass! -s"=" -W -h -1 -Q "set nocount on; select HypervisorConnectionId FROM [%userSiteDB%].chb_Config.HypervisorConnections where DisplayName = '!hypn%%t!'"') do set hypi%%t=%%i

for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userMoDB%].[MonitorData].[Machine] Set HypervisorId = '!hypi%%t!' WHERE HostedMachineName = '!vmn%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userSiteDB%].[Chb_Config].[Workers] Set HypervisorConnectionUid = '!hypu%%t!' WHERE HostedMachineId = '!vmu%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userSiteDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] SET HypervisorConnectionUid = '!hypi%%t!' WHERE VMId = '!vmu%%t!'"

goto mvccsv2ch5

:mvccsv2ch3
::VM ����
for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[Chb_Config].[Workers] Set HostedMachineId = '!vmu%%t!' FROM [%userDB%].[Chb_Config].[Workers] w Left Join [%userDB%].[MonitorData].[Machine] m ON w.HostedMachineId = m.HostedMachineId where m.HostedMachineName = '!vmn%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[MonitorData].[Machine] Set HostedMachineId = '!vmu%%t!' WHERE HostedMachineName = '!vmn%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] Set VMId = '!vmu%%t!' FROM [%userDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] w Left Join [%userDB%].[MonitorData].[Machine] m ON w.ADAccountSid = m.Sid WHERE m.HostedMachineName = '!vmn%%t!'"

::pool ����
for /l %%t in (1,1,%count%) do for /f "tokens=*" %%i in ('sqlcmd -E -S %userDBip%^^^,%dbport% -s"=" -W -h -1 -Q "set nocount on; select Uid FROM [%userDB%].chb_Config.HypervisorConnections where DisplayName = '!hypn%%t!'"') do set hypu%%t=%%i
for /l %%t in (1,1,%count%) do for /f "tokens=*" %%i in ('sqlcmd -E -S %userDBip%^^^,%dbport% -s"=" -W -h -1 -Q "set nocount on; select HypervisorConnectionId FROM [%userDB%].chb_Config.HypervisorConnections where DisplayName = '!hypn%%t!'"') do set hypi%%t=%%i

for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[MonitorData].[Machine] Set HypervisorId = '!hypi%%t!' WHERE HostedMachineName = '!vmn%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[Chb_Config].[Workers] Set HypervisorConnectionUid = '!hypu%%t!' WHERE HostedMachineId = '!vmu%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] SET HypervisorConnectionUid = '!hypi%%t!' WHERE VMId = '!vmu%%t!'"

goto mvccsv2ch5

:mvccsv2ch4
::VM ����
for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userSiteDB%].[Chb_Config].[Workers] Set HostedMachineId = '!vmu%%t!' FROM [%userSiteDB%].[Chb_Config].[Workers] w Left Join [%userMoDB%].[MonitorData].[Machine] m ON w.HostedMachineId = m.HostedMachineId where m.HostedMachineName = '!vmn%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userMoDB%].[MonitorData].[Machine] Set HostedMachineId = '!vmu%%t!' WHERE HostedMachineName = '!vmn%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userSiteDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] Set VMId = '!vmu%%t!' FROM [%userSiteDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] w Left Join [%userMoDB%].[MonitorData].[Machine] m ON w.ADAccountSid = m.Sid WHERE m.HostedMachineName = '!vmn%%t!'"

::pool ����
for /l %%t in (1,1,%count%) do for /f "tokens=*" %%i in ('sqlcmd -E -S %userDBip%^^^,%dbport% -s"=" -W -h -1 -Q "set nocount on; select Uid FROM [%userSiteDB%].chb_Config.HypervisorConnections where DisplayName = '!hypn%%t!'"') do set hypu%%t=%%i
for /l %%t in (1,1,%count%) do for /f "tokens=*" %%i in ('sqlcmd -E -S %userDBip%^^^,%dbport% -s"=" -W -h -1 -Q "set nocount on; select HypervisorConnectionId FROM [%userSiteDB%].chb_Config.HypervisorConnections where DisplayName = '!hypn%%t!'"') do set hypi%%t=%%i

for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userMoDB%].[MonitorData].[Machine] Set HypervisorId = '!hypi%%t!' WHERE HostedMachineName = '!vmn%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userSiteDB%].[Chb_Config].[Workers] Set HypervisorConnectionUid = '!hypu%%t!' WHERE HostedMachineId = '!vmu%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userSiteDB%].[DesktopUpdateManagerSchema].[ProvisionedVirtualMachine] SET HypervisorConnectionUid = '!hypi%%t!' WHERE VMId = '!vmu%%t!'"


goto mvccsv2ch5


:mvccsv2ch5
echo �ҷ����Ⱑ �Ϸ�Ǿ����ϴ�!
pause
goto MVCCSV


:mvccsv3
echo 3) Catalog Master VM csv ��� �����ϱ�
echo.
echo ������...
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
echo CSV\Master.csv ��η� ���� �Ϸ��Ͽ����ϴ�!
pause
goto MVCCSV


:mvccsv4
echo.
set sel=CSV\Master.csv
echo 4) Catalog Master VM csv �ҷ�����
echo.
echo CSV\Master.csv���� �ҷ����� ���� �ƴ� ���� �� ���Ϸ� �ҷ����⸦ �� ���
echo csv������ ��θ� �Է��ϰų� ������ �巹�� �� ����Ͽ� ��θ� ����
echo �Է¿���) C:\Users\user\Desktop\Master.csv
echo.
echo ���� �޴��� ���ư��� 'C' ��ư Ŭ��, ������ 'X' ��ư
echo.
echo.
set /p sel=�Է� �Ǵ� �巹�׾� ���:

if %sel%==c goto MVCCSV
if %sel%==C goto MVCCSV
if %sel%==x goto exit
if %sel%==X goto exit

:mvccsv4home
echo ������...
for /f %%i in ('type %sel% ^|find /c /v ""') do set /a count=%%i-2
:: ù��° īŻ�α� ���� ���� ����
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

:: �ι�° ProvisioningSchemeId ����
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

:: ����° HypervisorName ����
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

:: ����
if %dbcon%==1 goto mvccsv4ch1
if %dbcon%==2 goto mvccsv4ch2

:mvccsv4ch1
if %salist%==0 goto mvccsv4ch3
::pool ����
for /l %%t in (1,1,%count%) do for /f "tokens=*" %%i in ('sqlcmd -S %userDBip%^^^,%dbport% -U %sauser% -P !sapass! -s"=" -W -h -1 -Q "set nocount on; select Uid FROM [%userDB%].chb_Config.HypervisorConnections where DisplayName = '!hypn%%t!'"') do set hypu%%t=%%i

for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[chb_Config].[Catalogs] Set ProvisioningSchemeId = '!provid%%t!' WHERE DisplayName = '!catalogname%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[chb_Config].[Catalogs] Set HypervisorConnectionUid = '!hypu%%t!' WHERE DisplayName = '!catalogname%%t!'"

goto mvccsv4ch5

:mvccsv4ch2
if %salist%==0 goto mvccsv4ch4
::pool ����
for /l %%t in (1,1,%count%) do for /f "tokens=*" %%i in ('sqlcmd -S %userDBip%^^^,%dbport% -U %sauser% -P !sapass! -s"=" -W -h -1 -Q "set nocount on; select Uid FROM [%userSiteDB%].chb_Config.HypervisorConnections where DisplayName = '!hypn%%t!'"') do set hypu%%t=%%i

for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userSiteDB%].[chb_Config].[Catalogs] Set ProvisioningSchemeId = '!provid%%t!' WHERE DisplayName = '!catalogname%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -S %userDBip%^,%dbport% -U %sauser% -P !sapass! -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userSiteDB%].[chb_Config].[Catalogs] Set HypervisorConnectionUid = '!hypu%%t!' WHERE DisplayName = '!catalogname%%t!'"

goto mvccsv4ch5

:mvccsv4ch3
::pool ����
for /l %%t in (1,1,%count%) do for /f "tokens=*" %%i in ('sqlcmd -E -S %userDBip%^^^,%dbport% -s"=" -W -h -1 -Q "set nocount on; select Uid FROM [%userDB%].chb_Config.HypervisorConnections where DisplayName = '!hypn%%t!'"') do set hypu%%t=%%i

for /l %%t in (1,1,%count%) do sqlcmd -S -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[chb_Config].[Catalogs] Set ProvisioningSchemeId = '!provid%%t!' WHERE DisplayName = '!catalogname%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -S -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userDB%].[chb_Config].[Catalogs] Set HypervisorConnectionUid = '!hypu%%t!' WHERE DisplayName = '!catalogname%%t!'"

goto mvccsv4ch5

:mvccsv4ch4
::pool ����
for /l %%t in (1,1,%count%) do for /f "tokens=*" %%i in ('sqlcmd -E -S %userDBip%^^^,%dbport% -s"=" -W -h -1 -Q "set nocount on; select Uid FROM [%userSiteDB%].chb_Config.HypervisorConnections where DisplayName = '!hypn%%t!'"') do set hypu%%t=%%i

for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userSiteDB%].[chb_Config].[Catalogs] Set ProvisioningSchemeId = '!provid%%t!' WHERE DisplayName = '!catalogname%%t!'"
for /l %%t in (1,1,%count%) do sqlcmd -E -S %userDBip%^,%dbport% -s"," -W -h -1 -Q "SET QUOTED_IDENTIFIER ON; Update [%userSiteDB%].[chb_Config].[Catalogs] Set HypervisorConnectionUid = '!hypu%%t!' WHERE DisplayName = '!catalogname%%t!'"

goto mvccsv4ch5


:mvccsv4ch5
echo �ҷ����Ⱑ �Ϸ�Ǿ����ϴ�!
echo.
pause

goto MVCCSV


:ver
cls
echo ���� ���� Citrix CVAD VDI UUID Changer v1.3.2
echo Date 2023-08-03
echo Copyright �� Leedk. All rights reserved.
echo.
pause
goto main2
