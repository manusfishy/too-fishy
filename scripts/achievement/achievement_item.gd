extends HBoxContainer

# References to UI elements
var fish_name_label: Label
var icon_texture: TextureRect
var badges_container: HBoxContainer

func _ready():
	fish_name_label = $FishNameLabel
	icon_texture = $IconContainer/IconTexture
	badges_container = $BadgesContainer

# Set the fish name
func set_fish_name(name_text):
	fish_name_label.text = name_text

# Set the icon texture
func set_icon(texture):
	icon_texture.texture = texture

# Add a badge (star or air bubble)
func add_badge(badge_texture):
	var badge = TextureRect.new()
	badge.texture = badge_texture
	badge.expand = true
	badge.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	badge.custom_minimum_size = Vector2(24, 24)
	badges_container.add_child(badge)