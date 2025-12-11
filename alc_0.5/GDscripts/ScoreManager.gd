extends Node

var score: int = 0

func add_score(value: int):
	score += value

func reset_score():
	score = 0

func save_best_score(score_to_save: int):
	var file = FileAccess.open("user://best_score.save", FileAccess.WRITE)
	if file:
		file.store_var(score_to_save)
		file.close()

func load_best_score() -> int:
	var file = FileAccess.open("user://best_score.save", FileAccess.READ)
	if file:
		var loaded_score = file.get_var()
		file.close()
		return loaded_score
	else:
		return 0
