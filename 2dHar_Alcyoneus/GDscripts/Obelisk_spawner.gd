extends Node2D

@export var obelisk_scene: PackedScene

@export var min_spawn_time: float = 3
@export var max_spawn_time: float = 12

@export var spawn_area_size: Vector2 = Vector2(3700, 3500) 

func _ready():
	spawn_loop()

func spawn_loop():
	while true:
		var wait_time = randf_range(min_spawn_time, max_spawn_time)
		await get_tree().create_timer(wait_time).timeout
		spawn_obelisk()

func spawn_obelisk():
	if not obelisk_scene:
		print("CHYBA: Není přiřazena scéna Obelisku v Inspectoru!")
		return

	var obelisk = obelisk_scene.instantiate()
	
	var random_x = randf_range(-900, spawn_area_size.x)
	var random_y = randf_range(-2200, spawn_area_size.y)
	
	obelisk.position = Vector2(random_x, random_y)
	
	get_tree().current_scene.add_child(obelisk)
