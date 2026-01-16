# Project Plan: Basement Escape

## Phase 1: 3-Day Intensive Stint (Core Mechanics)

Goal: Establish a playable "gray-box" loop where the player can navigate the space and complete the puzzle.

### Day 1: Foundation & Environment

- [ ] Player Controller: Implement first-person, child-scale movement. - 10 - 20 mins
- [ ] Movement Constraints: Ensure "walking only" logic (no sprint). - 10 - 20 mins
- [ ] Modular Layout: Build the basement using 1m modular blocks to roughly blockout the room 30 min - 1hr
- [ ] Interaction System: Verify player interaction system. - 10 - 20 mins

### Day 2: The Logic Hub
- [ ] GATING Player interaction: 5 - 40 mins
- [ ] Chess Plug Mechanism: Create the three-slot socket system in the central room. Then Implement the "correct order" requirement and automatic reset on failure. 50 mins - 1.5hr.
- [ ] Exit Grate: Script the mechanical grate/wall panel to retract upon puzzle completion 10 mins - 45 mins.

### Day 3: Puzzle Path Implementation

- [ ] Flashlight Tool: Implement the flashlight toggle and the dark room/coal room visibility logic. - 10 - 45 mins.
- [ ] Path A: Place Chess Piece A inside the dark room accessible only by flashlight 10 mins - 20 mins.
- [ ] Path B: Implement the unlocked chest for Chess Piece B 10 mins - 20 mins.
- [ ] Path C: Program the padlock and input code logic for Chess Piece C 10 mins - 20 mins.

## Phase 2: Full Workday (Narrative & Atmosphere)

Goal: Transform the mechanical loop into a cohesive horror experience.
- [ ] Write notes: Write out all 8 planned narrative notes. 1 - 2 hours.
- [ ] Note Integration: Place all 8 planned narrative notes (Jacob, Emily, and Abductor lists) in concealed locations . 10 mins - 20 mins.
- [ ] Ambient Audio: Implement the 2D basement room tone and 3D environmental sounds for objects. 10 mins - 1hour.
- [ ] Write Cult Ritual Script: 1 hour
- [ ] Record Cult Ritual Audio & edit: 3 hours
- [ ] Ending Sequence: Script the final escape passage, cult ritual audio, and the fade-to-black. 1 hour - 2 hours.
- [ ] Lighting Design: Set up fully dynamic lighting with heavy use of shadows. 10 mins - 20 mins.

## Phase 3: Night Sessions (Polish & Tuning)

Goal: Refine the experience and mitigate known risks.

- Night 1 (Audio Polish): Layer in the narrative audio (distant cult chanting) as the player approaches the end. 10 mins - 20 mins.
- Night 2 (Puzzle Balancing): Fine-tune the "Ordering Hint System" in the notes to ensure the solution is discoverable but not explicit . 10 mins - 20 mins.
- Night 3 (QA & Optimization): Verify the "No Death" feedback loop and check performance for modular assets. 10 mins - 20 mins.

## Strict Scope Constraints

- No Combat: No weapon mechanics or AI chase systems.
- No Complex Movement: No crouching, crawling, or inventory management.
- Diegetic Storytelling: All narrative remains strictly in notes; no voice acting.

Would you like me to generate a specific C# script template for the Chess Plug Mechanism logic to help you get started on Day 2?