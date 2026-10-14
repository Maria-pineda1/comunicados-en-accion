param(
  [int]$Quality = 82,
  [int]$MaxWidth = 1600
)

Add-Type -AssemblyName System.Drawing
Set-Location $PSScriptRoot

$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$encParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]$Quality)

$pngs = Get-ChildItem -Filter '*.png' | Where-Object { $_.BaseName -match '^\d+$' }
$hechas = 0

foreach ($p in $pngs) {
  $out = Join-Path $PSScriptRoot ($p.BaseName + '.jpg')
  if (Test-Path $out) { continue }

  $src = [System.Drawing.Image]::FromFile($p.FullName)
  try {
    $w = $src.Width; $h = $src.Height
    if ($w -gt $MaxWidth) { $h = [int]($h * $MaxWidth / $w); $w = $MaxWidth }
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.Clear([System.Drawing.Color]::White)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($src, 0, 0, $w, $h)
    $g.Dispose()
    $bmp.Save($out, $codec, $encParams)
    $bmp.Dispose()
    $hechas++
  } finally {
    $src.Dispose()
  }
}

$mbJpg = [math]::Round(((Get-ChildItem -Filter '*.jpg' | Measure-Object Length -Sum).Sum) / 1MB, 1)
Write-Output "Imagenes convertidas: $hechas | Peso total JPG: $mbJpg MB"
