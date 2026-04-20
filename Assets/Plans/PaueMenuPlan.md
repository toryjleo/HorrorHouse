# Pause Menu Implementation Plan

Add a pause menu triggered by **Escape** with a "Paused" title and **Resume** / **Quit** buttons. Freezes player input, pauses audio, and stops `Time.timeScale`.

---

## Existing Systems Summary

| System | Key Details |
|---|---|
| [GameState.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/GameState.cs) | Already has `isGamePaused`, `IsPlayerBusy`, `IsInteracting` |
| [AKDisableManager.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKDisableManager.cs) | Singleton; [DisablePlayerDefault()](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKDisableManager.cs#46-67) and [SetCursorState()](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKDisableManager.cs#90-96) |
| [AKFPSController.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Player/AKFPSController.cs) | [SetPlayerDisableMode(bool)](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Player/AKFPSController.cs#290-296) → sets `canMove`/`canRotate` |
| [AKAudioManager.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKAudioManager.cs) | Singleton; [StopAll()](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Core/AKAudioManager.cs#125-133) **stops** audio permanently (no resume). We'll use `AudioListener.pause` instead |
| [SceneManager.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/SceneManagement/SceneManager.cs) | Has [EndGame()](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/SceneManagement/SceneManager.cs#17-25) which calls `Application.Quit()` |

> [!IMPORTANT]
> `GameState.isGamePaused` already exists and is checked by `IsPlayerBusy` / `IsInteracting`. The new `PauseManager` will set this flag, so existing systems that check `IsPlayerBusy` will automatically respect the paused state.

---

## Proposed Changes

### PauseManager Script

#### [NEW] [PauseManager.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/PauseMenu/PauseManager.cs)

A new singleton `MonoBehaviour` that follows the same pattern as the other managers (`persistAcrossScenes`, `DontDestroyOnLoad`, `instance` field).

**Responsibilities:**
- Listen for `KeyCode.Escape` in [Update()](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/SceneManagement/SceneManager.cs#11-16)
- Guard: only allow pause toggle when **not** `GameState.IsPlayerBusy` (examining, inventory, etc.) — but always allow **unpausing** via Escape
- On **Pause**:
  1. Save current cursor state (`Cursor.visible`, `Cursor.lockState`)
  2. `GameState.isGamePaused = true`
  3. `Time.timeScale = 0f` — freezes physics, animations, and any time-based logic
  4. `AudioListener.pause = true` — globally pauses all audio; resumes exactly where it left off when set back to `false`
  5. Show cursor (visible + unlocked)
  6. Show the pause UI panel
- On **Resume**:
  1. Hide the pause UI panel
  2. `AudioListener.pause = false`
  3. Restore saved cursor state (so if the player was mid-interaction with cursor visible, it stays visible; if they were in normal play, cursor locks again)
  4. `Time.timeScale = 1f`
  5. `GameState.isGamePaused = false`
- On **Quit**: call the same `Application.Quit()` / `EditorApplication.isPlaying = false` pattern from `SceneManager.EndGame()`

> [!IMPORTANT]
> We intentionally **do not** call `AKDisableManager.DisablePlayerDefault()` during pause/resume. That method changes interaction state, crosshair, and prompts. If the player pauses mid-interaction (examining an item, using the safe, etc.), calling it on resume would wipe that state. Instead, `Time.timeScale = 0` + the `isGamePaused` guard in [AKFPSController](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Player/AKFPSController.cs#5-297) handles freezing the player cleanly.

---

### FPS Controller Guard

#### [MODIFY] [AKFPSController.cs](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Player/AKFPSController.cs)

[HandleRotation()](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/Adventure%20Puzzle%20Kit%20v1.7.1/Player/AKFPSController.cs#156-168) does **not** use `Time.deltaTime`, so mouse look still works at `timeScale = 0`. Add a simple early-return guard at the top of [Update()](file:///home/tory/Documents/Code/unity/HorrorHouse/Assets/Scripts/SceneManagement/SceneManager.cs#11-16):

```diff
 private void Update()
 {
+    if (GameState.isGamePaused) return;
     if (canMove) HandleMovement();
     if (canRotate) HandleRotation();
     HandleCrouching();
     HandleFootsteps();
 }
```

This freezes **all** player input (movement, rotation, crouching, footsteps) while paused, without touching `canMove`/`canRotate` — so the pre-pause state is fully preserved on resume.

**Inspector fields:**
- `[SerializeField] private GameObject pauseMenuPanel` — the UI root panel to show/hide
- `[SerializeField] private bool persistAcrossScenes = true`

> [!TIP]
> `Input.GetKeyDown` still fires at `timeScale = 0`, so the Escape toggle works without needing `Time.unscaledDeltaTime` hacks.

---

### Unity UI Setup (Manual Steps in Editor)

Since Unity UI must be created in the scene hierarchy, here are the step-by-step instructions to set up the Canvas, Panel, and Buttons.

> [!IMPORTANT]
> These steps are done **in the Unity Editor**, not in code. Follow them in order.

#### Step 1 — Create the Canvas

1. In the **Hierarchy**, right-click on the **Managers** parent object (or wherever your managers live)
2. Select **UI → Canvas**
3. Rename it to **PauseMenuCanvas**
4. In the Inspector, set:
   - **Canvas** component → Render Mode: **Screen Space - Overlay**
   - **Canvas Scaler** → UI Scale Mode: **Scale With Screen Size**
   - Reference Resolution: **1920 × 1080**
   - Match: **0.5** (balanced width/height scaling)

#### Step 2 — Create the Panel (background overlay)

1. Right-click **PauseMenuCanvas** → **UI → Panel**
2. Rename to **PauseMenuPanel**
3. In the Inspector:
   - **Image** component → Color: **black, alpha ~150** (semi-transparent dark overlay)
   - **Rect Transform**: anchors = Stretch/Stretch (already default for Panel)
4. **This is the GameObject you'll drag into `PauseManager.pauseMenuPanel`**

#### Step 3 — Choose a Font

You'll want a custom font for the horror aesthetic. Some good free options:

| Font | Style | Where to Get It |
|---|---|---|
| **Nosifer** | Dripping horror | [Google Fonts](https://fonts.google.com/specimen/Nosifer) |
| **Creepster** | Spooky handwritten | [Google Fonts](https://fonts.google.com/specimen/Creepster) |
| **Eater** | Grungy horror | [Google Fonts](https://fonts.google.com/specimen/Eater) |
| **Butcherman** | Rough, creepy | [Google Fonts](https://fonts.google.com/specimen/Butcherman) |
| **Special Elite** | Typewriter/unsettling | [Google Fonts](https://fonts.google.com/specimen/Special+Elite) |

**To import a font into Unity:**
1. Download the `.ttf` file from Google Fonts
2. Drag it into your project (e.g. `Assets/Fonts/`)
3. In Unity, go to **Window → TextMeshPro → Font Asset Creator**
4. Drag your `.ttf` into the **Source Font File** field
5. Click **Generate Font Atlas**, then **Save** (save as e.g. `Nosifer SDF` in `Assets/Fonts/`)

#### Step 4 — Add the "Paused" Title Text

1. Right-click **PauseMenuPanel** → **UI → Text - TextMeshPro**
   - If prompted to import TMP Essentials, click **Import**
2. Rename to **PausedTitle**
3. In the Inspector:
   - **Text Input**: `PAUSED`
   - **Font Asset**: your chosen horror font SDF asset
   - **Font Size**: `72` (adjust to taste)
   - **Alignment**: Center + Middle
   - **Color**: white or a blood-red (#8B0000)
   - **Rect Transform**:
     - **Anchor**: Top-Center
     - **Anchor Preset**: hold Alt+Shift, click the top-center option
     - **Pos Y**: `-200` (pushes it down from top, roughly upper-third)
     - **Width**: `600`, **Height**: `100`

#### Step 5 — Add the Resume Button

1. Right-click **PauseMenuPanel** → **UI → Button - TextMeshPro**
2. Rename to **ResumeButton**
3. Select the child **Text (TMP)** object:
   - **Text**: `Resume`
   - **Font Asset**: same horror font
   - **Font Size**: `36`
   - **Alignment**: Center + Middle
   - **Color**: white
4. Select the **ResumeButton** itself:
   - **Rect Transform**:
     - **Anchor**: Middle-Center
     - **Pos Y**: `0` (centered vertically)
     - **Width**: `300`, **Height**: `60`
   - **Image** component → Color: dark gray with some transparency, or fully transparent for text-only look
   - **Button** component → **On Click ()**: drag the **PauseManager** object → select `PauseManager.ResumeGame`

#### Step 6 — Add the Quit Button

1. Right-click **PauseMenuPanel** → **UI → Button - TextMeshPro**
2. Rename to **QuitButton**
3. Select the child **Text (TMP)**:
   - **Text**: `Quit`
   - **Font Asset**: same horror font
   - **Font Size**: `36`
   - **Alignment**: Center + Middle
   - **Color**: white
4. Select the **QuitButton** itself:
   - **Rect Transform**:
     - **Anchor**: Middle-Center
     - **Pos Y**: `-80` (below Resume)
     - **Width**: `300`, **Height**: `60`
   - **Image** component → match Resume button styling
   - **Button** component → **On Click ()**: drag the **PauseManager** object → select `PauseManager.QuitGame`

#### Step 7 — Disable the Panel by Default

1. Select **PauseMenuPanel** in the hierarchy
2. Uncheck the **checkbox** at top-left of the Inspector (disables the GameObject)
3. The panel starts hidden — `PauseManager` will call `SetActive(true/false)` on it

#### Final Hierarchy

```
Managers
├── ... (existing managers)
└── PauseMenuCanvas
    └── PauseMenuPanel  ← drag into PauseManager.pauseMenuPanel
        ├── PausedTitle (TMP)
        ├── ResumeButton
        │   └── Text (TMP)
        └── QuitButton
            └── Text (TMP)
```

---

## Verification Plan

### Manual Testing in Unity Editor

Since this is a Unity runtime UI feature, it must be tested by playing in the editor:

1. **Enter Play mode** in Unity
2. **Press Escape** → verify:
   - Panel appears with "PAUSED" text and two buttons
   - Player cannot move or look around
   - All audio is paused (ambient, footsteps, etc.)
   - Cursor is visible and unlocked
3. **Click Resume** → verify:
   - Panel hides
   - Player movement and look restored
   - Audio resumes
   - Cursor is hidden and locked
4. **Press Escape again** → verify it pauses again (toggle works)
5. **Press Escape while examining an item / in inventory** → verify nothing happens (guard check)
6. **Click Quit** → verify play mode stops (in-editor) or app closes (in build)
