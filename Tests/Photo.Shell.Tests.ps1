Clear-Host
Import-Module -Name Pester -Force
Import-Module .\Photo.Shell\Photo.Shell.psm1 -Force

function Get-TestImage {
    param (
        [Parameter(Mandatory = $false, Position = 0 )]
        [System.Drawing.Imaging.ImageFormat]$Format = [System.Drawing.Imaging.ImageFormat]::Png
    )
    $bitmap = [System.Drawing.Bitmap]::new(1000, 800, [System.Drawing.Imaging.PixelFormat]::Format32bppPArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $pen1 = [System.Drawing.Pen]::new([System.Drawing.Color]::FromKnownColor([System.Drawing.KnownColor]::Red), 2)
    $graphics.DrawEllipse($pen1, 10, 10, 900, 700)

    $result = [System.IO.MemoryStream]::new()
    $bitmap.Save($result, $Format)
    $result.ToArray()
}

Describe 'Photo.Shell.Tests' {
    Context "Get-ImageCodecInfo" {
        $testImage = Get-TestImage
        $codecInfo = Get-ImageCodecInfo $testImage

        It "should not be null" {
            $codecInfo | Should -Not -BeNullOrEmpty
        }

        It "should have valid type" {
            $codecInfo | Should -BeOfType [System.Drawing.Imaging.ImageCodecInfo]
        }

        It "given img.<Format>, it returns '<Expected>'" -TestCases @(
            @{ Format = [System.Drawing.Imaging.ImageFormat]::Png; Expected = 'image/png' }
            @{ Format = [System.Drawing.Imaging.ImageFormat]::Jpeg; Expected = 'image/jpeg' }
            @{ Format = [System.Drawing.Imaging.ImageFormat]::Bmp; Expected = 'image/bmp' }
            @{ Format = [System.Drawing.Imaging.ImageFormat]::Gif; Expected = 'image/gif' }
        ) {
            param ($Format, $Expected)
            $img = Get-TestImage -Format $Format
            Get-ImageCodecInfo $img | Select-Object -ExpandProperty MimeType  | Should -BeExactly $Expected
        }
    }
}