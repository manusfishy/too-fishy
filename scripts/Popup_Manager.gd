extends Node

const PopupTextScene = preload("res://scenes/popup_text.tscn")

func show_popup(
		text_to_show: String,
		world_position: Vector3,
		text_color: Color = Color.WHITE,
		parent_anchor: Node3D = null, # optional: Node the popup should follow
		delay: float = 0.0 # optional:
	):
	
	var popup_instance = PopupTextScene.instantiate()
	
	if is_instance_valid(parent_anchor):
		parent_anchor.add_child(popup_instance)
		popup_instance.global_position = world_position
	else:
		var current_scene = get_tree().current_scene
		current_scene.add_child(popup_instance)
		popup_instance.global_position = world_position
		
	popup_instance.start_animation(text_to_show, text_color, world_position, delay)
