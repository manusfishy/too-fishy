extends Label

var fps_update_interval = 0.5  # Update FPS display every 0.5 seconds
var time_since_last_update = 0.0

func _ready():
	# Set initial visibility based on settings
	visible = SettingsManager.show_fps

func _process(delta):
	# Update visibility if setting changes
	visible = SettingsManager.show_fps
	
	if not visible:
		return
	
	# Update counter at regular intervals
	time_since_last_update += delta
	if time_since_last_update >= fps_update_interval:
		time_since_last_update = 0.0
		text = "FPS: " + str(Engine.get_frames_per_second())
