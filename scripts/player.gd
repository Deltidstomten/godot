extends CharacterBody2D

@onready var player_stats = get_node("/root/PlayerStats")
@onready var username_label = $Username

@onready var inventory_control = $Control
@onready var inventory_label = $"Control/ScrollContainer2/VBoxContainer/Inventory Label"


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
	if event.is_action_pressed("open_inventory"):
		inventory_control.visible = !inventory_control.visible

func update_inventory():
	if is_multiplayer_authority():
		inventory_label.text = ""
		for item in player_stats.inventory:
			inventory_label.text += item + " : " + str(player_stats.inventory[item]) + "\n"

func _on_load_timeout():
	username_label.text = player_stats.usernames[name.to_int()]
