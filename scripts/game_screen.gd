tool
extends TileMap

var pos = Vector2(10, 0)
var size = Vector2(10, 18)

var refresh_time = 0.75
var counter = 0

var board_rect = Rect2(Vector2(), size)

var grid = []

var current_piece = null

signal piece_landed (piece)
signal score_gained (lines)
signal game_over


func _ready():
	set_fixed_process(true)

	for x in range(size.x):
		var arr = []
		for y in range(size.y):
			arr.append(0)
		grid.append(arr)


func _fixed_process(delta):
	if current_piece != null:
		if counter >= refresh_time:
			process_board()
			counter = 0

	counter += delta

	if not get_tree().is_editor_hint():
		update()


func process_board():
	var grav = current_piece.pos + Vector2(0, 1)

	if can_move(grav):
		move(grav)
	else:
		land_piece()
		emit_signal("piece_landed", current_piece)

		var full_lines = get_full_lines()
		var full_columns = get_full_columns()

		# Erasing full lines
		if full_lines.size() > 0:
			for line in full_lines:
				for x in range(size.x):
					grid[x][line] = 0

			emit_signal("score_gained", full_lines)
			fall_grid(full_lines)

		# Game over emit
		if full_columns.size() > 0:
			emit_signal("game_over")


func get_full_lines():
	var full_lines = []

	for column in range(size.y):
		for line in range(size.x):
			if grid[line][column] == 0:
				break

			if line == size.x - 1:
				full_lines.append(column)

	return full_lines


func get_full_columns():
	var full_columns = []

	var first_line = 0
	for column in range(size.x):
		if grid[column][first_line] == 1:
			full_columns.append(column)

	return full_columns


func fall_grid(full_lines):
	for line in full_lines:
		for x in range(size.x):
			for y in range(line - 1, -1, -1):
				if grid[x][y+1] == 0:
					grid[x][y+1] = grid[x][y]
					grid[x][y] = 0
			pass

func _draw():
	draw_set_transform(Vector2(get_cell_size().x, 0)/2, 0, get_cell_size())
	draw_rect(Rect2(pos, size), Color(0,0,0))

	if current_piece != null:
		var shape = current_piece.shape
		for x in range(shape.size()):
			for y in range(shape[x].size()):
				if shape[x][y] > 0:
					var pos = current_piece.pos
					draw_rect(Rect2(10 + pos.x + x, pos.y + y, 1, 1), Color(1, 0, 0))

	for x in range(grid.size()):
		for y in range(grid[x].size()):
			if grid[x][y] != 0:
				draw_rect( Rect2(10 + x, y, 1, 1), Color(1, 0, 0) )


func spawn(piece):
	current_piece = piece
	current_piece.pos = Vector2(4, 0)


func can_move(pos):
	if current_piece == null:
		return false

	var shape = current_piece.shape

	for x in range(shape.size()):
		for y in range(shape[0].size()):
			var p = pos + Vector2(x, y)

			if !is_inside_grid(p) or (shape[x][y] != 0 and grid[p.x][p.y] != 0):
				return false

	return true
	pass


func move(pos):
	if !can_move(pos): return false

	current_piece.pos = pos
	return true


func rotate_piece():
	var shape = transpose_shape(current_piece.shape)
	shape = reverse_columns(shape)

	var pos = current_piece.pos
	for x in range(shape.size()):
		for y in range(shape[0].size()):
			var new_pos = pos + Vector2(x, y)
			if shape[x][y] == 1 and !is_inside_grid(new_pos):
				pos = pos + Vector2(-1, 0)

	var rotate = true
	for x in range(shape.size()):
		for y in range(shape[0].size()):
			if !is_inside_bounds(pos + Vector2(x, y)):
				rotate = false
				break

	current_piece.shape = shape if rotate else current_piece.shape
	current_piece.pos = pos

func land_piece():
	var shape = current_piece.shape
	var pos = current_piece.pos

	for x in range(shape.size()):
		for y in range(shape[x].size()):
			if shape[x][y] != 0:
				var p = pos + Vector2(x, y)

				grid[p.x][p.y] = shape[x][y]


func is_inside_grid(pos):
	return pos.x >= board_rect.pos.x and pos.x < board_rect.size.x and \
	pos.y >= board_rect.pos.y and pos.y < board_rect.size.y


func is_inside_bounds(pos):
	if is_inside_grid(pos):
		return grid[pos.x][pos.y] == 0

	return false


func transpose_shape(matrix):
	# Create result matrix
	var result = []
	result.resize(matrix[0].size())

	for i in range(result.size()):
		var column = []
		column.resize(matrix.size())

		result[i] = column

	# Transpose matrix
	for i in range(matrix.size()):
		for j in range(matrix[0].size()):
			result[j][i] = matrix[i][j]

	return result


func reverse_columns(matrix):
	var result = []

	for column in matrix:
		var new_column = []
		new_column.resize(column.size())

		for index in range(column.size()):
			new_column[new_column.size() - index - 1] = column[index]

		result.append(new_column)

	return result