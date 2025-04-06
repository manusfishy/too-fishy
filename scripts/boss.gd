extends Node
var boss_spawned = false
var boss_spawn_height = 25

enum BossDialogSections {TUTORIAL1, TUTORIAL2, RESCUE_CALL, BOSS_INTRO, BOSS_KILLS_FRIEND}


var boss_dialog_from = {
	BossDialogSections.TUTORIAL1: "John",
	BossDialogSections.TUTORIAL2: "John",
	BossDialogSections.RESCUE_CALL: "John",
	BossDialogSections.BOSS_INTRO: "???",
	BossDialogSections.BOSS_KILLS_FRIEND: "Blobfish",
}
	
var boss_dialog_displayed = true
var boss_dialog_section = BossDialogSections.TUTORIAL1
var boss_dialog_index = 0

func setBossSpawned():
	boss_spawned = true
	boss_dialog_displayed = true
	boss_dialog_index = 0
	boss_dialog_section = BossDialogSections.BOSS_INTRO
	GameState.paused = true

func attackBoss():
	boss_dialog_displayed = true
	boss_dialog_index = 0
	boss_dialog_section = BossDialogSections.BOSS_KILLS_FRIEND
	GameState.paused = true
