extends Control

@onready var save_system = $"/root/SaveSystem"
@onready var save_button = $Panel/MarginContainer/VBoxContainer/ButtonsContainer/SaveButton
@onready var load_button = $Panel/MarginContainer/VBoxContainer/ButtonsContainer/LoadButton
@onready var delete_button = $Panel/MarginContainer/VBoxContainer/ButtonsContainer/DeleteButton
@onready var back_button = $Panel/MarginContainer/VBoxContainer/BackButton
@onready var status_label = $StatusLabel
@onready var save_info_label = $Panel/MarginContainer/VBoxContainer/SaveInfoContainer/MarginContainer/SaveInfoLabel
@onready var save_info_container = $Panel/MarginContainer/VBoxContainer/SaveInfoContainer

func _ready():
	# Check for save file and update UI
	update_ui()
	
	# Apply style to the save info container
	var info_style = StyleBoxFlat.new()
	info_style.bg_color = Color(0.05, 0.15, 0.3, 0.7) # Darker blue
	info_style.set_border_width_all(2)
	info_style.border_color = Color(0.3, 0.5, 0.7)
	info_style.set_corner_radius_all(8)
	save_info_container.get_node("StyleOverride").add_theme_stylebox_override("panel", info_style)
	
	# Apply button styles
	_style_buttons()
	
	# Connect button signals
	save_button.pressed.connect(_on_save_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)
	delete_button.pressed.connect(_on_delete_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)

func _style_buttons():
	var buttons = [save_button, load_button, delete_button, back_button]
	
	for button in buttons:
		var button_style = StyleBoxFlat.new()
		button_style.bg_color = Color(0.1, 0.25, 0.4, 0.9)
		button_style.set_border_width_all(2)
		button_style.border_color = Color(0.3, 0.5, 0.7)
		button_style.set_corner_radius_all(8)
		button.add_theme_stylebox_override("normal", button_style)
		
		var hover_style = StyleBoxFlat.new()
		hover_style.bg_color = Color(0.15, 0.3, 0.45, 0.9)
		hover_style.set_border_width_all(2)
		hover_style.border_color = Color(0.4, 0.6, 0.8)
		hover_style.set_corner_radius_all(8)
		button.add_theme_stylebox_override("hover", hover_style)
		
		var pressed_style = StyleBoxFlat.new()
		pressed_style.bg_color = Color(0.05, 0.2, 0.35, 0.9)
		pressed_style.set_border_width_all(2)
		pressed_style.border_color = Color(0.2, 0.4, 0.6)
		pressed_style.set_corner_radius_all(8)
		button.add_theme_stylebox_override("pressed", pressed_style)

func update_ui():
	var has_save = save_system.has_save_file()
	
	# Update button states
	load_button.disabled = !has_save
	delete_button.disabled = !has_save
	
	# Update save info label
	if has_save:
		var save_info = save_system.get_save_info()
		var datetime = Time.get_datetime_dict_from_unix_time(save_info.get("timestamp", 0))
		var date_str = "%04d-%02d-%02d %02d:%02d" % [
			datetime.year, datetime.month, datetime.day,
			datetime.hour, datetime.minute
		]
		
		var info_text = "Save file: %s\nDepth: %d m\nMax Depth: %d m\nMoney: $%d" % [
			date_str,
			save_info.get("depth", 0),
			save_info.get("max_depth", 0),
			save_info.get("money", 0)
		]
		
		save_info_label.text = info_text
	else:
		save_info_label.text = "No save file found"

func show_status(message: String, duration: float = 2.0):
	status_label.text = message
	status_label.show()
	
	# Hide the status message after duration seconds
	var timer = get_tree().create_timer(duration)
	timer.timeout.connect(func(): status_label.hide())

func _on_save_button_pressed():
	if save_system.save_game():
		show_status("Game saved successfully!")
	else:
		show_status("Failed to save game!")
	
	update_ui()

func _on_load_button_pressed():
	if save_system.load_game():
		show_status("Game loaded successfully!")
		
		# Resume game 
		get_tree().paused = false
		hide()
		
		# Refresh all UI elements that depend on loaded game state
		var upgrades_menu = get_tree().get_first_node_in_group("upgrades_menu")
		if upgrades_menu and upgrades_menu.has_method("refresh_all_upgrades"):
			upgrades_menu.refresh_all_upgrades()
		
		get_parent().resume_game()
	else:
		show_status("Failed to load save file!")
	
	update_ui()

func _on_delete_button_pressed():
	if save_system.delete_save():
		show_status("Save file deleted!")
	else:
		show_status("Failed to delete save file!")
	
	update_ui()

func _on_back_button_pressed():
	# Hide the save menu and show pause menu elements
	get_parent().show_pause_elements(true)
	hide() 