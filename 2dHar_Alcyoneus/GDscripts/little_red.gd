extends Area2D

@export var speed: float = 200.0
@export var wobble_frequency: float = 5
@export var wobble_amplitude: float = 250
@export var attack_range: float = 100
@export var retreat_distance: float = 1200
@export var score_value: int = 500

var player = null

@onready var attack_pivot = get_node_or_null("AttackPivot")
@onready var slash_area = get_node_or_null("AttackPivot/SlashArea")
@onready var slash_anim = get_node_or_null("AttackPivot/SlashArea/AnimatedSprite2D")
@onready var slash_col = get_node_or_null("AttackPivot/SlashArea/CollisionShape2D")

enum State { CHASE, ATTACK, RETREAT }
var current_state = State.CHASE
var time_alive: float = 0.0

func _ready():
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")
	
	wobble_frequency = randf_range(1,10)
	wobble_amplitude = randf_range(100,500)
	attack_range = randf_range(80,120)
	retreat_distance = randf_range(500,1500)
	
	if slash_anim: slash_anim.visible = false
	if slash_col: slash_col.disabled = true
	
	if slash_area:
		slash_area.monitoring = true
		connect("body_entered", self._on_body_entered)

func _physics_process(delta):
	if not player or not is_instance_valid(player):
		return 
		
	time_alive += delta
	
	match current_state:
		State.CHASE:
			state_chase(delta)
		State.ATTACK:
			pass
		State.RETREAT:
			state_retreat(delta)

func state_chase(delta):
	var direction_to_player = (player.global_position - global_position).normalized()
	var distance_to_player = global_position.distance_to(player.global_position)
	
	var perpendicular = Vector2(-direction_to_player.y, direction_to_player.x)
	var wobble = perpendicular * sin(time_alive * wobble_frequency) * wobble_amplitude
	
	var target_velocity = (direction_to_player * speed) + wobble
	position += target_velocity * delta
	
	if target_velocity.length_squared() > 0:
		look_at(global_position + target_velocity)
		rotate(deg_to_rad(90))
	
	if distance_to_player < attack_range:
		start_attack()

func start_attack():
	current_state = State.ATTACK
	
	if attack_pivot:
		attack_pivot.look_at(player.global_position)
		attack_pivot.rotate(deg_to_rad(90))
	
	look_at(player.global_position)
	rotate(deg_to_rad(90))
	
	if slash_anim:
		slash_anim.visible = true
		slash_anim.frame = 0
		slash_anim.play("default")
	
	if slash_col:
		slash_col.set_deferred("disabled", false)
	
	if slash_anim and slash_anim.sprite_frames.get_frame_count("default") > 0:
		await slash_anim.animation_finished
	else:
		await get_tree().create_timer(0.5).timeout
	
	if slash_anim:
		slash_anim.stop()
		slash_anim.visible = false
	
	if slash_col:
		slash_col.set_deferred("disabled", true)
	
	current_state = State.RETREAT
	await get_tree().create_timer(1.5).timeout
	current_state = State.CHASE

func state_retreat(delta):
	var direction_away = (global_position - player.global_position).normalized()
	position += direction_away * (speed * 1.5) * delta
	look_at(global_position + direction_away)
	rotate(deg_to_rad(90))


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.hit()

func hit():
	die()

func die():
	if has_node("/root/ScoreManager"):
		ScoreManager.add_score(score_value)
	queue_free()
