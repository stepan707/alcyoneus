extends Control

@onready var content_container: Control = $BackgroundPanel/ContentContainer
@onready var game_over_label: Label = $BackgroundPanel/ContentContainer/GameOverLabel
@onready var score_label: Label = $BackgroundPanel/ContentContainer/CurrentScore
@onready var best_score_label: Label = $BackgroundPanel/ContentContainer/BestScore
@onready var play_again_button: Button = $BackgroundPanel/ContentContainer/PlayAgainButton
@onready var main_menu_button: Button = $BackgroundPanel/ContentContainer/MainMenuButton

var current_score = 0
var best_score = 0

func _ready():
	if content_container == null:
		return 

	if play_again_button:
		if not play_again_button.is_connected("pressed", _on_play_again_button_pressed):
			play_again_button.connect("pressed", _on_play_again_button_pressed)

	if main_menu_button:
		if not main_menu_button.is_connected("pressed", _on_main_menu_button_pressed):
			main_menu_button.connect("pressed", _on_main_menu_button_pressed)

	set_scores(ScoreManager.score)

func set_scores(score: int):
	current_score = score
	best_score = load_best_score()

	if game_over_label: 
		game_over_label.text = "Konec hry!"
	if score_label:
		score_label.text = "Vaše skóre: %d" % current_score
	if best_score_label:
		best_score_label.text = "Nejlepší skóre: %d" % best_score

	if current_score > best_score:
		save_best_score(current_score)
		if best_score_label:
			best_score_label.text = "Nejlepší skóre: %d (NOVÝ REKORD!)" % current_score

func _on_play_again_button_pressed():
	get_tree().change_scene_to_file("res://scenes/level1.tscn")

func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func save_best_score(score: int):
	var file = FileAccess.open("user://best_score.save", FileAccess.WRITE)
	if file:
		file.store_var(score)
		file.close()

func load_best_score():
	var file = FileAccess.open("user://best_score.save", FileAccess.READ)
	if file:
		var loaded_score = file.get_var()
		file.close()
		return loaded_score
	else:
		return 0
