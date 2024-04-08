extends Node2D

var peer = ENetMultiplayerPeer.new()

var PORT = 25565
var ip_address = "127.0.0.1"

var map_x = 0
var map_y = 0

@export var player_scene : PackedScene
@onready var cam = $Camera2D
@onready var menu = $Menu
@onready var tile_map = $TileMap

@onready var username = $Menu/Panel/Username
@onready var ip_address_input = $"Menu/Panel/Ip Address"

@onready var chunk_loader_timer = $chunk_loader

@onready var player_stats = get_node("/root/PlayerStats")


func _on_host_pressed():
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)
	multiplayer.connected_to_server.connect(connected_to_server)
	add_player()
	player_stats.usernames[1] = username.text
	cam.enabled = false
	menu.visible = false
	
	
	

func _on_join_pressed():
	if len(ip_address_input.text) != 0:
		ip_address = ip_address_input.text
		
	peer.create_client(ip_address, PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(connected_to_server)	
	cam.enabled = false
	menu.visible = false	
	
func connected_to_server():
	tile_map.clear()
	rpc("_send_player_info", username.text, multiplayer.get_unique_id())
	chunk_loader_timer.start()

func add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)

func exit_game(id):
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)

func del_player(id):
	rpc("_del_player", id)

@rpc("any_peer", "call_local")
func _request_chunk(requester_id, chunk_coords : Vector2i):
	if multiplayer.is_server():
		var starting_x = 0 + 32 * chunk_coords.x
		var starting_y = 0 + 32 * chunk_coords.y
		
		var map_info = {}
		for y in range(32):
			for x in range(32):
				map_info[Vector2i(starting_x + x, starting_y + y)] = []
				map_info[Vector2i(starting_x + x, starting_y + y)].append(tile_map.get_cell_atlas_coords(0, Vector2i(starting_x + x, starting_y + y)))
				map_info[Vector2i(starting_x + x, starting_y + y)].append(tile_map.get_cell_alternative_tile(1, Vector2i(starting_x + x, starting_y + y)))
				map_info[Vector2i(starting_x + x, starting_y + y)].append(tile_map.get_cell_atlas_coords(2, Vector2i(starting_x + x, starting_y + y)))
		rpc("_load_chunk", requester_id, map_info)
	
@rpc("any_peer", "call_local")
func _load_chunk(id, map_info):
	if multiplayer.get_unique_id() == id:
		for tile in map_info:
			tile_map.set_cell(0, tile, 0, map_info[tile][0])
			if map_info[tile][1] != -1:
				tile_map.set_cell(1, tile, 1, Vector2i(0,0))
			tile_map.set_cell(2, tile, 0, map_info[tile][2])


@rpc("any_peer")
func _send_player_info(usrname, id):
	if !player_stats.usernames.has(id):
		player_stats.usernames[id] = usrname
	
	if multiplayer.is_server():
		for i in player_stats.usernames:
			rpc("_send_player_info", player_stats.usernames[i], i)

@rpc("any_peer", "call_local")
func _del_player(id):
	get_node(str(id)).queue_free()


func _on_chunk_loader_timeout():
		rpc("_request_chunk", multiplayer.get_unique_id(), Vector2i(0,0))
		rpc("_request_chunk", multiplayer.get_unique_id(), Vector2i(-1,0))
		rpc("_request_chunk", multiplayer.get_unique_id(), Vector2i(0,-1))
		rpc("_request_chunk", multiplayer.get_unique_id(), Vector2i(-1, -1))
