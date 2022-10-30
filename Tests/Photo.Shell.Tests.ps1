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

function Convert-BytesToImage {
    param (
        [byte[]]$testImage
    )

    $stream = [System.IO.MemoryStream]::new($testImage)
    [System.Drawing.Image]::FromStream($stream)

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

    Context "Resize-Image" {
        $testImage = Get-TestImage


        It "should resize and keep ratio - smaller" {
            # 1000 x 800
            $img_before = Convert-BytesToImage $testImage

            $img_after = Resize-Image -Image $testImage -Ratio 0.1 #10%
            $img_after = [System.Drawing.Image]::FromStream($img_after)

            $img_after.Width | Should -BeExactly ($img_before.Width * 0.1)
            $img_after.Height | Should -BeExactly ($img_before.Height * 0.1)
        }

        It "should resize and keep ratio - bigger" {
            # 1000 x 800
            $img_before = Convert-BytesToImage $testImage

            $img_after = Resize-Image -Image $testImage -Ratio 1.2 #120%
            $img_after = [System.Drawing.Image]::FromStream($img_after)

            $img_after.Width | Should -BeExactly ($img_before.Width * 1.2)
            $img_after.Height | Should -BeExactly ($img_before.Height * 1.2)
        }

        It "should resize to a given size" {
            $img_after = Resize-Image -Image $testImage -Width 200 -Height 200
            $img_after = [System.Drawing.Image]::FromStream($img_after)

            $img_after.Width | Should -BeExactly 200
            $img_after.Height | Should -BeExactly 200
        }

        It "should resize to a given size with ratio" {
            $img_after = Resize-Image -Image $testImage -Width 200 -Height 200 -ProportionalResize
            $img_after = [System.Drawing.Image]::FromStream($img_after)

            $img_after.Width | Should -BeExactly 200
            $img_after.Height | Should -BeExactly 160
        }
    }
}