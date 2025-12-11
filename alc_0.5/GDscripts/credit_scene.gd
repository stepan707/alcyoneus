extends Node2D

@onready var hoverSound = get_node("hover")

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_mouse_entered() -> void:
	hoverSound.play()
