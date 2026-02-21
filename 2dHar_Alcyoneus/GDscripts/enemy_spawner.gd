extends Node2D

@export var enemy_scene: PackedScene

@export var min_spawn_time: float = 1.0
@export var max_spawn_time: float = 2.0

@export var max_enemies_total: int = 0

@export var spawn_area_size: Vector2 = Vector2(4000, 200)

@export var increase_limit_time: float = 10.0

@export var when_infinity: float = 30.0

var current_enemy_count: int = 0

func _ready():
	spawn_loop()
	difficulty_loop()

func difficulty_loop():
	while true:
		await get_tree().create_timer(increase_limit_time).timeout
		
		if max_enemies_total != -1:
			max_enemies_total += 1
			
			if max_enemies_total >= when_infinity:
				max_enemies_total = -1

func spawn_loop():
	while true:
		if max_enemies_total != -1 and current_enemy_count >= max_enemies_total:
			await get_tree().create_timer(0.5).timeout
			continue

		var wait_time = randf_range(min_spawn_time, max_spawn_time)
		await get_tree().create_timer(wait_time).timeout
		
		spawn_enemy()

func spawn_enemy():
	if not enemy_scene:
		return

	var enemy = enemy_scene.instantiate()
	
	var random_offset = Vector2(
		randf_range(0, spawn_area_size.x),
		randf_range(0, spawn_area_size.y)
	)
	
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = global_position + random_offset
	
	current_enemy_count += 1
	enemy.tree_exited.connect(_on_enemy_died)

func _on_enemy_died():
	current_enemy_count -= 1
	if current_enemy_count < 0:
		current_enemy_count = 0
