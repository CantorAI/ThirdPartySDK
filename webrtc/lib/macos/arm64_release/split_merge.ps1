param(
    [string]$Mode,
    [string]$File,
    [int]$PartSizeMB = 50
)

function Split-Compress {
    param([string]$File, [int]$PartSizeMB)

    $partSize = $PartSizeMB * 1MB
    $bufferSize = 4MB
    $buffer = New-Object byte[] $bufferSize

    $fs = [System.IO.File]::OpenRead($File)
    $partIndex = 0
    $bytesReadTotal = 0

    while ($fs.Position -lt $fs.Length) {
        $partFile = "{0}.part{1:D3}.zip" -f $File, $partIndex
        $partStream = New-Object System.IO.MemoryStream

        $bytesWritten = 0
        while ($bytesWritten -lt $partSize -and $fs.Position -lt $fs.Length) {
            $toRead = [Math]::Min($bufferSize, $partSize - $bytesWritten)
            $read = $fs.Read($buffer, 0, $toRead)
            if ($read -le 0) { break }
            $partStream.Write($buffer, 0, $read)
            $bytesWritten += $read
        }

        $partStream.Seek(0, 'Begin') | Out-Null

        # Compress part
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $zip = [System.IO.Compression.ZipFile]::Open($partFile, 'Create')
        $entry = $zip.CreateEntry([System.IO.Path]::GetFileName($File) + ".bin")
        $entryStream = $entry.Open()
        $partStream.Seek(0,'Begin') | Out-Null
        $partStream.CopyTo($entryStream)
        $entryStream.Close()
        $zip.Dispose()

        Write-Host "Created $partFile"
        $partStream.Dispose()
        $partIndex++
    }

    $fs.Close()
    Write-Host "Done. Created $partIndex parts."
}

function Decompress-Merge {
    param([string]$File)

    $outFile = [System.IO.Path]::GetFileName($File)
    $outStream = [System.IO.File]::Create($outFile)

    $partIndex = 0
    while ($true) {
        $partFile = "{0}.part{1:D3}.zip" -f $File, $partIndex
        if (-not (Test-Path $partFile)) { break }

        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $zip = [System.IO.Compression.ZipFile]::OpenRead($partFile)
        foreach ($entry in $zip.Entries) {
            $entryStream = $entry.Open()
            $entryStream.CopyTo($outStream)
            $entryStream.Close()
        }
        $zip.Dispose()

        Write-Host "Merged $partFile"
        $partIndex++
    }

    $outStream.Close()
    Write-Host "Done. Restored as $outFile"
}

if ($Mode -ieq "split") {
    Split-Compress -File $File -PartSizeMB $PartSizeMB
} elseif ($Mode -ieq "merge") {
    Decompress-Merge -File $File
} else {
    Write-Host "Invalid mode. Use 'split' or 'merge'."
}
