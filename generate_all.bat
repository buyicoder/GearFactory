@echo off
REM GearFactory - Generate all 20 palettes
for %%p in (ruby sapphire emerald amethyst topaz obsidian silver rose_gold coral amber jade crimson ocean forest inferno frost shadow celestial thunder onyx) do (
    echo === %%p ===
    powershell -ExecutionPolicy Bypass -File "forge.ps1" -PaletteName %%p
)
echo Done!
