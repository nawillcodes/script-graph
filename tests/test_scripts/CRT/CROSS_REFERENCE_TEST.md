# Cross-Reference Test Scripts

These test scripts demonstrate the cross-file function call detection feature in ScriptGraph.

## 📋 Test Scripts

### **1. game_manager.gd** - Game Controller
Manages the game state and coordinates between systems.

**Functions:**
- `start_game()` - Entry point
- `spawn_player()` - Creates player instance
- `initialize_ui()` - Creates UI instance
- `start_level()` - Starts a level
- `update_ui()` - Updates UI with player data
- `handle_player_death()` - Handles player death
- `show_game_over()` - Shows game over screen
- `restart_game()` - Restarts the game
- `quit_game()` - Quits the game

**Calls functions from:**
- `player_movement.gd` → `reset()`
- `ui_manager.gd` → `show_game_over_screen()`, `update_health()`, `update_score()`

---

### **2. player_movement.gd** - Player Controller
Player character with health, movement, and scoring.

**Functions:**
- `_process()` - Main update loop
- `die()` - Handles player death
- `test_early_return()` - Test function
- `check_bonus()` - Checks for bonus
- `grant_bonus()` - Awards bonus
- `reset_position()` - Resets position
- `reset()` - Full reset
- `take_damage()` - Takes damage
- `log_event()` - Logs events

**Called from:**
- `game_manager.gd` → `reset()`
- `enemy.gd` → `take_damage()`

---

### **3. ui_manager.gd** - UI Controller
Manages all UI elements and updates.

**Functions:**
- `setup_ui()` - Initializes UI
- `create_health_bar()` - Creates health bar
- `create_score_label()` - Creates score label
- `create_game_over_panel()` - Creates game over screen
- `update_health()` - Updates health display
- `update_score()` - Updates score display
- `show_game_over_screen()` - Shows game over
- `hide_game_over_screen()` - Hides game over
- `show_notification()` - Shows notification

**Called from:**
- `game_manager.gd` → `show_game_over_screen()`, `update_health()`, `update_score()`

---

### **4. enemy.gd** - Enemy AI
Enemy character that attacks the player.

**Functions:**
- `find_player()` - Finds player in scene
- `try_attack_player()` - Attempts attack
- `attack_player()` - Attacks player
- `take_damage()` - Takes damage
- `die()` - Handles death
- `emit_loot()` - Emits loot
- `spawn_loot_effects()` - Spawns effects
- `log_combat_event()` - Logs combat

**Calls functions from:**
- `player_movement.gd` → `take_damage()`

---

## 🧪 How to Test

### **Step 1: Load a Script**
1. Open ScriptGraph tab
2. Select **game_manager.gd** in FileSystem

### **Step 2: See Cross-References**
You should see badges like:
```
⚡ spawn_player()
📞 called in game_manager.gd

⚡ update_health(health: float)
📞 called in game_manager.gd

⚡ show_game_over_screen()
📞 called in game_manager.gd
```

### **Step 3: Test Other Scripts**

**Load player_movement.gd:**
```
⚡ reset()
📞 called in game_manager.gd

⚡ take_damage(amount: float)
📞 called in enemy.gd
```

**Load ui_manager.gd:**
```
⚡ update_health(health: float)
📞 called in game_manager.gd

⚡ update_score(score: int)
📞 called in game_manager.gd

⚡ show_game_over_screen()
📞 called in game_manager.gd
```

**Load enemy.gd:**
```
⚡ attack_player()
// No cross-references (internal only)
```

---

## 📊 Expected Call Graph

```
game_manager.gd
    ├── calls player_movement.reset()
    ├── calls ui_manager.update_health()
    ├── calls ui_manager.update_score()
    └── calls ui_manager.show_game_over_screen()

enemy.gd
    └── calls player_movement.take_damage()

player_movement.gd
    └── (called by game_manager & enemy)

ui_manager.gd
    └── (called by game_manager)
```

---

## ⚡ Performance Note

The cross-reference scan happens when you load a file. For large projects, it may take a few seconds. You'll see debug output:

```
[DEBUG] Finding callers for functions in: res://.../player_movement.gd
[DEBUG] Scanning 15 .gd files for function calls...
[DEBUG] Function 'take_damage' called from 1 file(s)
[DEBUG] Function 'reset' called from 1 file(s)
```

---

## 🎯 What to Look For

✅ **Badges on function nodes** showing which files call them  
✅ **Tooltip showing complete caller list**  
✅ **Multiple callers displayed correctly** (file1.gd & file2.gd)  
✅ **Functions with no callers** don't show the badge  

---

Enjoy testing the cross-reference feature! 🎉
