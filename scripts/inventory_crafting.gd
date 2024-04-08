extends Control

@onready var item_defs = get_node("/root/ItemDefs")
@onready var player_stats = get_node("/root/PlayerStats")

@onready var player = get_node("../")

@onready var plank_label = $ScrollContainer/VBoxContainer/Craft_Plank/PlankLabel
@onready var stick_label = $ScrollContainer/VBoxContainer/CraftStick/StickLabel

func update_label(recipe1, label):
	var recipe = recipe1
	if len(item_defs.recipe_requirement[recipe]) > 1:
		pass
	else:
		for item in item_defs.recipe_requirement[recipe]:
			label.text += str(item_defs.recipe_requirement[recipe][item]) + " " + item
		label.text += " = "
		for item in item_defs.recipe_result[recipe]:
			label.text += str(item_defs.recipe_result[recipe][item]) + " " + item

func check_if_can_craft(recipe_name):
	var recipe = item_defs.recipe_requirement[recipe_name]
	
	for item in recipe:
		if !player_stats.inventory.has(item):
			return
		if player_stats.inventory[item] < recipe[item]:
			return
	
	for item in recipe:
		player_stats.inventory[item] = player_stats.inventory[item] - recipe[item]
	for item in item_defs.recipe_result[recipe_name]:
		player_stats.inventory[item] = player_stats.inventory[item] + item_defs.recipe_result[recipe_name][item]
		
	player.update_inventory()

func _on_craft_plank_mouse_entered():
	update_label("plank", plank_label)

func _on_craft_stick_mouse_entered():
	update_label("stick", stick_label)

func _on_craft_plank_mouse_exited():
	plank_label.text = ""

func _on_craft_stick_mouse_exited():
	stick_label.text = ""

func _on_craft_plank_pressed():
	check_if_can_craft("plank")

func _on_craft_stick_pressed():
	check_if_can_craft("stick")
