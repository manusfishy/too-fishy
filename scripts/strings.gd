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
}

var boss_dialog_lines = {
	Boss.BossDialogSections.TUTORIAL1: ["Hey man! Is you sub ready yet?", "Yes? Awesome! Go shoot some fish with that spear of yours!", "'CLICK' to shoot a spear." , "Remember, you can swim near the dock to upgrade your sub and sell fish."],
	Boss.BossDialogSections.TUTORIAL2: ["There are some crazy fish down here!", "I was able to sell some of them for a lot of money!"],
	Boss.BossDialogSections.TUTORIAL3: ["I found that the pickaxe is actually very useful", "You can break the barriers with them", "Press 'SPACE' to use it!"],
	Boss.BossDialogSections.TUTORIAL4: ["Its awesome down here, you gotta check it out!", "Catch fish, load them off at the base and upgrade your vessel to come down and meet up with me."],
	Boss.BossDialogSections.RESCUE_CALL: ["Uhhhh- I did an oopsie", "I think you need to come and get me :S"],
	Boss.BossDialogSections.BOSS_INTRO: ["Hahaha, I got your friend, looser!", "You better not attack me or he dies!"],
	Boss.BossDialogSections.BOSS_KILLS_FRIEND: ["Ohhhh, that was a mistake!", "*Splash*", "Your friend is dead now!"],
	Boss.BossDialogSections.FRIEND_RESCUED: ["Oh my god thank you!", "That fucker is a mind controlling blobfish!", "You getting close has freed me from his spell!", "We need to stay close together and fight him!"],
	}
