extends Node3D

@export var pickaxe_scene = preload("res://scenes/pickaxe.tscn") # Pfad zur Pickaxe-Szene
var pickaxe_instance: Node3D = null

func _ready():
    # Überprüfen, ob das Upgrade bereits gekauft wurde
    if GameState.upgrades[GameState.Upgrade.PICKAXE_UNLOCKED] == 1:
        equip_pickaxe()

func equip_pickaxe():
    # Instanziiert die Pickaxe und fügt sie der Hand hinzu
    if pickaxe_instance == null:
        pickaxe_instance = pickaxe_scene.instantiate()
        add_child(pickaxe_instance)
        pickaxe_instance.global_transform = global_transform
        print("Pickaxe equipped!")

func on_upgrade_purchased(upgrade_type):
    # Wird aufgerufen, wenn ein Upgrade gekauft wird
    if upgrade_type == GameState.Upgrade.PICKAXE_UNLOCKED:
        equip_pickaxe()