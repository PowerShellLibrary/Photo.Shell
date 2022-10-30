# Table of file signatures (aka "magic numbers")
# https://www.garykessler.net/library/file_sigs.html
function Get-ImageCodecInfo {
    [CmdletBinding()]
    param (
        # [byte[]] or [System.IO.Stream]
        [Parameter(Mandatory = $true, Position = 0 )]
        $Image
    )

    begin {
        Write-Verbose "Cmdlet Get-ImageCodecInfo - Begin"
    }

    process {
        Write-Verbose "Cmdlet Get-ImageCodecInfo - Process"

        if ($Image.PSTypeNames -contains [System.IO.Stream]) {
            $Image = $Image.ToArray()
        }

        [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | ? {
            [byte[]]$pattern = $_.SignaturePatterns  | Select-Object -First 1
            [byte[]]$header = $Image  | Select-Object -First $pattern.Length
            [System.Linq.Enumerable]::SequenceEqual([byte[]]$pattern, [byte[]]$header)
        } | Select-Object -First 1
    }

    end {
        Write-Verbose "Cmdlet Get-ImageCodecInfo - End"
    }
}