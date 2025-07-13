#requires -Version 5.1

<#
.SYNOPSIS
    This script compresses a file by reducing its size and storing the excess data in an Alternate Data Stream (ADS).
.DESCRIPTION
    The script takes a file, compresses it to approximately 1% of its original size, and stores the remaining data in a hidden ADS named "hidden". This simulates a form of compression using NTFS features.
.PARAMETER file
    The path to the file to be compressed. This parameter is mandatory.
.EXAMPLE
    .\magiczip-compress.ps1 -file "C:\path\to\your\file.txt"
.NOTES
    This script is for educational purposes and demonstrates the use of NTFS Alternate Data Streams.
#>

param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$file
)

if ([string]::IsNullOrWhiteSpace($file)) {
    Write-Error "ERROR: File parameter is missing or empty."
    exit
}

if (-not [System.IO.Path]::IsPathRooted($file)) {
    $file = Join-Path -Path (Get-Location) -ChildPath $file
}

if (-not (Test-Path $file)) {
    Write-Error "ERROR: File does not exist: $file"
    exit
}

Write-Host "`n📦 Starting compression for file: $file"

Write-Host "Using file path: $file"

$adsPath = "${file}:hidden"
Write-Host "Using ADS path: $adsPath"

# Reading the original file content
[byte[]]$content = [System.IO.File]::ReadAllBytes($file)
$originalSize = $content.Length
Write-Host "Original file size: $originalSize bytes"

if ($originalSize -eq 0) {
    Write-Host "File is empty, nothing to compress."
    exit
}

$targetSize = [Math]::Max([int]([Math]::Ceiling($originalSize * 0.01)), 1)
Write-Host "Compressing to 1% of original size: $targetSize bytes"

# Ensure the target size is not larger than the original content
$mainContent = $content[0..($targetSize - 1)]
if ($originalSize -gt $targetSize) {
    $adsContent = $content[$targetSize..($originalSize - 1)]
}
else {
    $adsContent = @()
}

# Writing the main content back to the file
[System.IO.File]::WriteAllBytes($file, $mainContent)
Write-Host "Main file written with $($mainContent.Length) bytes."

if ($adsContent.Count -gt 0) {
    Set-Content -Path $adsPath -Value $adsContent -Encoding Byte
    Write-Host "ADS stream written with $($adsContent.Length) bytes."
}
else {
    if (Test-Path $adsPath) {
        Remove-Item $adsPath
    }
}

Write-Host "🎩✨ Magic compression complete. 🎉`n"
Write-Host "Total size now: $(($mainContent.Length) + ($adsContent.Length)) bytes (main file + ADS)"
