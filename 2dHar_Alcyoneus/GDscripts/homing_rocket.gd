extends Area2D

@export var eject_speed: float = 150.0

@export var min_homing_speed: float = 350.0
@export var max_homing_speed: float = 499.0

@export var drag: float = 3.0
@export var turn_speed: float = 5.0

@export var lifespan: float = 15.0

@export var visual_rotation_offset: float = 90

var player = null
@onready var sprite_engine = get_node_or_null("Sprite2D2")
@onready var main_sprite = get_node_or_null("Sprite2D")

enum State { EJECT, ARC, HOMING }
var current_state = State.EJECT

var velocity = Vector2.ZERO
var arc_target_pos = Vector2.ZERO
var current_homing_speed: float = 0.0

func _ready():
	player = get_tree().get_first_node_in_group("player")
	
	if sprite_engine: sprite_engine.visible = false
	
	if main_sprite:
		main_sprite.rotation_degrees = visual_rotation_offset
		if sprite_engine:
			sprite_engine.rotation_degrees = visual_rotation_offset
	
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
		
	current_homing_speed = randf_range(min_homing_speed, max_homing_speed)
	turn_speed = randf_range(3, 6);
		
	start_launch_sequence()

func start_launch_sequence():
	var side_dir = Vector2.UP.rotated(rotation) if randf() > 0.5 else Vector2.DOWN.rotated(rotation)
	velocity = side_dir * eject_speed
	
	rotation = velocity.angle()
	
	await get_tree().create_timer(randf_range(1.0, 3.5)).timeout
	
	if is_instance_valid(player):
		current_state = State.ARC
		if sprite_engine: sprite_engine.visible = true
		
		var random_angle = randf_range(0, 2 * PI)
		var offset = Vector2(cos(random_angle), sin(random_angle)) * randf_range(200, 400)
		arc_target_pos = player.global_position + offset
		
		await get_tree().create_timer(randf_range(0.5, 1.0)).timeout
		current_state = State.HOMING

func _physics_process(delta):
	lifespan -= delta
	if lifespan <= 0:
		queue_free()
		return

	match current_state:
		State.EJECT:
			velocity = velocity.move_toward(Vector2.ZERO, drag * delta)
			position += velocity * delta
			
			if velocity.length() > 10:
				var target_angle = velocity.angle()
				rotation = lerp_angle(rotation, target_angle, 5 * delta)

		State.ARC:
			move_towards_target(arc_target_pos, delta)

		State.HOMING:
			if is_instance_valid(player):
				move_towards_target(player.global_position, delta)
			else:
				position += Vector2.RIGHT.rotated(rotation) * current_homing_speed * delta

func move_towards_target(target: Vector2, delta: float):
	var direction = (target - global_position).normalized()
	var desired_angle = direction.angle()
	
	rotation = lerp_angle(rotation, desired_angle, turn_speed * delta)
	position += Vector2.RIGHT.rotated(rotation) * current_homing_speed * delta

func _on_body_entered(body):
	if body.is_in_group("player") and body.has_method("hit"):
		body.hit()
		explode()

func explode():
	queue_free()
	
func _on_area_entered(area: Node) -> void:
	if area.is_in_group("bullet"):
		area.queue_free()
		explode()
