#requires -Version 5.1

<#
.SYNOPSIS
    This script decompresses a file by restoring its original size from an Alternate Data Stream (ADS).
.DESCRIPTION
    The script takes a file, reads the main content and the excess data stored in a hidden ADS named "hidden", and merges them back to restore the original file size.
.PARAMETER file
    The path to the file to be decompressed. This parameter is mandatory.
.EXAMPLE
    .\magiczip-decompress.ps1 -file "C:\path\to\your\file.txt"
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

Write-Host "`n📦 Starting decompression for file: $file"

Write-Host "Using file path: $file"

$adsPath = "${file}:hidden"
Write-Host "Using ADS path: $adsPath"

$adsExists = $false
try {
    Get-Item -Path $adsPath -ErrorAction Stop | Out-Null
    $adsExists = $true
}
catch {
    $adsExists = $false
}

if (-not $adsExists) {
    Write-Host "No ADS stream found. Nothing to decompress."
    exit
}

# Reading the main file and ADS stream
[byte[]]$mainContent = [System.IO.File]::ReadAllBytes($file)
[byte[]]$adsContent = Get-Content -Path $adsPath -Encoding Byte -Raw

Write-Host "Main file size: $($mainContent.Length) bytes"
Write-Host "ADS stream size: $($adsContent.Length) bytes"

# Merging contents
[byte[]]$fullContent = New-Object byte[] ($mainContent.Length + $adsContent.Length)
[System.Buffer]::BlockCopy($mainContent, 0, $fullContent, 0, $mainContent.Length)
[System.Buffer]::BlockCopy($adsContent, 0, $fullContent, $mainContent.Length, $adsContent.Length)

# Writing the complete data back to the file
[System.IO.File]::WriteAllBytes($file, $fullContent)
Write-Host "File decompressed successfully to original size: $($fullContent.Length) bytes"

# Remove the ADS stream if it exists
try {
    Get-Item -Path $adsPath -ErrorAction Stop | Out-Null
    Remove-Item -Path $adsPath -ErrorAction Stop
}
catch {
}

Write-Host "🎩✨ Magic decompression complete. 🎉`n"
