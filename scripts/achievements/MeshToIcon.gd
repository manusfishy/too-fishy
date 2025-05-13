# MeshToIcon.gd (or your filename)
@tool
extends EditorScript

# Configuration: Adjust these values in the Inspector when the script is selected
@export_dir var source_model_directory: String = "res://meshes/fish" # Directory containing 3D models
@export_dir var output_icon_directory: String = "res://textures/icons" # Directory to save generated icons
@export var icon_size: Vector2i = Vector2i(128, 128) # Resolution of the icons
@export var camera_distance_multiplier: float = 1.5 # Increase for more padding around the model
@export var background_color: Color = Color(0, 0, 0, 0) # RGBA - Default is transparent black
@export var light_energy: float = 2.0
@export var overwrite_existing: bool = true # If true, overwrites icons with the same name

# Side view rotation (90 degrees around Y for side view)
const MODEL_ROTATION = Vector3(0, 90, 0)

# Supported model file extensions
const MODEL_EXTENSIONS = ["glb", "gltf", "obj", "fbx"] # Add more if needed

# Member variable to hold editor interface reference
var _editor_interface: EditorInterface = null
var _pending_models: Array[Dictionary] = []
var _current_viewport: SubViewport = null
var _processing: bool = false
var _root_control: Control = null
var _render_steps: Array = []
var _current_step: int = 0

func _run():
	print("\n=== Starting Icon Generation ===")
	
	# Get editor interface and root control
	_editor_interface = get_editor_interface()
	if not _editor_interface:
		printerr("Failed to get EditorInterface")
		return
		
	_root_control = _editor_interface.get_base_control()
	if not _root_control:
		printerr("Failed to get base control")
		return
	
	# Setup directories and collect models
	if not _setup_directories():
		return
	
	if not _collect_models():
		return
	
	print("\n=== Model Queue Complete ===")
	print("Models queued for processing:", _pending_models.size())
	print("Starting processing...")
	
	# Process first model
	if _pending_models.size() > 0:
		_processing = true
		print(" proce")
		_process_next_model()

func _setup_directories() -> bool:
	if not DirAccess.dir_exists_absolute(source_model_directory):
		printerr("Source directory does not exist:", source_model_directory)
		return false
		
	if not DirAccess.dir_exists_absolute(output_icon_directory):
		print("Creating output directory:", output_icon_directory)
		if DirAccess.make_dir_recursive_absolute(output_icon_directory) != OK:
			printerr("Failed to create output directory")
			return false
	
	return true

func _collect_models() -> bool:
	var dir = DirAccess.open(source_model_directory)
	if not dir:
		printerr("Failed to open source directory")
		return false
		
	print("\nScanning directory:", source_model_directory)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir():
			var ext = file_name.get_extension().to_lower()
			if ext in MODEL_EXTENSIONS:
				var model_path = source_model_directory.path_join(file_name)
				var output_path = output_icon_directory.path_join(file_name.get_basename() + "_icon.png")
				
				if not overwrite_existing and FileAccess.file_exists(output_path):
					print("  [_run] Skipping existing:", output_path)
				else:
					print("  [_run] Queueing:", model_path)
					_pending_models.append({
						"model_path": model_path,
						"output_path": output_path
					})
					
		file_name = dir.get_next()
		
	dir.list_dir_end()
	return true

