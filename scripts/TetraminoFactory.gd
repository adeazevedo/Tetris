extends Node2D

func _ready():
	randomize()


func create(type):
	var tetramino = {
		"shape": [],
		"pos": Vector2()
	}

	if type == 1:
		tetramino["shape"] = [[1, 1, 1, 1]]

	if type == 2:
		tetramino["shape"] = [
			[0, 1, 0],
			[1, 1, 1]]

	if type == 3:
		tetramino["shape"] = [
			[1, 1],
			[0, 1],
			[0, 1]]

	if type == 4:
		tetramino["shape"] = [
			[1, 1, 0],
			[0, 1, 1]]

	if type == 5:
		tetramino["shape"] = [
			[1, 1],
			[1, 1]]

	return tetramino

# 1 - 0.15
# 2 - 0.25
# 3 - 0.2
# 4 - 0.2
# 5 - 0.2
#
#
var cdf_array = [0.15, .35, .60, .80, 1]

func create_random_piece():
	var found = false
	var index = 0

	var chance = randf(0, 1)
	while not found:
		if cdf_array[index] > chance:
			break

		index += 1

	var piece = TetraminoFactory.create(index + 1)

	#piece.show()

	return piece