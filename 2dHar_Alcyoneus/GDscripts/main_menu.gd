extends Control

@onready var music_player = get_node("MusicPlayer")

func _ready() -> void:
	music_player.play()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Credit_Scene.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_setings_pressed() -> void:
	pass # Replace with function body.


func _on_garage_pressed() -> void:
	pass # Replace with function body.
