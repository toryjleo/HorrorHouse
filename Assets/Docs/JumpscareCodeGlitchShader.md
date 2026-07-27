# Jumpscare Code Glitch Shader

The jumpscare overlay now uses `Assets/Shaders/JumpscareCodeGlitch.shader`.

The `JumpscarePlayer` already sends `_ScareProgress` from `0` to `1` while the audio plays, so the shader does not need any extra C#.

Good first values to edit on `Assets/Art/JumpscareCodeGlitch.mat`:

- `_GlitchStrength`: bigger horizontal tearing.
- `_NoiseScale`: more or fewer glitch bands.
- `_ScanlineStrength`: darker scanlines.
- `_RedBlueSplit`: stronger red/blue channel split.
- `_FlashColor` and `_FlashIntensity`: color and strength of the random flashes.

Good first shader lines to study:

- `hash12`: makes repeatable fake noise from a `float2`.
- `band`: splits the screen into horizontal rows.
- `offset`: moves selected bands left or right.
- `red` and `blue`: sample color channels from different positions.
- `scanline`: dims every other thin row.
- `flash`: randomly blends toward `_FlashColor`.
