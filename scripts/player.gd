extends CharacterBody2D

@onready var player_stats = get_node("/root/PlayerStats")
@onready var building_defs = get_node("/root/BuildingDefs")
@onready var tile_map = get_node("/root/main/TileMap")
@onready var username_label = $Username

@onready var inventory_control = $Control
@onready var inventory_label = $"Control/ScrollContainer2/VBoxContainer/Inventory Label"

@onready var builder_control = $BuildingMenu

const SPEED = 200.0

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	
func _ready():
	$Camera2D.enabled = is_multiplayer_authority()
	update_inventory()

func _physics_process(_delta):
	if is_multiplayer_authority():
		velocity = Input.get_vector("move_left", "move_right","move_up","move_down") * SPEED
	move_and_slide()

func _input(event):
	if is_multiplayer_authority():
		if event.is_action_pressed("open_inventory"):
			inventory_control.visible = !inventory_control.visible
		elif event.is_action_pressed("open_builder"):
			builder_control.visible = !builder_control.visible
		elif event.is_action_pressed("interact_tile"):
			if builder_control.visible:
				rpc("_place_tile", builder_control.selected_block_to_build, get_global_mouse_position())

@rpc("any_peer", "call_local")
func _place_tile(tile, pos):
	if tile == "None":
		return
	var tile_pos = tile_map.local_to_map(pos)
	var layer = building_defs.building_layer[tile]
	var atlas_coords = building_defs.building_atlas[tile]
	print(building_defs.building_layer[tile])
	tile_map.set_cell(layer, tile_pos, 0, atlas_coords)
	print(tile_pos)

func update_inventory():
	if is_multiplayer_authority():
		inventory_label.text = ""
		for item in player_stats.inventory:
			inventory_label.text += item + " : " + str(player_stats.inventory[item]) + "\n"

func _on_load_timeout():
	username_label.text = player_stats.usernames[name.to_int()]
