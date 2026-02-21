extends Area2D

@export var speed: float = 300.0
@export var preferred_distance: float = 900;
@export var retreat_margin: float = 400.0
@export var score_value: int = 500

@export var rocket_scene: PackedScene
@onready var launch_point = get_node_or_null("LaunchPoint")

var rockets_per_volley: int = 1
var can_shoot: bool = true
var shoot_cooldown: float = 5.0


var player = null
var map_limits = Rect2(-450, 1900, 3900, 3500) 

func _ready():
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")
	
	preferred_distance = randf_range(800,1500)
	
	var upgrade_timer = Timer.new()
	upgrade_timer.wait_time = 20.0
	upgrade_timer.autostart = true
	upgrade_timer.timeout.connect(_on_upgrade)
	add_child(upgrade_timer)

func _physics_process(delta):
	if not player or not is_instance_valid(player):
		return

	var dist_to_player = global_position.distance_to(player.global_position)
	var dir_to_player = (player.global_position - global_position).normalized()
	var velocity = Vector2.ZERO

	if dist_to_player < (preferred_distance - retreat_margin):
		velocity = -dir_to_player * speed
	elif dist_to_player > (preferred_distance + retreat_margin):
		velocity = dir_to_player * speed
	else:
		velocity = dir_to_player.rotated(PI / 2) * (speed * 0.5)
	
	position += velocity * delta
	
	look_at(player.global_position)
	
	if can_shoot:
		fire_volley()

func fire_volley():
	can_shoot = false
	
	for i in range(rockets_per_volley):
		spawn_rocket()
		await get_tree().create_timer(0.3).timeout
	
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true

func spawn_rocket():
	if not rocket_scene: return
	
	var rocket = rocket_scene.instantiate()
	get_tree().current_scene.add_child(rocket)
	
	if launch_point:
		rocket.global_position = launch_point.global_position
	else:
		rocket.global_position = global_position
	
	rocket.rotation = rotation

func _on_upgrade():
	rockets_per_volley += 1


func hit():
	die()

func die():
	if has_node("/root/ScoreManager"):
		ScoreManager.add_score(score_value)
	queue_free()
