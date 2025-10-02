extends Control

@onready var music_player = get_node("MusicPlayer")

func _ready() -> void:
	music_player.play()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Credit_Scene.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
