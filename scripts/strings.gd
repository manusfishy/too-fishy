extends Node

var stageNames = {
	GameState.Stage.SURFACE: "Shallow Waters",
	GameState.Stage.DEEP: "Medium Waters",
	GameState.Stage.DEEPER: "Deep Waters",
	GameState.Stage.SUPERDEEP: "Dark Deep Waters",
	GameState.Stage.HOT: "Hot-Zone",
	GameState.Stage.LAVA: "Lava",
	GameState.Stage.VOID: "THE VOID"
}

var upgradeNames = {
	GameState.Upgrade.CARGO_SIZE: "Increased Cargo Space",
	GameState.Upgrade.DEPTH_RESISTANCE: "Depth Resistance",
	GameState.Upgrade.PICKAXE_UNLOCKED: "Unlock Pickaxe",
	GameState.Upgrade.VERT_SPEED: "Agillity",
	GameState.Upgrade.HOR_SPEED: "Thrust",
	GameState.Upgrade.LAMP_UNLOCKED: "Unlock Lamp",
	GameState.Upgrade.AK47: "Unlock Gun",
	GameState.Upgrade.HARPOON: "Upgrade Harpoon",
}

var boss_dialog_lines = {
	Boss.BossDialogSections.TUTORIAL1: [
		"Hey man! Is your sub ready yet?",
		"Yes? Awesome! Go shoot some fish with that spear of yours!",
		"You can move the vessel by using W A S D, or the Arrow Keys",
		"To catch the fish, throw a spear with a 'Left-CLICK'",
		"Watch your preassure and Health levels and return to the surface when needed!",
		"Remember, you can swim near the dock to upgrade your sub and sell fish."
		],
	Boss.BossDialogSections.TUTORIAL2: ["There are some crazy fish down here!", "I was able to sell some of them for a lot of money!"],
	Boss.BossDialogSections.TUTORIAL3: ["I found that the pickaxe is actually very useful", "You can break the barriers with them", "Press 'SPACE' to use it!"],
	Boss.BossDialogSections.TUTORIAL4: ["Its awesome down here, you gotta check it out!", "The blobfish is looking at me kinda wierd...", "You should be careful!"],
	Boss.BossDialogSections.RESCUE_CALL: ["Uhhhh- I did an oopsie", "I think you need to come and get me :S"],
	Boss.BossDialogSections.BOSS_INTRO: ["Hahaha, I got your friend, looser!", "His mind is under my control now!", "You better not do anything stupid or he dies!"],
	Boss.BossDialogSections.BOSS_KILLS_FRIEND: ["Ohhhh, that was a mistake!", "*Splash*", "Your friend is dead now!"],
	Boss.BossDialogSections.FRIEND_RESCUED: ["Oh my god thank you!", "That fucker is a mind controlling blobfish!", "You getting close has freed me from his spell!", "You need to stay close to me and escort me to the top!"],
	}
