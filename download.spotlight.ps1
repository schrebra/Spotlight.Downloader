param (
    [switch]$FullUpdate,
    [switch]$NoDownload,
    [string]$OutputDirectory = (Get-Location).Path,
    [int]$PageNumber = 1,
    [switch]$Update,
    [string]$Website = "https://windows10spotlight.com"
)

# Function to get a random user agent
function Get-RandomUserAgent {
    $userAgents = @(
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15"
    )
    return $userAgents | Get-Random
}

# Function to download spotlight image
function Download-SpotlightImage {
    param (
        [string]$ImageUrl
    )

    $urlParts = $ImageUrl -split '/'
    $postedYear = $urlParts[-3]
    $postedMonth = $urlParts[-2]
    $hashName = $urlParts[-1]

    # Remove resolution suffix if present
    $hashName = $hashName -replace '-\d+x\d+', ''

    if ($NoDownload) {
        Write-Host $ImageUrl
    }
    else {
        $jpgFileName = "$postedYear-$postedMonth-$hashName"
        $fullFilePath = Join-Path $OutputDirectory $jpgFileName

        if ($Update -and (Test-Path $fullFilePath) -and (Get-Item $fullFilePath).Length -ne 0) {
            Write-Host "Update finished"
            exit
        }
        elseif ($FullUpdate -and (Test-Path $fullFilePath) -and (Get-Item $fullFilePath).Length -ne 0) {
            Write-Host "Skipping existing file: $jpgFileName"
        }
        else {
            Write-Host "Downloading: $jpgFileName"
            Invoke-WebRequest -Uri $ImageUrl -OutFile $fullFilePath -UserAgent (Get-RandomUserAgent)
        }
    }
}

# Function to get HTML source code
function Get-HtmlSourceCode {
    param (
        [string]$Url
    )

    try {
        $response = Invoke-WebRequest -Uri $Url -UserAgent (Get-RandomUserAgent)
        return $response.Content
    }
    catch {
        Write-Host "[ERROR] Failed to retrieve the webpage: $_"
        exit 1
    }
}

# Function to browse Windows 10 Spotlight
function Browse-Windows10Spotlight {
    param (
        [string]$CurrentUrl
    )

    Write-Host "Grabbing: $CurrentUrl"

    $htmlContent = Get-HtmlSourceCode -Url $CurrentUrl

    # Extract image URLs
    $imageUrls = [regex]::Matches($htmlContent, 'https://windows10spotlight\.com/wp-content/uploads/\d{4}/\d{2}/[a-zA-Z0-9_-]+\.jpg') | ForEach-Object { $_.Value } | Select-Object -Unique

    # Group images by their base name (without resolution)
    $groupedImages = $imageUrls | Group-Object { ($_ -split '/')[-1] -replace '-\d+x\d+', '' }

    foreach ($group in $groupedImages) {
        # Sort by file size (assuming larger file = higher resolution)
        $highestResolution = $group.Group | Sort-Object {
            $response = Invoke-WebRequest -Uri $_ -Method Head -UserAgent (Get-RandomUserAgent)
            [long]$response.Headers.'Content-Length'
        } -Descending | Select-Object -First 1

        Download-SpotlightImage -ImageUrl $highestResolution
    }

    # Check for next page
    if ($htmlContent -match '<a class="next page-numbers" href="(.*?)"') {
        $nextPageUrl = $Matches[1]
        Browse-Windows10Spotlight -CurrentUrl $nextPageUrl
    }
}

# Main execution
if (-not (Test-Path $OutputDirectory)) {
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
}

$currentUrl = "$Website/page/$PageNumber"
Browse-Windows10Spotlight -CurrentUrl $currentUrl