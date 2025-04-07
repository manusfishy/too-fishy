extends Label

func _process(_delta: float) -> void:
	set_text("FPS %s" % Engine.get_frames_per_second())
