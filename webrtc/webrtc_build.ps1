param(
    [switch]$CopyIncludes = $true
)

# Use current directory as parent for webrtc_build
$currentDir = Get-Location
$webrtcBuildDir = Join-Path $currentDir "webrtc_build"
$srcDir = Join-Path $webrtcBuildDir "src"
$outDir = Join-Path $webrtcBuildDir "out"
$includeDir = Join-Path $webrtcBuildDir "include"

Write-Host "Working directory: $currentDir" -ForegroundColor Green
Write-Host "WebRTC build directory: $webrtcBuildDir" -ForegroundColor Green
Write-Host "Output directory: $outDir" -ForegroundColor Green
if ($CopyIncludes) {
    Write-Host "Include directory: $includeDir" -ForegroundColor Green
}

# Check if src directory already exists
$srcExists = Test-Path $srcDir
if ($srcExists) {
    Write-Host "`nWebRTC source code already exists at: $srcDir" -ForegroundColor Yellow
    Write-Host "Skipping depot_tools setup and source code download..." -ForegroundColor Yellow
    Write-Host "Proceeding directly to build..." -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host "`nWebRTC source code not found. Will download..." -ForegroundColor Cyan
    
    # Install depot_tools to home directory
    Set-Location $HOME
    if (-not (Test-Path "depot_tools")) {
        Write-Host "Cloning depot_tools..." -ForegroundColor Cyan
        git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
    } else {
        Write-Host "depot_tools already exists, skipping clone..." -ForegroundColor Yellow
    }

    # Add depot_tools to PATH for current session
    $env:PATH = "$HOME\depot_tools;$env:PATH"
    $env:DEPOT_TOOLS_WIN_TOOLCHAIN = "0"

    # Add depot_tools to PATH permanently
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*depot_tools*") {
        Write-Host "Adding depot_tools to PATH..." -ForegroundColor Cyan
        [Environment]::SetEnvironmentVariable(
            "Path",
            "$HOME\depot_tools;$currentPath",
            "User"
        )
    }

    # Set environment variable to use local Visual Studio installation
    [Environment]::SetEnvironmentVariable(
        "DEPOT_TOOLS_WIN_TOOLCHAIN",
        "0",
        "User"
    )

    # Create WebRTC workspace in current directory
    New-Item -ItemType Directory -Force -Path $webrtcBuildDir | Out-Null
    Set-Location $webrtcBuildDir

    # Fetch WebRTC source code
    Write-Host "Fetching WebRTC source code..." -ForegroundColor Cyan
    fetch --nohooks webrtc

    Set-Location $srcDir

    # Sync all dependencies
    Write-Host "Syncing dependencies..." -ForegroundColor Cyan
    gclient sync
}

# Ensure we're in the src directory for build
Set-Location $srcDir

# Ensure depot_tools is in PATH (needed even if src exists)
if (-not ($env:PATH -like "*depot_tools*")) {
    $env:PATH = "$HOME\depot_tools;$env:PATH"
    $env:DEPOT_TOOLS_WIN_TOOLCHAIN = "0"
}

# Create out directory at webrtc_build level (sibling to src)
$releaseDir = Join-Path $outDir "Release"
New-Item -ItemType Directory -Force -Path $releaseDir | Out-Null

# Generate build files - output to webrtc_build/out/Release
Write-Host "Generating build files..." -ForegroundColor Cyan
gn gen $releaseDir --args='
  is_debug=false
  target_os=\"win\"
  target_cpu=\"x64\"
  rtc_include_tests=false
  rtc_build_examples=false
  rtc_build_tools=false
  use_rtti=true
  treat_warnings_as_errors=false
  rtc_enable_protobuf=false
  rtc_use_h264=true
  proprietary_codecs=true
  is_clang=false
'

