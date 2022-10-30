function Resize-Image {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [byte[]]$Image,
        [Parameter(Mandatory = $false, ParameterSetName = "Sizes")]
        [switch]$ProportionalResize = $false,
        [Parameter(Mandatory = $true, ParameterSetName = "Sizes")]
        [int32]$Width,
        [Parameter(Mandatory = $true, ParameterSetName = "Sizes")]
        [int32]$Height,
        [Parameter(Mandatory = $true, ParameterSetName = "Ratio")]
        [decimal]$Ratio = 0.5
    )

    begin {
        Write-Verbose "Cmdlet Resize-Image - Begin"
    }

    process {
        Write-Verbose "Cmdlet Resize-Image - Process"

        $stream = [System.IO.MemoryStream]::new($Image)
        $img = [System.Drawing.Image]::FromStream($stream)

        if ($PSCmdlet.ParameterSetName -eq 'Sizes') {
            $ratioX = $Width / $img.Width;
            $ratioY = $Height / $img.Height;
            $ratio = [System.Math]::Min($ratioX, $ratioY);
        }

        $autoRatio = $PSCmdlet.ParameterSetName -eq 'Ratio'
        [int32]$newWidth = if ($ProportionalResize -or $autoRatio) { $img.Width * $ratio } Else { $Width }
        [int32]$newHeight = if ($ProportionalResize -or $autoRatio) { $img.Height * $ratio } Else { $Height }

        $destImage = New-Object System.Drawing.Bitmap($newWidth, $newHeight)

        $graphics = [System.Drawing.Graphics]::FromImage($destImage)
        $graphics.DrawImage($img, 0, 0, $newWidth, $newHeight)
        $graphics.Dispose()

        $stream2 = [System.IO.MemoryStream]::new()
        $destImage.Save($stream2, [System.Drawing.Imaging.ImageFormat]::Png)
        $stream2
    }

    end {
        Write-Verbose "Cmdlet Resize-Image - End"
    }
}