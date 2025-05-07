# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Too Fishy is a 2.5D underwater exploration game built with Godot 4.4, where the player controls a submarine to dive into the ocean depths, catch exotic fish, and search for a lost friend. The game features a progression system where players collect fish to sell at the surface, upgrade their submarine, and venture deeper into more challenging areas.

## Development Environment

- Godot Engine 4.4 or newer (using GL Compatibility renderer)
- The project can be opened by selecting the `project.godot` file in Godot Editor

## Game Architecture

### Core Systems

1. **GameState**: Central singleton that manages:
   - Player's depth, money, health, and upgrades
   - Game stage based on depth (SURFACE, DEEP, DEEPER, SUPERDEEP, HOT, LAVA, VOID)
   - Upgrade system with costs and maximum levels
   - Inventory system integration

2. **Player**: Main submarine controller that handles:
   - Movement in 2.5D space using keyboard/touch controls
   - Harpoon mechanics for catching fish
   - Depth effects including damage from deep water pressure
   - Upgrade-based features like surface buoy and drone selling

3. **Inventory System**:
   - Manages caught fish with weight and price properties
   - Weight-limited capacity based on cargo size upgrades
   - Smart inventory management with fish replacement logic
   - Selling mechanics at surface dock or via drone

4. **Fish System**:
   - Different fish types with varying weight, price, and difficulty
   - Fish distribution based on depth/stage
   - Special "shiny" variants with higher value
   - Fish behavior including scattering and movement patterns

### Project Structure

- `scripts/`: Contains all GDScript code files
  - `game_state.gd`: Central game state management
  - `player.gd`: Player submarine controller
  - `inventory/`: Inventory system implementation
  - `items/`: Weapons and tools (harpoon, pickaxe, AK47)
  - `fishes_config.gd`: Fish type configurations
  
- `scenes/`: Game object scenes
  - `mobs/`: Fish and enemy scenes
  - `inventory/`: UI for inventory
  - `ui/`: User interface elements
  
- `materials/`: Materials and shaders for visual effects
  - `water/`: Water materials for different depths
  - `shaders/`: Custom shader implementations
  
- `meshes/`: 3D models for submarine, fish, and items

## Working with Godot Files

When editing this project, be aware of these Godot-specific file types:
- `.tscn`: Scene files that contain node structures
- `.gd`: GDScript code files
- `.gdshader`: Godot shader files
- `.tres`: Godot resource files

## Common Tasks

To test changes, open the project in Godot and run the game by pressing F5 or clicking the Play button in the editor.