extends Control

var board = ["", "", "", "", "", "", "", "", ""]
var current_player = 1  # 1 = X (host), 2 = O (cliente)
var my_player_id = 1
var game_over = false

@onready var status_label = $VBoxContainer/StatusLabel
@onready var grid = $VBoxContainer/GridContainer
@onready var restart_button = $VBoxContainer/RestartButton

func _ready():
	my_player_id = 1 if multiplayer.get_unique_id() == 1 else 2
	for i in range(9):
		var btn = grid.get_child(i)
		btn.pressed.connect(_on_cell_pressed.bind(i))
	restart_button.pressed.connect(_on_restart_pressed)
	_update_status()

func _on_cell_pressed(index):
	if game_over:
		return
	if current_player != my_player_id:
		return
	if board[index] != "":
		return
	make_move.rpc(index, my_player_id)

@rpc("any_peer", "call_local", "reliable")
func make_move(index, player):
	if board[index] != "" or game_over:
		return
	board[index] = "X" if player == 1 else "O"
	var btn = grid.get_child(index)
	btn.text = board[index]
	btn.disabled = true

	var winner = _check_winner()
	if winner != 0:
		game_over = true
		status_label.text = "¡Ganó X!" if winner == 1 else "¡Ganó O!"
	elif _board_full():
		game_over = true
		status_label.text = "¡Empate!"
	else:
		current_player = 2 if player == 1 else 1
		_update_status()

func _update_status():
	if game_over:
		return
	var turn_text = "Turno de X" if current_player == 1 else "Turno de O"
	if current_player == my_player_id:
		turn_text += "  (tu turno)"
	status_label.text = turn_text

func _check_winner():
	var lines = [
		[0, 1, 2], [3, 4, 5], [6, 7, 8],
		[0, 3, 6], [1, 4, 7], [2, 5, 8],
		[0, 4, 8], [2, 4, 6],
	]
	for line in lines:
		var a = board[line[0]]
		var b = board[line[1]]
		var c = board[line[2]]
		if a != "" and a == b and b == c:
			return 1 if a == "X" else 2
	return 0

func _board_full():
	for cell in board:
		if cell == "":
			return false
	return true

func _on_restart_pressed():
	reset_game.rpc()

@rpc("any_peer", "call_local", "reliable")
func reset_game():
	board = ["", "", "", "", "", "", "", "", ""]
	current_player = 1
	game_over = false
	for i in range(9):
		var btn = grid.get_child(i)
		btn.text = ""
		btn.disabled = false
	_update_status()
