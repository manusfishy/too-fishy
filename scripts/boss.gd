extends Node
var boss_spawned = false
var boss_spawn_height = 500
var boss_node: Node3D = null

enum BossDialogSections {TUTORIAL1, TUTORIAL2, TUTORIAL3, TUTORIAL4, RESCUE_CALL, BOSS_INTRO, BOSS_KILLS_FRIEND, FRIEND_RESCUED, WIN}

var boss_dialog_from = {
	BossDialogSections.TUTORIAL1: "John",
	BossDialogSections.TUTORIAL2: "John",
	BossDialogSections.TUTORIAL3: "John",
	BossDialogSections.TUTORIAL4: "John",
	BossDialogSections.RESCUE_CALL: "John",
	BossDialogSections.BOSS_INTRO: "???",
	BossDialogSections.BOSS_KILLS_FRIEND: "Blobfish",
	BossDialogSections.FRIEND_RESCUED: "John",
	BossDialogSections.WIN: "Too Fishy",
}

var dialog_depth_map = {
	BossDialogSections.TUTORIAL1: 0,
	BossDialogSections.TUTORIAL2: 25,
	BossDialogSections.TUTORIAL3: 50,
	BossDialogSections.TUTORIAL4: 300,
}

var boss_dialog_displayed = true
var boss_dialog_section = BossDialogSections.TUTORIAL1
var boss_dialog_index = 0

func setBossSpawned(boss: Node3D):
	boss_spawned = true
	boss_node = boss
	setDialogStage(BossDialogSections.BOSS_INTRO)

func attackBoss():
	setDialogStage(BossDialogSections.BOSS_KILLS_FRIEND)

func setDialogStage(section: BossDialogSections):
	boss_dialog_section = section
	boss_dialog_index = 0
	boss_dialog_displayed = true
	GameState.paused = true
	get_tree().paused = true
	
func process_dialog_depth():
	for section in dialog_depth_map.keys():
		if GameState.maxDepthReached >= dialog_depth_map[section]:
			if boss_dialog_section < section:
				setDialogStage(section)
				
	
	
