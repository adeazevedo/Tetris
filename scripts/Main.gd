
extends Node2D

onready var gscreen = get_node("game_screen")

var current_piece = null
var score = 0

func _ready():
	set_fixed_process(true)

	gscreen.connect("piece_landed", self, "on_piece_land")
	gscreen.connect("score_gained", self, "on_score_gained")
	gscreen.connect("game_over", self, "on_game_over")


func _fixed_process(delta):
	if current_piece == null:
		spawn_random_piece()

		set_process_input(true)


func spawn_random_piece():
	current_piece = TetraminoFactory.create_random_piece()
	gscreen.spawn(current_piece)


func on_piece_land (piece_landed):
	spawn_random_piece()


func on_score_gained(lines):
	score += 5 * lines.size()

	var label = get_node("score_label")

	label.set_text("Score:\n%d" % score)


func on_game_over():
	print("Game Over")
	gscreen.set_fixed_process(false)


func _input(event):
	var right = Input.is_action_pressed("ui_right")
	var left = Input.is_action_pressed("ui_left")
	var h_axis = right - left

	var v_axis = 0
	if event.is_action("ui_down"):
		if event.is_pressed() and event.is_echo():
			v_axis = 1

	gscreen.move(current_piece.pos + Vector2(h_axis, v_axis))

	if event.is_action("ui_select"):
		if event.is_pressed() and not event.is_echo():
			gscreen.rotate_piece()