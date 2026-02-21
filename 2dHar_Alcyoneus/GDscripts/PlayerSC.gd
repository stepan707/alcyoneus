extends CharacterBody2D

@onready var engine_sound = $EnginePlayer
@onready var thruster_anim = $AnimatedSprite2D
@onready var shoot_sound = $ShootPlayer
@onready var music_player = get_node("/root/Node2D/MusicPlayer")
@onready var explosion_player = get_node("/root/Node2D/ExplosionPlayer")
@onready var explosion_sprite = $ExplosionSprite2D

@export var acceleration = 800.0
@export var friction = 600.0

var powerup_timer: Timer = null

var level = 1

@export var speed = 400
var alive = true

var can_shoot := true
var shoot_cooldown := 1.0
@export var bullet_scene: PackedScene

func _ready():
	thruster_anim = $AnimatedSprite2D
	
	get_tree().paused = false

	engine_sound.play()
	if music_player: music_player.play()
	
	engine_sound.set("pause_mode", "process")
	if music_player: music_player.set("pause_mode", "stop")
	if explosion_player: explosion_player.set("pause_mode", "process")
	
	engine_sound.process_mode = Node.PROCESS_MODE_INHERIT
	if music_player: music_player.process_mode = Node.PROCESS_MODE_INHERIT
	if explosion_player: explosion_player.process_mode = Node.PROCESS_MODE_INHERIT
	
	explosion_sprite.visible = false
	powerup_timer = Timer.new()
	powerup_timer.wait_time = 10.0
	powerup_timer.one_shot = true
	powerup_timer.timeout.connect(_on_powerup_ended)
	add_child(powerup_timer)



func activate_ultimate_mode():
	level = 100
	powerup_timer.start()

func _on_powerup_ended():
	if level >= 100:
		level = 10 


func _physics_process(delta):
	if not alive:
		return
	
	look_at(get_global_mouse_position())

	if Input.is_action_pressed("ui_up") or Input.is_physical_key_pressed(KEY_W):
		var direction = (get_global_mouse_position() - global_position).normalized()
		
		var target_velocity = direction * speed
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
		
		if not thruster_anim.is_playing():
			thruster_anim.play("fly")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		thruster_anim.stop()
	
	move_and_slide()
	
	if Input.is_action_just_pressed("shoot") and can_shoot:
		shoot_bullet()
		can_shoot = false
		await get_tree().create_timer(shoot_cooldown).timeout
		can_shoot = true


func _process(_delta):    
	if alive:
		if not engine_sound.playing:
			engine_sound.play()
		if music_player and not music_player.playing:
			music_player.play()


func hit() -> void:
	if alive:
		alive = false
		engine_sound.stop()
		if music_player: music_player.stop()
		if explosion_player: explosion_player.play()        
		thruster_anim.visible = false        
		explosion_sprite.visible = true
		
		await get_tree().create_timer(1.5).timeout        
		
		set_process(false)
		set_physics_process(false)
		get_tree().change_scene_to_file("res://scenes/GameOverScene.tscn")


