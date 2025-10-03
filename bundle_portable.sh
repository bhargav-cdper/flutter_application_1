#!/bin/bash

# Enhanced Portable Expense Management App Bundle Creator
echo "Creating Portable Expense Management App..."

# Configuration
APP_NAME="expense-management"
PORTABLE_DIR="ExpenseApp_Portable"
BUILD_SOURCE="build/linux/x64/release/bundle"

# Clean and create portable directory structure
echo "Setting up portable directory structure..."
rm -rf ~/${PORTABLE_DIR}
mkdir -p ~/${PORTABLE_DIR}/data
mkdir -p ~/${PORTABLE_DIR}/data/backups
mkdir -p ~/${PORTABLE_DIR}/lib

echo "Copying application files..."
# Copy app files
cp -r ${BUILD_SOURCE}/* ~/${PORTABLE_DIR}/

cd ~/${PORTABLE_DIR}

# Rename executable to user-friendly name
mv flutter_application_1 ${APP_NAME}
chmod +x ${APP_NAME}

echo "Bundling SQLite3 library for portability..."

# Bundle SQLite3 function
bundle_sqlite() {
    local sqlite_found=false
    
    # Check common SQLite3 library locations
    for path in \
        "/usr/lib/x86_64-linux-gnu/libsqlite3.so.0" \
        "/usr/lib64/libsqlite3.so.0" \
        "/usr/lib/libsqlite3.so.0" \
        "/lib/x86_64-linux-gnu/libsqlite3.so.0" \
        "/lib64/libsqlite3.so.0"
    do
        if [ -f "$path" ]; then
            cp "$path" lib/libsqlite3.so.0
            # Also create a symlink without version number
            ln -sf libsqlite3.so.0 lib/libsqlite3.so
            echo "SQLite3 bundled from: $path"
            sqlite_found=true
            break
        fi
    done
    
    # If not found locally, download a compatible version
    if [ "$sqlite_found" = false ]; then
        echo "Local SQLite3 not found, downloading..."
        
        mkdir -p /tmp/sqlite_download
        cd /tmp/sqlite_download
        
        # Download SQLite3 precompiled binaries
        wget -q "https://www.sqlite.org/2023/sqlite-autoconf-3440200.tar.gz" -O sqlite.tar.gz
        
        if [ $? -eq 0 ]; then
            tar -xzf sqlite.tar.gz
            cd sqlite-autoconf-3440200
            
            # Compile SQLite3 as shared library
            ./configure --enable-shared --prefix=/tmp/sqlite_install
            make && make install
            
            # Copy the compiled library
            if [ -f "/tmp/sqlite_install/lib/libsqlite3.so.0" ]; then
                cp /tmp/sqlite_install/lib/libsqlite3.so.0 ~/${PORTABLE_DIR}/lib/
                ln -sf libsqlite3.so.0 ~/${PORTABLE_DIR}/lib/libsqlite3.so
                echo "SQLite3 compiled and bundled successfully"
                sqlite_found=true
            fi
        fi
        
        # Cleanup
        cd ~/${PORTABLE_DIR}
        rm -rf /tmp/sqlite_download /tmp/sqlite_install
    fi
    
    return $sqlite_found
}

# Try to bundle SQLite3
if bundle_sqlite; then
    echo "✅ SQLite3 library bundled successfully"
else
    echo "⚠️  Warning: Could not bundle SQLite3. Users will need to install it."
fi

echo "Creating portable launcher scripts..."

# Create Linux/Mac launcher script
cat > run.sh << 'EOF'
#!/bin/bash

echo "================================================================"
echo "     Expense Management App - Portable Edition v1.0"
echo "================================================================"
echo ""

# Get the directory where this script is located
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$APP_DIR"

# Set environment variables for portable mode
export EXPENSE_APP_PORTABLE=true
export EXPENSE_APP_DATA_DIR="$APP_DIR/data"

# Add local lib directory to library path
export LD_LIBRARY_PATH="$APP_DIR/lib:$LD_LIBRARY_PATH"

# Set environment variables to reduce warnings and improve compatibility
export GDK_BACKEND=x11
export XDG_DATA_DIRS=/usr/share:/usr/local/share:$XDG_DATA_DIRS
export GTK_THEME=Adwaita
export QT_QPA_PLATFORM=xcb

echo "🚀 Starting in Portable Mode..."
echo "📁 Data Directory: $APP_DIR/data"
echo "💾 Database: $APP_DIR/data/expense_management.db"
echo ""

# Function to check libraries
check_lib() {
    local lib_name="$1"
    local package_suggestions="$2"
    
    if ldconfig -p 2>/dev/null | grep -q "$lib_name"; then
        echo "✅ $lib_name found"
        return 0
    else
        echo "❌ $lib_name missing"
        if [ -n "$package_suggestions" ]; then
            echo "   Install with: $package_suggestions"
        fi
        return 1
    fi
}

# Check for essential libraries
echo "Checking system requirements..."
check_lib "libgtk-3" "sudo apt install libgtk-3-0 (Ubuntu/Debian) | sudo dnf install gtk3 (Fedora)"
check_lib "libglib-2.0" "sudo apt install libglib2.0-0 (Ubuntu/Debian) | sudo dnf install glib2 (Fedora)"

# Special check for SQLite3
echo ""
echo "SQLite3 Status:"
if [ -f "$APP_DIR/lib/libsqlite3.so" ]; then
    echo "✅ Using bundled SQLite3 library"
elif ldconfig -p 2>/dev/null | grep -q "libsqlite3"; then
    echo "✅ Using system SQLite3 library"
else
    echo "❌ SQLite3 not found! Install with:"
    echo "   sudo apt install libsqlite3-0 (Ubuntu/Debian)"
    echo "   sudo dnf install sqlite (Fedora)"
    echo ""
    echo "⚠️  The application may not work without SQLite3!"
fi

echo ""
echo "================================================================"

# Create data directory if it doesn't exist
mkdir -p "$APP_DIR/data"
mkdir -p "$APP_DIR/data/backups"

# Start the application
if [ -x "./expense-management" ]; then
    ./expense-management
else
    echo "❌ Error: expense-management executable not found or not executable!"
    exit 1
fi
EOF

chmod +x run.sh

# Create Windows batch file
cat > run.bat << 'EOF'
@echo off
title Expense Management App - Portable Edition
cd /d "%~dp0"

echo ================================================================
echo      Expense Management App - Portable Edition v1.0
echo ================================================================
echo.

REM Set environment variables for portable mode
set EXPENSE_APP_PORTABLE=true
set EXPENSE_APP_DATA_DIR=%~dp0data

echo 🚀 Starting in Portable Mode...
echo 📁 Data Directory: %~dp0data
echo 💾 Database: %~dp0data\expense_management.db
echo.

REM Create data directory if it doesn't exist
if not exist "data" mkdir "data"
if not exist "data\backups" mkdir "data\backups"

echo ================================================================
echo.

REM Start the application
if exist "expense-management.exe" (
    expense-management.exe
) else (
    echo ❌ Error: expense-management.exe not found!
    pause
    exit /b 1
)

if errorlevel 1 (
    echo.
    echo ⚠️  Application exited with an error.
    echo    Check if Visual C++ Redistributable is installed.
    pause
)
EOF

# Create comprehensive README
echo "Creating documentation..."
cat > README.txt << 'EOF'
PORTABLE EXPENSE MANAGEMENT APP
===============================

This is a fully portable expense management application that stores all data 
locally within the application folder. Perfect for USB drives, shared drives,
or any location where you need a self-contained financial tracking solution.

🚀 QUICK START:
- Linux/Mac: Run ./run.sh
- Windows: Double-click run.bat
- All data is stored in the 'data' folder

📋 FEATURES:
✅ Complete expense and income tracking
✅ Bank transaction management with multiple accounts
✅ Customizable categories (Jobs, Accounts, Parties)
✅ Advanced search and filtering
✅ Automatic