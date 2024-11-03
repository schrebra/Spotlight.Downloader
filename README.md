
# Spotlight Image Downloader

## Overview
This PowerShell script downloads Spotlight images from windows10spotlight.com. It can download images in bulk while managing duplicates and updates.

## Key Features
- Downloads high-resolution Windows 10 Spotlight images
- Supports incremental updates
- Handles pagination automatically
- Uses random user agents to prevent blocking
- Organizes images by year and month
- Supports various operation modes

## Parameters
- `-FullUpdate`: Performs a full update while skipping existing files
- `-NoDownload`: Only displays image URLs without downloading
- `-OutputDirectory`: Specifies where to save images (defaults to current directory)
- `-PageNumber`: Starting page number for downloads (defaults to 1)
- `-Update`: Stops when finding an existing file
- `-Website`: Source website URL (defaults to windows10spotlight.com)

## Main Functions
1. `Get-RandomUserAgent`
   - Randomly selects a user agent string to mimic different browsers
   - Helps prevent website blocking

2. `Download-SpotlightImage`
   - Downloads individual images
   - Names files using format: YEAR-MONTH-FILENAME.jpg
   - Handles update modes and duplicate checking

3. `Get-HtmlSourceCode`
   - Retrieves webpage content
   - Handles errors during webpage retrieval

4. `Browse-Windows10Spotlight`
   - Main crawler function
   - Extracts image URLs from pages
   - Finds highest resolution versions of images
   - Handles pagination automatically

## Operation Flow
1. Validates output directory
2. Starts from specified page number
3. Downloads images page by page
4. For each image:
   - Finds highest resolution version
   - Creates year-month based filename
   - Downloads if conditions are met
5. Continues to next page until complete

## Usage Examples
```powershell
# Basic download to current directory
.\download.spotlight.ps1

# Download to specific directory
.\download.spotlight.ps1 -OutputDirectory "C:\Spotlight"

# Update mode - stop on first existing file
.\download.spotlight.ps1 -Update

# Show URLs only
.\download.spotlight.ps1 -NoDownload
