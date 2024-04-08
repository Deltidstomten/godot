extends StaticBody2D

@onready var player_stats = get_node("/root/PlayerStats")
@onready var tile_map = get_node("/root/main/TileMap")

@export var loot = {
	"log" : 4,
	"stick": 1
}



func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		for item in loot:
			if player_stats.inventory.has(item):
				player_stats.inventory[item] += loot[item]
			else:
				player_stats.inventory[item] = loot[item]
				
		get_node(player_stats.player_path + str(multiplayer.get_unique_id())).update_inventory()
		tile_map.rpc("_delete_cell", 1, tile_map.local_to_map(get_global_mouse_position()))
