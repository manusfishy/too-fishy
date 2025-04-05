extends PanelContainer

var buttons = {}

func _ready():
	for key in GameState.upgrades:
		var upgradeButton: Button = Button.new()
		upgradeButton.text = Strings.upgradeNames[key] + " %s" % (GameState.upgrades[key] + 1) + " (Cost: %s)" % GameState.getUpgradeCost(key)
		upgradeButton.pressed.connect(func(): GameState.upgrade(key)) 
		$VBoxContainer/GridContainer.add_child(upgradeButton)
		buttons[key] = upgradeButton
	pass

func _process(delta):
	if GameState.isDocked:
		visible = true
	else:
		visible = false
	for key in buttons:
		var upgradeButton = buttons[key]
		
		if GameState.upgrades[key] == GameState.maxUpgrades[key]:
			upgradeButton.text = Strings.upgradeNames[key] + "[MAX]"
		else:
			upgradeButton.text = Strings.upgradeNames[key] + " %s" % (GameState.upgrades[key] + 1) + " (Cost: %s)" % GameState.getUpgradeCost(key)
