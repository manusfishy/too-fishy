extends HBoxContainer

# References to UI elements
var fish_name_label: Label
var icon_texture: TextureRect
var badges_container: HBoxContainer

func _ready():
	fish_name_label = $FishNameLabel
	icon_texture = $IconContainer/IconTexture
	badges_container = $BadgesContainer
	
	# Set fixed size for icon that won't be affected by UI scaling
	icon_texture.custom_minimum_size = Vector2(32, 32)
	icon_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	# Add to a group that will be excluded from UI scaling
	add_to_group("no_scale_ui")

# Set the fish name
func set_fish_name(name_text):
	fish_name_label.text = name_text

# Set the icon texture
func set_icon(texture):
	icon_texture.texture = texture
	# Maintain fixed size
	icon_texture.custom_minimum_size = Vector2(32, 32)

# Add a badge (star or air bubble)
func add_badge(badge_texture):
	var badge = TextureRect.new()
	badge.texture = badge_texture
	badge.expand = true
	badge.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	badge.custom_minimum_size = Vector2(24, 24)
	badge.add_to_group("no_scale_ui") # Add badge to no-scale group too
	badges_container.add_child(badge)
