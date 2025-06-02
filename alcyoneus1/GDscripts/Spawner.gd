extends Node2D

@export var asteroid_scene: PackedScene
@onready var timer = $AsteroidTimer
@onready var map_sprite := get_parent().get_node("CanvasLayer/ParallaxBackground/Sprite2D")

func _ready():
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	var asteroid = asteroid_scene.instantiate()


	var spawn_x = randf_range(-1250, 5400)
	var spawn_y = -2600

	asteroid.position = Vector2(spawn_x, spawn_y)

	asteroid.direction = Vector2(-0.5, 1).normalized()
	asteroid.speed = randf_range(100.0, 200.0)

	get_parent().add_child(asteroid)