func _process_next_model():
	print(" processing1")
	if not _processing or _pending_models.is_empty():
		_cleanup_and_finish()
		return
		
	if _current_viewport != null:
		print("Previous viewport still exists, cleaning up...")
		_cleanup_viewport()
		
	var model_info = _pending_models.pop_front()
	var model_path = model_info["model_path"]
	var output_path = model_info["output_path"]
	
	print("\n>>>>> Processing:", model_path)
	
	# Create viewport
	print("  Creating viewport...")
	_current_viewport = SubViewport.new()
	_current_viewport.name = "MeshToIconViewport"
	_current_viewport.size = icon_size
	_current_viewport.transparent_bg = true
	_current_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	# Setup environment
	var world = World3D.new()
	var environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = background_color
	world.environment = environment
	_current_viewport.world_3d = world
	
	_root_control.add_child(_current_viewport)
	print("  Viewport added to scene:", _current_viewport.get_path())
	
	# Setup camera
	var camera = Camera3D.new()
	camera.name = "MeshToIconCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.look_at_from_position(Vector3(2, 0, 0), Vector3.ZERO, Vector3.UP)
	_current_viewport.add_child(camera)
	print("  Camera setup complete")
	
	# Setup lights
	var main_light = DirectionalLight3D.new()
	main_light.name = "MainLight"
	main_light.light_energy = light_energy
	main_light.rotation_degrees = Vector3(-15, -30, -45)
	_current_viewport.add_child(main_light)
	
	var fill_light = DirectionalLight3D.new()
	fill_light.name = "FillLight"
	fill_light.light_energy = light_energy * 0.5
	fill_light.rotation_degrees = Vector3(15, 150, 45)
	_current_viewport.add_child(fill_light)
	print("  Lights setup complete")
	
	# Load model
	print("  Loading model...")
	var resource = load(model_path)
	if not resource:
		printerr("  Failed to load resource")
		_cleanup_viewport()
		_process_next_model()
		return
		
	var model: Node3D
	if resource is PackedScene:
		var instance = resource.instantiate()
		if not instance is Node3D:
			printerr("  Model root is not Node3D")
			_cleanup_viewport()
			_process_next_model()
			return
		model = instance
	elif resource is Mesh:
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = resource
		model = mesh_instance
	else:
		printerr("  Unsupported resource type")
		_cleanup_viewport()
		_process_next_model()
		return
	
	# Setup model
	model.name = "ProcessingModel"
	model.rotation_degrees = MODEL_ROTATION
	_current_viewport.add_child(model)
	print("  Model added to viewport")
	
	# Setup render steps
	_render_steps = []
	_render_steps.append(func(): _calculate_bounds(model, camera))
	_render_steps.append(func(): _capture_image(output_path))
	_current_step = 0
	
	# Start rendering process
	_root_control.process_mode = Node.PROCESS_MODE_ALWAYS
	_root_control.process_frame.connect(_on_process_frame)
	print("  Starting render process...")

func _on_process_frame():
	if _current_step >= _render_steps.size():
		_root_control.process_frame.disconnect(_on_process_frame)
		return
		
	print("  Executing render step", _current_step)
	_render_steps[_current_step].call()
	_current_step += 1

func _calculate_bounds(model: Node3D, camera: Camera3D):
	print("  Calculating bounds...")
	var aabb = get_model_bounds(model)
	if aabb.size == Vector3.ZERO:
		printerr("  Invalid model bounds")
		_cleanup_viewport()
		_process_next_model()
		return
		
	# Position camera
	var center = aabb.get_center()
	var size = aabb.size
	var max_dim = max(size.x, max(size.y, size.z))
	camera.size = max_dim * camera_distance_multiplier
	camera.look_at_from_position(center + Vector3(max_dim * 2, 0, 0), center, Vector3.UP)
	print("  Camera positioned based on bounds")
	
	# Force viewport update
	_current_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func _capture_image(output_path: String):
	print("  Capturing image...")
	if not is_instance_valid(_current_viewport):
		printerr("Viewport is no longer valid!")
		_process_next_model()
		return
		
	var texture = _current_viewport.get_texture()
	if not texture:
		printerr("Failed to get viewport texture!")
		_cleanup_viewport()
		_process_next_model()
		return
		
	var image = texture.get_image()
	if image:
		# Ensure the output directory exists
		var dir = DirAccess.open("res://")
		if dir:
			var dir_path = output_path.get_base_dir()
			if not dir.dir_exists(dir_path):
				print("  Creating output directory:", dir_path)
				dir.make_dir_recursive(dir_path)
		
		var err = image.save_png(output_path)
		if err == OK:
			print("  Success:", output_path)
		else:
			printerr("  Failed to save image. Error:", err)
	else:
		printerr("  Failed to get viewport image")
	
	_cleanup_viewport()
	_process_next_model()

func get_model_bounds(node: Node3D) -> AABB:
	var aabb = AABB()
	var first = true
	
	if node is MeshInstance3D and node.mesh:
		aabb = node.mesh.get_aabb()
		first = false
	
	for child in node.get_children():
		if child is MeshInstance3D and child.mesh:
			var child_aabb = child.mesh.get_aabb()
			child_aabb = child.transform * child_aabb
			if first:
				aabb = child_aabb
				first = false
			else:
				aabb = aabb.merge(child_aabb)
				
	return aabb

func _cleanup_viewport():
	if _current_viewport:
		print("Cleaning up viewport...")
		if is_instance_valid(_current_viewport):
			if _current_viewport.is_inside_tree():
				_current_viewport.get_parent().remove_child(_current_viewport)
			_current_viewport.queue_free()
		_current_viewport = null

func _cleanup_and_finish():
	print("\nCleaning up...")
	_processing = false
	_cleanup_viewport()
	
	print("\n=== Icon Generation Complete ===")
	print("All models processed")
	print("Check output above for results")
	print("===============================")
