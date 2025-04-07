extends Node

const PopupTextScene = preload("res://scenes/popup_text.tscn")

func show_popup(text_to_show: String, world_position: Vector3, text_color: Color = Color.WHITE):
	var popup_instance = PopupTextScene.instantiate()
	var current_scene = get_tree().current_scene
	current_scene.add_child(popup_instance)
	popup_instance.start_animation(text_to_show, text_color, world_position)
