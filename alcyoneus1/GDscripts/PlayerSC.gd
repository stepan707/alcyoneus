extends CharacterBody2D

@export var speed = 400
var thruster_anim: AnimatedSprite2D
var alive: bool = true

var can_shoot := true
var shoot_cooldown := 4.0  
@export var bullet_scene: PackedScene


func _ready():
	thruster_anim = $AnimatedSprite2D
	ScoreManager.score = 0
	ScoreManager.running = true
	get_tree().paused = false

func _physics_process(_delta):
	var direction = (get_global_mouse_position() - global_position).normalized()
	velocity = direction * speed
	look_at(get_global_mouse_position())
	move_and_slide()
	
	if velocity.length() > 0:
		if not thruster_anim.is_playing():
			thruster_anim.play("fly")
	else:
		thruster_anim.stop()
	
	if Input.is_action_just_pressed("shoot") and can_shoot:
		shoot_bullet()
		can_shoot = false
		await get_tree().create_timer(shoot_cooldown).timeout
		can_shoot = true



func hit() -> void:
	if alive:
		alive = false
		ScoreManager.running = false
		get_tree().paused = true
		print("Hráč byl zasažen!")
		print("Tvé skóre: ", ScoreManager.score)



func shoot_bullet():
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	
	var direction = (get_global_mouse_position() - global_position).normalized()
	bullet.set_direction(direction)
