extends TileMap

@rpc("any_peer","call_local")
func _delete_cell(layer, pos):
	erase_cell(layer, pos)