func shoot_bullet():
	if not bullet_scene:
		return

	shoot_sound.play()

	var mouse_dir = (get_global_mouse_position() - global_position).normalized()
	match level:
		1:
			spawn_projectile(mouse_dir, 0, 0)
			
		2:
			spawn_projectile(mouse_dir, 2, 5)
			spawn_projectile(mouse_dir, -2, -5)
			
		3:
			spawn_projectile(mouse_dir, 0, 0)
			spawn_projectile(mouse_dir, -15, 0)
			spawn_projectile(mouse_dir, 15, 0)
			
		4:
			spawn_projectile(mouse_dir, 2, 5)
			spawn_projectile(mouse_dir, -2, -5)
			spawn_projectile(mouse_dir, -20, -10)
			spawn_projectile(mouse_dir, 20, 10)
			
		5:
			spawn_projectile(mouse_dir, 0, 0)
			spawn_projectile(mouse_dir, -10, 0)
			spawn_projectile(mouse_dir, 10, 0)
			spawn_projectile(mouse_dir, -25, 0)
			spawn_projectile(mouse_dir, 25, 0)
			
		6:
			spawn_projectile(mouse_dir, 2, 5)
			spawn_projectile(mouse_dir, -2, -5)
			spawn_projectile(mouse_dir, -15, 0)
			spawn_projectile(mouse_dir, 15, 0)
			spawn_projectile(mouse_dir, -25, 0)
			spawn_projectile(mouse_dir, 25, 0)
			
		7:
			spawn_projectile(mouse_dir, 2, 5)
			spawn_projectile(mouse_dir, -2, -5)
			spawn_projectile(mouse_dir, -10, 0)
			spawn_projectile(mouse_dir, 10, 0)
			spawn_projectile(mouse_dir, -15, 0)
			spawn_projectile(mouse_dir, 15, 0)
			spawn_projectile(mouse_dir, -25, 0)
			spawn_projectile(mouse_dir, 25, 0)
		8:
			spawn_projectile(mouse_dir, 2, 5)
			spawn_projectile(mouse_dir, -2, -5)
			spawn_projectile(mouse_dir, -10, 0)
			spawn_projectile(mouse_dir, 10, 0)
			spawn_projectile(mouse_dir, -15, 0)
			spawn_projectile(mouse_dir, 15, 0)
			spawn_projectile(mouse_dir, -25, 0)
			spawn_projectile(mouse_dir, 25, 0)
			spawn_projectile(mouse_dir, -30, 0)
			spawn_projectile(mouse_dir, 30, 0)
			
		9:
			spawn_projectile(mouse_dir, 2, 5)
			spawn_projectile(mouse_dir, -2, -5)
			spawn_projectile(mouse_dir, -10, 0)
			spawn_projectile(mouse_dir, 10, 0)
			spawn_projectile(mouse_dir, -15, 0)
			spawn_projectile(mouse_dir, 15, 0)
			spawn_projectile(mouse_dir, -25, 0)
			spawn_projectile(mouse_dir, 25, 0)
			spawn_projectile(mouse_dir, -30, 0)
			spawn_projectile(mouse_dir, 30, 0)
			spawn_projectile(mouse_dir, -35, 0)
			spawn_projectile(mouse_dir, 35, 0)
		10:
			spawn_projectile(mouse_dir, 2, 5)
			spawn_projectile(mouse_dir, -2, -5)
			spawn_projectile(mouse_dir, -10, 0)
			spawn_projectile(mouse_dir, 10, 0)
			spawn_projectile(mouse_dir, -15, 0)
			spawn_projectile(mouse_dir, 15, 0)
			spawn_projectile(mouse_dir, -25, 0)
			spawn_projectile(mouse_dir, 25, 0)
			spawn_projectile(mouse_dir, -30, 0)
			spawn_projectile(mouse_dir, 30, 0)
			spawn_projectile(mouse_dir, -35, 0)
			spawn_projectile(mouse_dir, 35, 0)
			spawn_projectile(mouse_dir, -40, 0)
			spawn_projectile(mouse_dir, 40, 0)
		100:
			spawn_projectile(mouse_dir, 2, 5)
			spawn_projectile(mouse_dir, -2, -5)
			spawn_projectile(mouse_dir, -10, 0)
			spawn_projectile(mouse_dir, 10, 0)
			spawn_projectile(mouse_dir, -15, 0)
			spawn_projectile(mouse_dir, 15, 0)
			spawn_projectile(mouse_dir, -25, 0)
			spawn_projectile(mouse_dir, 25, 0)
			spawn_projectile(mouse_dir, -30, 0)
			spawn_projectile(mouse_dir, 30, 0)
			spawn_projectile(mouse_dir, -35, 0)
			spawn_projectile(mouse_dir, 35, 0)
			spawn_projectile(mouse_dir, -40, 0)
			spawn_projectile(mouse_dir, 40, 0)
			spawn_projectile(mouse_dir, -45, 0)
			spawn_projectile(mouse_dir, 45, 0)
			spawn_projectile(mouse_dir, -50, 0)
			spawn_projectile(mouse_dir, 50, 0)
			spawn_projectile(mouse_dir, -55, 0)
			spawn_projectile(mouse_dir, 55, 0)
			spawn_projectile(mouse_dir, -60, 0)
			spawn_projectile(mouse_dir, 60, 0)
			spawn_projectile(mouse_dir, -65, 0)
			spawn_projectile(mouse_dir, 65, 0)
			spawn_projectile(mouse_dir, -70, 0)
			spawn_projectile(mouse_dir, 70, 0)
			spawn_projectile(mouse_dir, -75, 0)
			spawn_projectile(mouse_dir, 75, 0)
			spawn_projectile(mouse_dir, 180, 0)
			spawn_projectile(mouse_dir, -175, 0)
			spawn_projectile(mouse_dir, 175, 0)
			spawn_projectile(mouse_dir, -170, 0)
			spawn_projectile(mouse_dir, 170, 0)
			spawn_projectile(mouse_dir, -165, 0)
			spawn_projectile(mouse_dir, 165, 0)
			
		_:
			spawn_projectile(mouse_dir, 2, 5)
			spawn_projectile(mouse_dir, -2, -5)
			spawn_projectile(mouse_dir, -10, 0)
			spawn_projectile(mouse_dir, 10, 0)
			spawn_projectile(mouse_dir, -15, 0)
			spawn_projectile(mouse_dir, 15, 0)
			spawn_projectile(mouse_dir, -25, 0)
			spawn_projectile(mouse_dir, 25, 0)
			spawn_projectile(mouse_dir, -30, 0)
			spawn_projectile(mouse_dir, 30, 0)
			spawn_projectile(mouse_dir, -35, 0)
			spawn_projectile(mouse_dir, 35, 0)
			spawn_projectile(mouse_dir, -40, 0)
			spawn_projectile(mouse_dir, 40, 0)


func spawn_projectile(base_dir: Vector2, angle_offset_deg: float, position_offset: float):
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	
	var final_dir = base_dir.rotated(deg_to_rad(angle_offset_deg))

	var perp_dir = Vector2(-base_dir.y, base_dir.x)
	var spawn_pos = global_position + (perp_dir * position_offset)
	
	bullet.global_position = spawn_pos
	
	if bullet.has_method("set_direction"):
		bullet.set_direction(final_dir)
