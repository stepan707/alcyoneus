extends Control

@onready var game_over_label: Label = $BackgroundPanel/ContentContainer/GameOverLabel
@onready var score_label: Label = $BackgroundPanel/ContentContainer/CurrentScore
@onready var best_score_label: Label = $BackgroundPanel/ContentContainer/BestScore
@onready var play_again_button: Button = $BackgroundPanel/ContentContainer/PlayAgainButton
@onready var main_menu_button: Button = $BackgroundPanel/ContentContainer/MainMenuButton

@onready var hoverSound = get_node_or_null("hover")
@onready var music_player = get_node_or_null("GameOver")

func _ready():
	if music_player:
		music_player.play()
	
	if play_again_button:
		play_again_button.pressed.connect(_on_play_again_button_pressed)
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	
	set_scores()

func set_scores():
	var current_score = ScoreManager.score
	
	ScoreManager.save_score_to_supabase(current_score)
	
	var best_score = ScoreManager.best_score
	
	if game_over_label:
		game_over_label.text = "Konec hry!"
		
	if score_label:
		score_label.text = "Vaše skóre: %d" % current_score
		
	if best_score_label:
		if current_score >= best_score and current_score > 0:
			best_score_label.text = "Nejlepší skóre: %d (NOVÝ REKORD!)" % current_score
			best_score_label.add_theme_color_override("font_color", Color.GREEN) # Zelená barva pro radost
		else:
			best_score_label.text = "Nejlepší skóre: %d" % best_score
			best_score_label.add_theme_color_override("font_color", Color.WHITE)


func _on_play_again_button_pressed():
	ScoreManager.reset_score()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_main_menu_button_pressed():
	ScoreManager.reset_score()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_mouse_entered() -> void:
	if hoverSound:
		hoverSound.play()
