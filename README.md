# Mayor Voting UI

A sleek and customizable in-game voting interface for FiveM, designed for immersive mayor elections. Built with `ox_lib`, `ox_target`, `oxmysql` and `QBX/ESX` support, and a custom HTML/CSS UI.

---

## Features

- Vote for a mayor in-character with only one vote per citizen
- Dynamic candidate list (image + name)
- Custom NUI interface (no `ox_lib` context menu)
- Scrollable carousel UI with arrow navigation
- Vote logging via Discord webhook
- Fully configurable framework, ticket machine, blip, and voting UI behavior

---

## How It Works

### 1. **Voting Interface Trigger**
A prop (e.g., ticket machine) spawns at a configurable location. When a player targets and interacts with it using `ox_target`, a short animation is played and a server-side check determines if they've already voted.

If eligible, the player sees a custom NUI interface where they can choose from a list of candidates.

### 2. **Voting Logic**
- Each vote is stored in a SQL table (`mayor_votes`) with the player’s license, name, vote, and timestamp.
- Only **one vote per player** is allowed.
- Webhooks log the vote to a Discord channel with name, license, Discord ID, and current vote count.

### 3. **Dynamic Candidate System**
Candidates are stored in a JSON file (`candidates.json`) and synced dynamically to clients. Their images must be added to the `ui/images/` folder and named using lowercase and underscores (e.g., `john_doe.png`).

### 4. **UI and Carousel**
- The voting UI is built with HTML, CSS, and JS.
- Candidates are shown in a card layout, styled with Poppins font and unique branding.
- If there are more than 3 candidates, arrows appear allowing the player to scroll through them in a carousel-like fashion.
- Voting happens by clicking the candidate card. Pressing `Esc` or clicking `X` closes the interface.

https://youtu.be/YZeLR_9D2Ng
---

## File Structure

```
will-mayorvoting/
│
├── client.lua
├── server.lua
├── config.lua
├── fxmanifest.lua
│
├── ui/
│   ├── index.html
│   ├── style.css
│   ├── main.js
│   ├── images/
│       ├── john_doe.png
│       └── default.png
│
└── candidates.json
```

---

## Database Setup

To store player votes securely, this script uses a table called `mayor_votes`. If your database does not auto-create it, you can run the following SQL manually:

```sql
CREATE TABLE IF NOT EXISTS `mayor_votes` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `license` VARCHAR(64) NOT NULL UNIQUE,
  `player_name` VARCHAR(100),
  `candidate_name` VARCHAR(100),
  `vote_time` DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

This table ensures each player can vote only once and stores the vote timestamp and player identifiers.

---

## Installation

1. **Drag & Drop** `will-mayorvoting` into your `resources` folder.
2. Add to your `server.cfg`:
   ```cfg
   ensure will-mayorvoting
   ```
3. Edit `config.lua` to set:
   - Framework (`"qbx"`, or `"esx"`)
   - Ticket machine model and spawn coords
   - Webhook URL
4. Place your candidate images in `ui/images/` with names matching `candidates.json`
5. Make sure your database table is correctly registered, otherwise you can create the table manually from code above.

---

## Dependencies

- [`ox_lib`](https://github.com/overextended/ox_lib)
- [`oxmysql`](https://github.com/overextended/oxmysql)
- [`ox_target`](https://github.com/overextended/ox_target)
- Any framework: ESX / QBX

---

## Credits

UI design & scripting by **willlyyy**  
Vote logic, NUI bridge, and Discord logging fully integrated

---

## To-Do / Ideas

- Custom ped that shows information about the election.
- Admin panel in-game with custom admin commands
- Election timer or countdown

