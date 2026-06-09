# Extract vanilla diamond textures from your Minecraft installation
# Run this once to set up the template library

param([string]$MinecraftVersion = "1.21.11")

$mcJar = "$env:USERPROFILE\.gradle\caches\fabric-loom\$MinecraftVersion\minecraft-client-only.jar"

if (!(Test-Path $mcJar)) {
    Write-Host "Minecraft jar not found at: $mcJar"
    Write-Host "Make sure you've run Minecraft at least once with Fabric."
    Write-Host "Or specify a custom path: .\extract_templates.ps1 -JarPath <path>"
    exit 1
}

$items = @("diamond_sword","diamond_pickaxe","diamond_axe","diamond_shovel","diamond_hoe",
           "diamond_helmet","diamond_chestplate","diamond_leggings","diamond_boots")
$equip = @("humanoid","humanoid_leggings")

Write-Host "Extracting from: $mcJar"

# Extract item textures
foreach ($item in $items) {
    $cmd = "unzip -o `"$mcJar`" `"assets/minecraft/textures/item/$item.png`" -d ."
    Invoke-Expression $cmd
    if (Test-Path "assets/minecraft/textures/item/$item.png") {
        Move-Item "assets/minecraft/textures/item/$item.png" "templates/item/$item.png" -Force
        Write-Host "  [+] $item"
    }
}

# Extract equipment textures  
foreach ($eq in $equip) {
    $cmd = "unzip -o `"$mcJar`" `"assets/minecraft/textures/entity/equipment/$eq/diamond.png`" -d ."
    Invoke-Expression $cmd
    if (Test-Path "assets/minecraft/textures/entity/equipment/$eq/diamond.png") {
        Move-Item "assets/minecraft/textures/entity/equipment/$eq/diamond.png" "templates/equipment/$eq.png" -Force
        Write-Host "  [+] $eq"
    }
}

# Cleanup
if (Test-Path "assets") { Remove-Item "assets" -Recurse -Force }

Write-Host ""
Write-Host "Templates extracted! Run .\forge.ps1 -PaletteName ruby to test."
