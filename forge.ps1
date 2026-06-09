# ============================================================
# GearFactory v1.1
# ============================================================
param(
    [string]$PaletteName = "ruby",
    [string]$Shape = "vanilla",
    [string]$ItemName = "all",
    [switch]$ListPalettes,
    [switch]$ListShapes
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$EngineRoot = "D:/MC/fabric-mod-dev/forge_engine"
$TemplateDir = "$EngineRoot/templates"
$OutputBase = "$EngineRoot/output"
$PaletteFile = "$EngineRoot/palettes.json"
$ProjectAssets = "D:/MC/fabric-mod-dev/src/main/resources/assets/modid/textures"

function HexToColor($hex) {
    $h = $hex -replace '#', ''
    return [Drawing.Color]::FromArgb(255,
        [Convert]::ToInt32($h.Substring(0,2), 16),
        [Convert]::ToInt32($h.Substring(2,2), 16),
        [Convert]::ToInt32($h.Substring(4,2), 16))
}

$palData = Get-Content $PaletteFile -Raw | ConvertFrom-Json
$names = $palData.PSObject.Properties.Name
if ($ListPalettes) { foreach ($n in $names) { Write-Host $n }; exit 0 }
if ($ListShapes) { Get-ChildItem "$TemplateDir/shapes" -Directory | % { Write-Host $_.Name }; exit 0 }
if ($PaletteName -notin $names) { Write-Error "Unknown: $PaletteName"; exit 1 }

$pal = $palData.$PaletteName
$matPal = @(
    (HexToColor $pal.outline),
    (HexToColor $pal.shadow),
    (HexToColor $pal.dark),
    (HexToColor $pal.base),
    (HexToColor $pal.mid),
    (HexToColor $pal.light),
    (HexToColor $pal.shine),
    (HexToColor $pal.sparkle)
)
$hanPal = @(
    (HexToColor $pal.h_dark),
    (HexToColor $pal.h_base),
    (HexToColor $pal.h_light)
)

function Forge($srcFile, $dstFile, $label) {
    if (!(Test-Path $srcFile)) { Write-Host "  [!] Missing: $srcFile"; return }
    $bmp = [Drawing.Bitmap]::FromFile($srcFile)

    # Collect unique brightness values
    $matVals = @{}
    $hanVals = @{}
    for ($y = 0; $y -lt $bmp.Height; $y++) {
        for ($x = 0; $x -lt $bmp.Width; $x++) {
            $px = $bmp.GetPixel($x, $y)
            if ($px.A -eq 0) { continue }
            $r = $px.R; $g = $px.G; $b2 = $px.B
            $v = [int](($r + $g + $b2) / 3)
            $isH = ($r -gt $b2) -and ($r -gt $g) -and ($b2 -lt 100) -and ($r -gt 50)
            if ($isH) { $hanVals[$v] = 1 } else { $matVals[$v] = 1 }
        }
    }

    # Build value-to-color maps
    $matMap = @{}
    $matSorted = $matVals.Keys | Sort-Object
    $mc = @($matSorted).Count
    if ($mc -gt 0) {
        for ($i = 0; $i -lt $mc; $i++) {
            $idx = [Math]::Min(7, [Math]::Floor($i * 8 / $mc))
            $matMap[$matSorted[$i]] = $matPal[$idx]
        }
    }
    $hanMap = @{}
    $hanSorted = $hanVals.Keys | Sort-Object
    $hc = @($hanSorted).Count
    if ($hc -gt 0) {
        for ($i = 0; $i -lt $hc; $i++) {
            $idx = [Math]::Min(2, [Math]::Floor($i * 3 / $hc))
            $hanMap[$hanSorted[$i]] = $hanPal[$idx]
        }
    }

    # Apply colors
    for ($y = 0; $y -lt $bmp.Height; $y++) {
        for ($x = 0; $x -lt $bmp.Width; $x++) {
            $px = $bmp.GetPixel($x, $y)
            if ($px.A -eq 0) { continue }
            $r = $px.R; $g = $px.G; $b2 = $px.B
            $v = [int](($r + $g + $b2) / 3)
            $isH = ($r -gt $b2) -and ($r -gt $g) -and ($b2 -lt 100) -and ($r -gt 50)
            $nc = $null
            if ($isH) { $nc = $hanMap[$v] } else { $nc = $matMap[$v] }
            if ($nc -ne $null) { $bmp.SetPixel($x, $y, $nc) }
        }
    }

    # Save
    $dstDir = Split-Path $dstFile -Parent
    if (!(Test-Path $dstDir)) { New-Item -ItemType Directory -Force -Path $dstDir | Out-Null }
    $bmp.Save($dstFile, [Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "  [+] $label"
}

$itemNames = @("sword","pickaxe","axe","shovel","hoe","helmet","chestplate","leggings","boots")
$equipNames = @("humanoid","humanoid_leggings")
$shapeDir = "$TemplateDir/shapes/$Shape"
if (!(Test-Path $shapeDir)) { Write-Error "Shape not found: $Shape"; exit 1 }

# 形状前缀映射 (不同来源用不同文件名前缀)
$prefixes = @("diamond", "copper", "iron", "golden", "netherite", "stone", "wooden")

Write-Host "GearFactory v1.1: $PaletteName / $Shape"

foreach ($n in $itemNames) {
    if ($ItemName -ne "all" -and $ItemName -ne $n) { continue }
    # 尝试多个前缀查找文件
    $src = $null
    foreach ($pfx in $prefixes) {
        $candidate = "$shapeDir/${pfx}_$n.png"
        if (Test-Path $candidate) { $src = $candidate; break }
    }
    # 回退: 直接用物品名
    if ($src -eq $null) { $src = "$shapeDir/${n}.png" }
    if (!(Test-Path $src)) { continue }
    Forge $src "$OutputBase/$PaletteName/item/${PaletteName}_$n.png" "$PaletteName/$n"
    Forge $src "$ProjectAssets/item/ruby_$n.png" "$PaletteName/$n -> project"
}
foreach ($n in $equipNames) {
    if ($ItemName -ne "all" -and $ItemName -ne $n) { continue }
    # 优先用形状源里的装备纹理
    $src = $null
    foreach ($pfx in $prefixes) {
        $candidate = "$shapeDir/${pfx}.png"
        if (Test-Path $candidate -and $n -eq "humanoid") { $src = $candidate; break }
    }
    if ($src -eq $null) { $src = "$shapeDir/${n}.png" }
    if (!(Test-Path $src)) { $src = "$TemplateDir/equipment/$n.png" }
    if (!(Test-Path $src)) { continue }
    $dstDir = "entity/equipment/$n"
    Forge $src "$OutputBase/$PaletteName/equipment/$n/${PaletteName}.png" "$PaletteName/$n"
    Forge $src "$ProjectAssets/$dstDir/ruby.png" "$PaletteName/$n -> project"
}
Write-Host "Done!"
