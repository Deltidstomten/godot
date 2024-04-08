extends Control

@onready var building_defs = get_node("/root/BuildingDefs")

@onready var wood_wall_label = $Panel/ScrollContainer/VBoxContainer/BuildWoodWall/WoodWallLabel
@onready var wood_floor_label = $Panel/ScrollContainer/VBoxContainer/BuildWoodFloor/WoodFloorLabel

var selected_block_to_build = "None"

func _ready():
	update_label("wood_wall", wood_wall_label)
	update_label("wood_floor", wood_floor_label)
	
func update_label(recipe, label):
	if len(building_defs.building_requirement[recipe]) > 1:
		pass
	else:
		for item in building_defs.building_requirement[recipe]:
			label.text += str(building_defs.building_requirement[recipe][item]) + " " + item

func _on_build_wood_wall_pressed():
	selected_block_to_build = "wood_wall"


func _on_build_wood_floor_pressed():
	selected_block_to_build = "wood_floor"	
