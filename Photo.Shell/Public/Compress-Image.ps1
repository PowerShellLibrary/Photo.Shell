function Compress-Image {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0 )]
        $Image,
        [Parameter(Mandatory = $false, Position = 1 )]
        [System.Drawing.Imaging.ImageFormat]$Format,
        [Parameter(Mandatory = $false, Position = 2 )]
        [long]$Compression = 50L
    )

    begin {
        Write-Verbose "Cmdlet Compress-Image - Begin"
    }

    process {
        Write-Verbose "Cmdlet Compress-Image - Process"
        $isByte = Test-ByteArrayType $Image
        $isStream = Test-StreamType $Image

        if (!$isByte -and !$isStream ) {
            throw [System.ArgumentException]::new("Invalid input. Accepted types are: [System.IO.Stream] and [System.Byte[]]")
        }

        if ($Format) {
            $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | ? { $_.FormatID -eq $Format.Guid }
        }
        else {
            if ($isByte) {
                $codec = Get-ImageCodecInfo $Image
            }
            else {
                $codec = Get-ImageCodecInfo ($Image.ToArray())
            }
        }
        $parameters = [System.Drawing.Imaging.EncoderParameters]::new(1)
        $parameters.Param[0] = [System.Drawing.Imaging.EncoderParameter]::new([System.Drawing.Imaging.Encoder]::Quality, $Compression)

        [System.IO.Stream]$result = [System.IO.MemoryStream]::new()
        if ($isByte) {
            $stream = [System.IO.MemoryStream]::new($Image)
        }
        else {
            $stream = $Image
        }
        $img = [System.Drawing.Image]::FromStream($stream)
        $img.Save($result, $codec, $parameters)
        $result
    }

    end {
        Write-Verbose "Cmdlet Compress-Image - End"
    }
}