# Build WebRTC library
Write-Host "Building WebRTC (this may take 30-90 minutes)..." -ForegroundColor Cyan
ninja -C $releaseDir webrtc

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nBuild completed successfully!" -ForegroundColor Green
    
    # Copy includes if flag is set
    if ($CopyIncludes) {
        Write-Host "`nCopying header files to include directory..." -ForegroundColor Cyan
        Write-Host "This will scan all directories for header files (.h, .hpp, .inc)..." -ForegroundColor Cyan
        
        # Create include directory structure
        New-Item -ItemType Directory -Force -Path $includeDir | Out-Null
        
        # Define directories to exclude (build outputs, tests, examples, etc.)
        $excludeDirs = @(
            "out",
            "build",
            ".git",
            "examples",
            "test",
            "tests",
            "testing",
            "tools\mb",
            "tools\clang",
            "buildtools",
            "third_party\llvm-build",
            "third_party\android_",
            "third_party\depot_tools"
        )
        
        # Copy all header files from src directory
        Write-Host "Scanning for header files in WebRTC source..." -ForegroundColor Gray
        
        $headerFiles = Get-ChildItem -Path $srcDir -Recurse -Include *.h,*.hpp,*.inc -File | Where-Object {
            $filePath = $_.FullName
            $relativePath = $filePath.Substring($srcDir.Length + 1)
            
            # Check if file is in any excluded directory
            $shouldExclude = $false
            foreach ($excludeDir in $excludeDirs) {
                if ($relativePath -like "$excludeDir\*" -or $relativePath -like "*\$excludeDir\*") {
                    $shouldExclude = $true
                    break
                }
            }
            
            # Also exclude test-related files by name pattern
            if ($_.Name -like "*_test.h" -or 
                $_.Name -like "*_unittest.h" -or 
                $_.Name -like "test_*.h" -or
                $_.Name -like "mock_*.h" -or
                $_.Name -like "*_mock.h") {
                $shouldExclude = $true
            }
            
            -not $shouldExclude
        }
        
        $totalFiles = $headerFiles.Count
        $copiedFiles = 0
        
        Write-Host "Found $totalFiles header files to copy..." -ForegroundColor Cyan
        
        foreach ($file in $headerFiles) {
            $relativePath = $file.FullName.Substring($srcDir.Length + 1)
            $destPath = Join-Path $includeDir $relativePath
            $destFolder = Split-Path -Parent $destPath
            
            # Create destination directory if it doesn't exist
            if (-not (Test-Path $destFolder)) {
                New-Item -ItemType Directory -Force -Path $destFolder | Out-Null
            }
            
            # Copy the file
            Copy-Item $file.FullName -Destination $destPath -Force
            
            $copiedFiles++
            
            # Show progress every 100 files
            if ($copiedFiles % 100 -eq 0) {
                Write-Host "  Copied $copiedFiles / $totalFiles files..." -ForegroundColor Gray
            }
        }
        
        Write-Host "Successfully copied $copiedFiles header files!" -ForegroundColor Green
        Write-Host "Header files location: $includeDir" -ForegroundColor Green
        
        # Show summary of top-level directories copied
        Write-Host "`nTop-level directories included:" -ForegroundColor Cyan
        $topDirs = Get-ChildItem -Path $includeDir -Directory | Select-Object -ExpandProperty Name | Sort-Object
        foreach ($dir in $topDirs) {
            $fileCount = (Get-ChildItem -Path (Join-Path $includeDir $dir) -Recurse -Include *.h,*.hpp,*.inc -File).Count
            Write-Host "  $dir ($fileCount files)" -ForegroundColor Gray
        }
    }
    
    Write-Host "`nBuild artifacts location:" -ForegroundColor Cyan
    Write-Host "  Libraries: $releaseDir" -ForegroundColor White
    if ($CopyIncludes) {
        Write-Host "  Headers: $includeDir" -ForegroundColor White
    }
} else {
    Write-Host "`nBuild failed with error code: $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}
