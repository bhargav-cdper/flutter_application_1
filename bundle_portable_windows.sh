@echo off
echo Creating Portable Expense Management App for Windows...

set APP_NAME=expense-management
set PORTABLE_DIR=ExpenseApp_Portable_Windows
set BUILD_SOURCE=build\windows\x64\runner\Release

echo Setting up portable directory structure...
if exist %USERPROFILE%\%PORTABLE_DIR% rmdir /s /q %USERPROFILE%\%PORTABLE_DIR%
mkdir %USERPROFILE%\%PORTABLE_DIR%
mkdir %USERPROFILE%\%PORTABLE_DIR%\data
mkdir %USERPROFILE%\%PORTABLE_DIR%\data\backups

echo Copying application files...
xcopy "%BUILD_SOURCE%\*" "%USERPROFILE%\%PORTABLE_DIR%\" /E /I /H /Y

cd /d %USERPROFILE%\%PORTABLE_DIR%

echo Renaming executable...
if exist flutter_application_1.exe ren flutter_application_1.exe %APP_NAME%.exe

echo Creating Windows launcher...
(
echo @echo off
echo title Expense Management App - Portable Edition
echo cd /d "%%~dp0"
echo.
echo echo ================================================================
echo echo      Expense Management App - Portable Edition v1.0
echo echo ================================================================
echo echo.
echo.
echo REM Set environment variables for portable mode
echo set EXPENSE_APP_PORTABLE=true
echo set EXPENSE_APP_DATA_DIR=%%~dp0data
echo.
echo echo 🚀 Starting in Portable Mode...
echo echo 📁 Data Directory: %%~dp0data
echo echo 💾 Database: %%~dp0data\expense_management.db
echo echo.
echo.
echo REM Create data directory if it doesn't exist
echo if not exist "data" mkdir "data"
echo if not exist "data\backups" mkdir "data\backups"
echo.
echo echo ================================================================
echo echo.
echo.
echo REM Start the application
echo if exist "%APP_NAME%.exe" ^(
echo     %APP_NAME%.exe
echo ^) else ^(
echo     echo ❌ Error: %APP_NAME%.exe not found!
echo     pause
echo     exit /b 1
echo ^)
echo.
echo if errorlevel 1 ^(
echo     echo.
echo     echo ⚠️  Application exited with an error.
echo     echo    Check if Visual C++ Redistributable is installed.
echo     pause
echo ^)
) > run.bat

echo Creating README...
(
echo PORTABLE EXPENSE MANAGEMENT APP - WINDOWS EDITION
echo ===============================================
echo.
echo This is a fully portable expense management application for Windows.
echo.
echo 🚀 QUICK START:
echo - Double-click run.bat to start the application
echo - All data is stored in the 'data' folder
echo.
echo 💻 SYSTEM REQUIREMENTS:
echo - Windows 10 or later
echo - Visual C++ Redistributable 2019 or later
echo.
echo 📁 FOLDER STRUCTURE:
echo ExpenseApp_Portable_Windows/
echo ├── %APP_NAME%.exe          # Main application
echo ├── run.bat                 # Launcher script
echo ├── data/                   # All your data
echo │   ├── expense_management.db
echo │   └── backups/
echo └── README.txt              # This file
echo.
echo 🔧 TROUBLESHOOTING:
echo - If app doesn't start, install Visual C++ Redistributable
echo - Ensure antivirus isn't blocking the application
echo - Run as administrator if permission issues occur
echo.
echo 💾 DATA PORTABILITY:
echo - Copy entire folder to backup your data
echo - Works from USB drives and network locations
echo - No installation required
echo.
echo VERSION: 1.0 Portable Windows Edition
) > README.txt

echo.
echo ================================================================
echo ✅ Portable Windows app created successfully!
echo.
echo 📁 Location: %USERPROFILE%\%PORTABLE_DIR%
echo 🚀 To start: Double-click run.bat in the created folder
echo.
echo 💡 Copy the entire folder to a USB drive for true portability!
echo ================================================================
pause