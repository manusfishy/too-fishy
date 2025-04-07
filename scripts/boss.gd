extends Node
var boss_spawned = false
var boss_spawn_height = 500

enum BossDialogSections {TUTORIAL1, TUTORIAL2, RESCUE_CALL, BOSS_INTRO, BOSS_KILLS_FRIEND, FRIEND_RESCUED}

var boss_dialog_from = {
	BossDialogSections.TUTORIAL1: "John",
	BossDialogSections.TUTORIAL2: "John",
	BossDialogSections.RESCUE_CALL: "John",
	BossDialogSections.BOSS_INTRO: "???",
	BossDialogSections.BOSS_KILLS_FRIEND: "Blobfish",
	BossDialogSections.FRIEND_RESCUED: "John",
}
	
var boss_dialog_displayed = true
var boss_dialog_section = BossDialogSections.TUTORIAL1
var boss_dialog_index = 0

func setBossSpawned():
	boss_spawned = true
	setDialogStage(BossDialogSections.BOSS_INTRO)

func attackBoss():
	setDialogStage(BossDialogSections.BOSS_KILLS_FRIEND)

func setDialogStage(section: BossDialogSections):
	boss_dialog_section = section
	boss_dialog_index = 0
	boss_dialog_displayed = true
	GameState.paused = true
