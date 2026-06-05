#Requires -Version 5.1
<#
.SYNOPSIS
    Project Build Skill Suite - Environment Setup Script

.DESCRIPTION
    Check and install optional dependencies for this project:
    - python-docx: for .docx to Markdown conversion
    - pywin32: for .doc to .docx conversion (Windows only)

.NOTES
    Usage:
    powershell -ExecutionPolicy Bypass -File scripts/setup-env.ps1
#>

$ErrorActionPreference = "Continue"

# --- Color output helpers ---
function Write-OK    { param($Msg) Write-Host "  [OK] $Msg" -ForegroundColor Green }
function Write-Skip  { param($Msg) Write-Host "  [SKIP] $Msg" -ForegroundColor Yellow }
function Write-Fail  { param($Msg) Write-Host "  [FAIL] $Msg" -ForegroundColor Red }
function Write-Info  { param($Msg) Write-Host "  $Msg" -ForegroundColor Cyan }
function Write-Title { param($Msg) Write-Host "`n=== $Msg ===" -ForegroundColor White }

# --- Detect OS properly ---
# PowerShell 7+ has built-in $IsWindows / $IsLinux / $IsMacOS
# PowerShell 5.1 (Windows only) does not have these variables
if (Test-Path Variable:\IsWindows) {
    $isWindows = $IsWindows
} elseif (Test-Path Variable:\IsLinux) {
    $isWindows = $false
} elseif (Test-Path Variable:\IsMacOS) {
    $isWindows = $false
} else {
    # PowerShell 5.1: only runs on Windows
    $isWindows = ($env:OS -eq "Windows_NT")
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Project Build Skill Suite" -ForegroundColor Cyan
Write-Host "  Environment Setup Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# ============================================================
# Step 1: Check Python
# ============================================================
Write-Title "Step 1: Check Python"

$pythonCmd = $null
$pyVersion = $null

# Try python3 first, then python
foreach ($cmd in @("python3", "python")) {
    try {
        $output = & $cmd --version 2>&1
        $exitCode = $LASTEXITCODE
        if ($exitCode -eq 0 -and $output -match "Python \d+\.\d+") {
            $pythonCmd = $cmd
            $pyVersion = $output.Trim()
            break
        }
    } catch {}
}

if ($pythonCmd) {
    Write-OK "Python found: $pyVersion ($pythonCmd)"
} else {
    Write-Fail "Python not found!"
    Write-Info "Please install Python 3.8+ from https://www.python.org/downloads/"
    Write-Info "Make sure to check 'Add Python to PATH' during installation."
    Write-Host ""
    pause
    exit 1
}

# ============================================================
# Step 2: Check pip
# ============================================================
Write-Title "Step 2: Check pip"

$pipOk = $false
try {
    $output = & $pythonCmd -m pip --version 2>&1
    $exitCode = $LASTEXITCODE
    if ($exitCode -eq 0 -and $output -match "pip") {
        Write-OK "pip available: $output"
        $pipOk = $true
    }
} catch {}

if (-not $pipOk) {
    Write-Fail "pip not available!"
    Write-Info "Try: $pythonCmd -m ensurepip --upgrade"
    Write-Host ""
    pause
    exit 1
}

# ============================================================
# Step 3: Install python-docx (.docx -> Markdown)
# ============================================================
Write-Title "Step 3: Check python-docx (.docx -> Markdown)"

$docxInstalled = $false
try {
    $output = & $pythonCmd -c "import docx; print(docx.__version__)" 2>&1
    $exitCode = $LASTEXITCODE
    if ($exitCode -eq 0 -and $output -match "\d+") {
        Write-Skip "Already installed (version $output)"
        $docxInstalled = $true
    }
} catch {}

if (-not $docxInstalled) {
    Write-Info "Installing python-docx ..."
    & $pythonCmd -m pip install python-docx --quiet 2>&1 | Out-Null
    $exitCode = $LASTEXITCODE

    # Verify installation
    if ($exitCode -eq 0) {
        try {
            $verify = & $pythonCmd -c "import docx; print(docx.__version__)" 2>&1
            if ($LASTEXITCODE -eq 0 -and $verify -match "\d+") {
                Write-OK "python-docx installed successfully (version $verify)"
            } else {
                Write-Fail "python-docx install appeared to succeed but import failed"
            }
        } catch {
            Write-Fail "python-docx install appeared to succeed but import failed"
        }
    } else {
        Write-Fail "Failed to install python-docx (pip exit code: $exitCode)"
    }
}

# ============================================================
# Step 4: Install pywin32 (.doc -> .docx, Windows only)
# ============================================================
Write-Title "Step 4: Check pywin32 (.doc -> .docx)"

if ($isWindows) {
    $win32Installed = $false
    try {
        $output = & $pythonCmd -c "import win32com.client; print('OK')" 2>&1
        $exitCode = $LASTEXITCODE
        if ($exitCode -eq 0 -and $output -match "OK") {
            Write-Skip "Already installed"
            $win32Installed = $true
        }
    } catch {}

    if (-not $win32Installed) {
        Write-Info "Installing pywin32 ..."
        & $pythonCmd -m pip install pywin32 --quiet 2>&1 | Out-Null
        $exitCode = $LASTEXITCODE

        # Verify installation
        if ($exitCode -eq 0) {
            try {
                $verify = & $pythonCmd -c "import win32com.client; print('OK')" 2>&1
                if ($LASTEXITCODE -eq 0 -and $verify -match "OK") {
                    Write-OK "pywin32 installed successfully"
                } else {
                    Write-Fail "pywin32 install appeared to succeed but import failed"
                }
            } catch {
                Write-Fail "pywin32 install appeared to succeed but import failed"
            }
        } else {
            Write-Fail "Failed to install pywin32 (pip exit code: $exitCode)"
        }
    }
} else {
    Write-Skip "Non-Windows OS, skipped"
    Write-Info ".docx conversion still works on all platforms"
}

# ============================================================
# Step 5: Check Word / WPS (for .doc conversion)
# ============================================================
Write-Title "Step 5: Check Word / WPS (for .doc conversion)"

if ($isWindows) {
    $hasWord = $false
    $hasWPS = $false
    $word = $null
    $wps = $null

    # Check Microsoft Word
    try {
        $word = New-Object -ComObject Word.Application
        $wordVersion = $word.Version
        $hasWord = $true
        Write-OK "Microsoft Word detected (version $wordVersion)"
    } catch {
        # Word not installed
    } finally {
        if ($word) {
            try { $word.Quit() } catch {}
            try { [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null } catch {}
            $word = $null
        }
    }

    # Check WPS (only if Word not found)
    if (-not $hasWord) {
        try {
            $wps = New-Object -ComObject Kwps.Application
            $hasWPS = $true
            Write-OK "WPS Office detected"
        } catch {
            # WPS not installed
        } finally {
            if ($wps) {
                try { $wps.Quit() } catch {}
                try { [System.Runtime.InteropServices.Marshal]::ReleaseComObject($wps) | Out-Null } catch {}
                $wps = $null
            }
        }
    }

    if (-not $hasWord -and -not $hasWPS) {
        Write-Skip "Neither Word nor WPS detected"
        Write-Info ".doc conversion requires Word or WPS to be installed"
        Write-Info "You can still use .docx and .md files without them"
    }
} else {
    Write-Skip "Non-Windows OS, skipped"
}

# ============================================================
# Step 6: Check conversion scripts exist
# ============================================================
Write-Title "Step 6: Check conversion scripts"

# Get script directory reliably
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
if (-not $scriptDir -or -not (Test-Path $scriptDir)) {
    # Fallback: use the directory of the current working script
    $scriptDir = Split-Path -Parent $PSCommandPath
}
if (-not $scriptDir -or -not (Test-Path $scriptDir)) {
    # Fallback: use current directory
    $scriptDir = Get-Location
}

$doc2docxPath = Join-Path $scriptDir "doc2docx.py"
$docx2mdPath  = Join-Path $scriptDir "docx2md.py"

if (Test-Path $doc2docxPath) {
    Write-OK "doc2docx.py found"
} else {
    Write-Fail "doc2docx.py not found in $scriptDir"
}

if (Test-Path $docx2mdPath) {
    Write-OK "docx2md.py found"
} else {
    Write-Fail "docx2md.py not found in $scriptDir"
}

# ============================================================
# Summary
# ============================================================
Write-Title "Summary"

Write-Host ""
Write-Host "  Required:" -ForegroundColor White
Write-Host "    - Code Agent platform (Trae / Claude Code / Codex)" -ForegroundColor Gray
Write-Host "    - Requirements doc (.md / .txt / .docx / .doc)" -ForegroundColor Gray
Write-Host ""
Write-Host "  Optional (for document conversion):" -ForegroundColor White
Write-Host "    - python-docx  : .docx -> .md" -ForegroundColor Gray
if ($isWindows) {
    Write-Host "    - pywin32      : .doc -> .docx (Windows only)" -ForegroundColor Gray
    Write-Host "    - Word / WPS   : needed by pywin32 for .doc files" -ForegroundColor Gray
}
Write-Host ""
Write-Host "  Quick start:" -ForegroundColor White
Write-Host "    1. Put your requirements doc in the 'input/' folder" -ForegroundColor Gray
Write-Host "    2. Open this repo in your Code Agent platform" -ForegroundColor Gray
Write-Host "    3. Tell the agent: 'Generate a project from my requirements doc'" -ForegroundColor Gray
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Setup complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

pause
