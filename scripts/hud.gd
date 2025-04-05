extends PanelContainer

@export var level: Node3D

func _process(delta: float) -> void:
	$DepthLabel.text = "Depth: %s" % level.depth
