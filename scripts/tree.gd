extends StaticBody2D

@onready var player_stats = get_node("/root/PlayerStats")

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
		rpc("_delete_self")
	pass # Replace with function body.

@rpc("any_peer", "call_local")
func _delete_self():
	queue_free()
