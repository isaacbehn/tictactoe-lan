extends Control

const PORT = 7878

@onready var host_button = $CenterContainer/VBoxContainer/HostButton
@onready var join_button = $CenterContainer/VBoxContainer/JoinButton
@onready var ip_input = $CenterContainer/VBoxContainer/IPInput
@onready var status_label = $CenterContainer/VBoxContainer/StatusLabel
@onready var my_ip_label = $CenterContainer/VBoxContainer/MyIPLabel

func _ready():
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	_show_local_ip()

func _show_local_ip():
	var addresses = IP.get_local_addresses()
	var lan_ip = ""
	for addr in addresses:
		if addr.begins_with("192.168.") or addr.begins_with("10.") or addr.begins_with("172."):
			lan_ip = addr
			break
	if lan_ip != "":
		my_ip_label.text = "Tu IP en esta red: %s" % lan_ip
	else:
		my_ip_label.text = ""

func _on_host_pressed():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, 1)
	if error != OK:
		status_label.text = "Error al crear el servidor (%s)" % error
		return
	multiplayer.multiplayer_peer = peer
	status_label.text = "Esperando al segundo jugador..."
	host_button.disabled = true
	join_button.disabled = true

func _on_join_pressed():
	var ip = ip_input.text.strip_edges()
	if ip == "":
		status_label.text = "Escribe la IP del anfitrión"
		return
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, PORT)
	if error != OK:
		status_label.text = "Error al conectar (%s)" % error
		return
	multiplayer.multiplayer_peer = peer
	status_label.text = "Conectando..."
	host_button.disabled = true
	join_button.disabled = true

func _on_peer_connected(_id):
	# Solo el host dispara el cambio de escena para todos.
	if multiplayer.is_server():
		_start_game.rpc()

func _on_connected_to_server():
	status_label.text = "Conectado. Iniciando partida..."

func _on_connection_failed():
	status_label.text = "No se pudo conectar. Revisa la IP y que ambos estén en la misma red."
	host_button.disabled = false
	join_button.disabled = false

func _on_server_disconnected():
	status_label.text = "El anfitrión se desconectó."

@rpc("call_local", "reliable")
func _start_game():
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
