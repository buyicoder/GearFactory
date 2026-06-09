# GearFactory — Minecraft Equipment Texture Engine

Generate thousands of unique Minecraft tool and armor textures from base templates + color palettes.

##  Quick Start

```powershell
# Generate ruby set (default)
.\forge.ps1

# Generate a specific palette
.\forge.ps1 -PaletteName sapphire

# List all 20 palettes
.\forge.ps1 -ListPalettes

# Generate ALL palettes
.\generate_all.bat
```

## How It Works

```
Vanilla Template (diamond shape) + Palette (ruby colors) = Custom Texture
        16x16 PNG                       JSON                 16x16 PNG
```

1. Scans the vanilla texture to find every unique brightness level
2. Maps each level linearly to 8 palette colors (outline/shadow/dark/base/mid/light/shine/sparkle)
3. Separately maps handle/brown pixels to 3 handle colors

## Palettes (20 included)

`ruby` `sapphire` `emerald` `amethyst` `topaz` `obsidian` `silver` `rose_gold` `coral` `amber` `jade` `crimson` `ocean` `forest` `inferno` `frost` `shadow` `celestial` `thunder` `onyx`

Each palette has 11 color stops: 8 material levels + 3 handle levels.

## Adding Your Own Palette

Edit `palettes.json`, add a new entry:

```json
"my_color": {
  "outline": "#...", "shadow": "#...", "dark": "#...",
  "base": "#...", "mid": "#...", "light": "#...",
  "shine": "#...", "sparkle": "#...",
  "h_dark": "#...", "h_base": "#...", "h_light": "#..."
}
```

Then run: `.\forge.ps1 -PaletteName my_color`

**Tip:** Use [Coolors](https://coolors.co) or [Adobe Color](https://color.adobe.com) to generate harmonious color palettes.

## Setting Up Templates

Templates are the base shapes the engine colors. Place them in `templates/item/`:

| File | Source |
|------|--------|
| `diamond_sword.png` | Extract from Minecraft assets |
| `diamond_pickaxe.png` | Extract from Minecraft assets |
| ... | ... |
| `diamond_boots.png` | Extract from Minecraft assets |

Also place armor model textures in `templates/equipment/`:
- `humanoid.png` (upper body + helmet + boots)
- `humanoid_leggings.png` (leggings layer)

**How to extract from Minecraft:** The vanilla textures are in the Minecraft client jar at `assets/minecraft/textures/item/`.

## Output

Generated textures go to:
- `output/<palette>/item/` — item icons
- `output/<palette>/equipment/` — armor model textures

They're also copied to your mod project if `$ProjectAssets` is configured.

## License

- Engine code & palettes: MIT
- OpenGameArt sprites (templates/external/): CC0
- Vanilla Minecraft templates: NOT included (Mojang copyright) — extract your own
