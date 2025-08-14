# 🎩 MagicZip

[![PowerShell](https://img.shields.io/badge/powershell-5.1+-blue.svg)](https://docs.microsoft.com/en-us/powershell/scripting/overview?view=powershell-7.2)

## ℹ️ About

MagicZip is a playful demonstration project of a *“magic”* compression technique using NTFS Alternate Data Streams (ADS).  
It **does NOT** actually compress data in the traditional sense. Instead, it splits the file into two parts:

- The first ~1% of the original file stays as the **main file** (visible and accessible normally).
- The remaining ~99% of the data is hidden inside an **Alternate Data Stream** attached to the same file.

This trick makes the main file appear much smaller, but the full data can be restored by recombining the ADS back into the main file.

> ✍️ **Author:** Miloš Perunović  
> 🗓️ **Date:** 2025-07-16

---

## ❔ Why MagicZip?

- To demonstrate how NTFS ADS works in practice.
- To teach about file streams and common misunderstandings about “infinite compression”.
- To show how metadata (or hidden streams) can be used for creative purposes.
- To warn about potential misuse or misunderstandings in compression claims.

---

## 🔧 Requirements

- Windows OS with NTFS file system.
- PowerShell 5.1 or newer.

---

## ⚙️ Usage

### 📦 Compress (split file into main + ADS)

```powershell
.\magiczip-compress.ps1 -file "path\to\your\file.ext"
```

This will:

- Shorten the main file to ~1% of its original size.
- Store the remaining data in the hidden ADS stream named hidden.

### 📦 Decompress (restore original file)

```powershell
.\magiczip-decompress.ps1 -file "path\to\your\file.ext"
```

This will:

- Read the main file and the hidden ADS.
- Merge them back into a single file restoring the original content.
- Remove the ADS stream.

---

## ⚠️ Important Notes

- This is a proof-of-concept / joke project, not a real compression tool.
- The data in the ADS is completely stored on the same NTFS volume and can be lost if the file is copied to a non-NTFS volume or transferred over some protocols.
- Some tools and antivirus software may not be aware of ADS streams and might flag or remove them.
- Handling ADS requires NTFS; this will not work on FAT, exFAT, or other file systems.
- Always backup your files before experimenting with ADS.

---

## ⚙️ How it works

NTFS supports alternate data streams, allowing multiple data "streams" within a single file entry. This project leverages that by moving part of the file’s data into an ADS, effectively hiding it from normal file size views and tools.

The compression script splits and stores the data:

- Main file: first ~1% bytes
- ADS (filename: hidden): remaining bytes

The decompression script reads both streams and concatenates them back.

---

## ⚠️ Disclaimer

MagicZip is provided as-is, for educational and demonstration purposes only. It should not be used for actual data compression or storage solutions.

---

## ⚖️ License

This project is free to use, share, and modify.

Enjoy the magic of NTFS ADS! 🎩✨
