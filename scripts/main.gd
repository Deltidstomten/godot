extends Node2D

var peer = ENetMultiplayerPeer.new()

var PORT = 25565
var ip_address = "127.0.0.1"

@export var player_scene : PackedScene
@onready var cam = $Camera2D
@onready var menu = $Menu

@onready var username = $Menu/Panel/Username
@onready var ip_address_input = $"Menu/Panel/Ip Address"

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
	rpc("_send_player_info", username.text, multiplayer.get_unique_id())
	pass

func add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)

func exit_game(id):
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)

func del_player(id):
	rpc("_del_player", id)

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
