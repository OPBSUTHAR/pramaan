# Draws Pramaan's app icon at every density the Android and web builds need.
# Pure System.Drawing — no design tool, no binary asset in the repo history.
#
#   powershell -ExecutionPolicy Bypass -File scripts/make_icons.ps1
#
# The mark: a saffron tile with the shield-and-tick from the in-app PramaanMark.

Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$app = Join-Path $root 'app'

function New-PramaanIcon {
    param([int]$Size, [string]$Path, [switch]$Maskable)

    $bmp = New-Object System.Drawing.Bitmap($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)

    $s = [double]$Size
    $pad = if ($Maskable) { 0.0 } else { 0.0 }

    # Tile: rounded square with the brand gradient.
    $radius = if ($Maskable) { 0.0 } else { $s * 0.22 }
    $rect = New-Object System.Drawing.RectangleF(0, 0, [float]$s, [float]$s)
    $tile = New-Object System.Drawing.Drawing2D.GraphicsPath
    if ($radius -le 0) {
        $tile.AddRectangle($rect)
    } else {
        $d = [float]($radius * 2)
        $tile.AddArc(0, 0, $d, $d, 180, 90)
        $tile.AddArc([float]($s - $d), 0, $d, $d, 270, 90)
        $tile.AddArc([float]($s - $d), [float]($s - $d), $d, $d, 0, 90)
        $tile.AddArc(0, [float]($s - $d), $d, $d, 90, 90)
        $tile.CloseFigure()
    }
    $grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $rect,
        [System.Drawing.Color]::FromArgb(255, 0xFF, 0x9F, 0x1C),
        [System.Drawing.Color]::FromArgb(255, 0xE0, 0x7B, 0x00),
        45.0)
    $g.FillPath($grad, $tile)

    # Shield + tick, scaled up around the centre.
    $scale = if ($Maskable) { 1.16 } else { 1.45 }
    $cx = $s / 2
    $cy = $s / 2
    function P([double]$x, [double]$y) {
        return New-Object System.Drawing.PointF(
            [float]($cx + ($x - 0.5) * $s * $scale),
            [float]($cy + ($y - 0.5) * $s * $scale))
    }

    $ink = [System.Drawing.Color]::FromArgb(255, 0x1A, 0x12, 0x00)
    $pen = New-Object System.Drawing.Pen($ink, [float]($s * 0.085))
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

    $shield = New-Object System.Drawing.Drawing2D.GraphicsPath
    $p0 = P 0.5 0.2;  $p1 = P 0.76 0.3; $p2 = P 0.76 0.52
    $p3 = P 0.63 0.78; $p4 = P 0.5 0.84
    $p5 = P 0.37 0.78; $p6 = P 0.24 0.68; $p7 = P 0.24 0.52; $p8 = P 0.24 0.3
    $shield.AddLine($p0, $p1)
    $shield.AddLine($p1, $p2)
    $shield.AddBezier($p2, $p3, $p4, $p4)
    $shield.AddBezier($p4, $p5, $p6, $p7)
    $shield.AddLine($p7, $p8)
    $shield.CloseFigure()
    $g.DrawPath($pen, $shield)

    $tick = New-Object System.Drawing.Drawing2D.GraphicsPath
    $tick.AddLine((P 0.37 0.5), (P 0.46 0.59))
    $tick.AddLine((P 0.46 0.59), (P 0.64 0.4))
    $g.DrawPath($pen, $tick)

    $g.Dispose()
    $bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
}

$densities = @{
    'mipmap-mdpi'    = 48
    'mipmap-hdpi'    = 72
    'mipmap-xhdpi'   = 96
    'mipmap-xxhdpi'  = 144
    'mipmap-xxxhdpi' = 192
}

foreach ($key in $densities.Keys) {
    $dir = Join-Path $app "android\app\src\main\res\$key"
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    New-PramaanIcon -Size $densities[$key] -Path (Join-Path $dir 'ic_launcher.png')
    Write-Host "  android $key ($($densities[$key])px)"
}

$webIcons = Join-Path $app 'web\icons'
if (-not (Test-Path $webIcons)) { New-Item -ItemType Directory -Path $webIcons -Force | Out-Null }

New-PramaanIcon -Size 512 -Path (Join-Path $webIcons 'Icon-512.png')
New-PramaanIcon -Size 192 -Path (Join-Path $webIcons 'Icon-192.png')
New-PramaanIcon -Size 512 -Path (Join-Path $webIcons 'Icon-maskable-512.png') -Maskable
New-PramaanIcon -Size 192 -Path (Join-Path $webIcons 'Icon-maskable-192.png') -Maskable
New-PramaanIcon -Size 64  -Path (Join-Path $app 'web\favicon.png')

Write-Host "Icons written."
