extends PanelContainer

@onready var grid = $VBoxContainer/GridContainer
@export var is_open = false

func addButton(text, call):
	var upgradeButton: Button = Button.new()
	upgradeButton.text = text
	upgradeButton.pressed.connect(call) 
	grid.add_child(upgradeButton)

func _ready():
	addButton("Upgrade All", func(): upgrade_all())
	addButton("1000+ $", func(): GameState.money += 1000)
	addButton("Down 100", func(): GameState.player_node.position.y -= 100)
	addButton("Up 100", func(): GameState.player_node.position.y += 100)
	addButton("God mode", func(): GameState.god_mode = not GameState.god_mode)
	

	close()


func upgrade_all():
	for key in GameState.upgrades:
		GameState.upgrades[key] = GameState.maxUpgrades[key]
	pass

func _process(delta):
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
