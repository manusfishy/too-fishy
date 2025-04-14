extends Node

# Dictionary of upgrade descriptions for tooltips
var upgradeDescriptions = {
	GameState.Upgrade.CARGO_SIZE: "Increases the maximum weight your submarine can carry, allowing you to collect more fish before returning to dock.",
	GameState.Upgrade.DEPTH_RESISTANCE: "Improves your submarine's hull integrity, allowing you to dive deeper without taking damage from pressure.",
	GameState.Upgrade.PICKAXE_UNLOCKED: "Equips your submarine with a pickaxe that can break through barriers. Press SPACE to use.",
	GameState.Upgrade.VERT_SPEED: "Increases your submarine's vertical speed, allowing you to ascend and descend more quickly.",
	GameState.Upgrade.HOR_SPEED: "Increases your submarine's horizontal speed, allowing you to move left and right more quickly.",
	GameState.Upgrade.LAMP_UNLOCKED: "Adds a powerful lamp to your submarine, improving visibility in deeper waters.",
	GameState.Upgrade.AK47: "Equips your submarine with a gun that can be used to defend against aggressive fish.",
	GameState.Upgrade.DUALAK47: "Adds a second gun to your submarine for increased firepower.",
	GameState.Upgrade.HARPOON: "Upgrades your harpoon to pierce through multiple fish with a single shot.",
	GameState.Upgrade.HARPOON_ROTATION: "Allows you to aim your harpoon in any direction using your mouse or touch controls.",
	GameState.Upgrade.INVENTORY_MANAGEMENT: "Automatically replaces less valuable fish with more expensive ones when your inventory is full.",
	GameState.Upgrade.SURFACE_BUOY: "Provides an emergency buoy that quickly returns you to the surface when you press B.",
	GameState.Upgrade.INVENTORY_SAVE: "Insures your inventory, preventing loss of collected fish when you die.",
	GameState.Upgrade.DRONE_SELLING: "Deploys a drone that sells your inventory remotely when you press Q, without returning to dock."
}
