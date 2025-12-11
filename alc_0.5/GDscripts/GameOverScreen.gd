extends Control

@onready var content_container: Control = $BackgroundPanel/ContentContainer
@onready var game_over_label: Label = $BackgroundPanel/ContentContainer/GameOverLabel
@onready var score_label: Label = $BackgroundPanel/ContentContainer/CurrentScore
@onready var best_score_label: Label = $BackgroundPanel/ContentContainer/BestScore
@onready var play_again_button: Button = $BackgroundPanel/ContentContainer/PlayAgainButton
@onready var main_menu_button: Button = $BackgroundPanel/ContentContainer/MainMenuButton
@onready var music_player = get_node("GameOver")
@onready var hoverSound = get_node("hover")

func _ready():	
	if content_container == null:
		return	
	if play_again_button:
		play_again_button.connect("pressed", _on_play_again_button_pressed)
	if main_menu_button:
		main_menu_button.connect("pressed", _on_main_menu_button_pressed)
	set_scores()
	music_player.play()


func set_scores():
	var current_score = ScoreManager.score
	var best_score = ScoreManager.load_best_score()
	if game_over_label:
		game_over_label.text = "Konec hry!"
	if score_label:
		score_label.text = "Vaše skóre: %d" % current_score
	if best_score_label:
		best_score_label.text = "Nejlepší skóre: %d" % best_score

	if current_score > best_score:
		ScoreManager.save_best_score(current_score)
		if best_score_label:
			best_score_label.text = "Nejlepší skóre: %d (NOVÝ REKORD!)" % current_score


func _on_play_again_button_pressed():
	ScoreManager.reset_score()
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_main_menu_button_pressed():
	ScoreManager.reset_score()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_mouse_entered() -> void:
	hoverSound.play()
