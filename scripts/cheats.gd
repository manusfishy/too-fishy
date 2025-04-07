extends PanelContainer

@onready var grid = $VBoxContainer/GridContainer
@export var is_open = false

func addButton(text, mCall):
	var upgradeButton: Button = Button.new()
	upgradeButton.text = text
	upgradeButton.pressed.connect(mCall) 
	grid.add_child(upgradeButton)

func _ready():
	addButton("Upgrade All", func(): upgrade_all())
	addButton("1000+ $", func(): GameState.money += 1000)
	addButton("Down 100", func(): GameState.player_node.position.y -= 100)
	addButton("Go Up", func(): GameState.player_node.position.y = 0)
	addButton("God mode", func(): GameState.god_mode = not GameState.god_mode)
	addButton("Kill", func(): GameState.health = 0)
	addButton("Skip Dialog", func(): skip_dialog())
	addButton("trauma 1", func(): GameState.player_node.traumaShakeMode = 1 )
	addButton("trauma 2", func(): GameState.player_node.traumaShakeMode = 2 )
	addButton("trauma 3", func(): GameState.player_node.traumaShakeMode = 3 )
	
	
	close()


func upgrade_all():
	for key in GameState.upgrades:
		GameState.upgrades[key] = GameState.maxUpgrades[key]
	pass
	
func skip_dialog() -> void:
	@warning_ignore("int_as_enum_without_cast")
	Boss.boss_dialog_section = 999
	Boss.boss_dialog_displayed = false
	Boss.boss_dialog_index = 0
	GameState.paused = false

func _process(_delta):
	if GameState.god_mode:
		GameState.health = 100
	if GameState.isDocked:
		close()
	if Input.is_action_just_pressed("cht_toggle"):
		if GameState.isDocked:
			return
		if is_open:
			close()
		else:
			open()
	if Input.is_action_just_pressed("esc"):
		close()


func open():
	visible = true
	is_open = true


func close():
	visible = false
	is_open = false
