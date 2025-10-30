extends CharacterBody2D

@onready var engine_sound = $EnginePlayer
@onready var thruster_anim = $AnimatedSprite2D
@onready var shoot_sound = $ShootPlayer
@onready var music_player = get_node("/root/Node2D/MusicPlayer")
@onready var explosion_player = get_node("/root/Node2D/ExplosionPlayer")
@onready var explosion_sprite = $ExplosionSprite2D

@export var speed = 400
var alive = true

var can_shoot := true
var shoot_cooldown := 0.5
@export var bullet_scene: PackedScene

func _ready():
	thruster_anim = $AnimatedSprite2D
	ScoreManager.score = 0
	get_tree().paused = false

	engine_sound.play()
	music_player.play()
	
	engine_sound.set("pause_mode", "process")
	music_player.set("pause_mode", "stop")
	explosion_player.set("pause_mode", "process")
	
	engine_sound.process_mode = Node.PROCESS_MODE_INHERIT
	music_player.process_mode = Node.PROCESS_MODE_INHERIT
	explosion_player.process_mode = Node.PROCESS_MODE_INHERIT

	explosion_sprite.visible = false


func _physics_process(_delta):
	if not alive:
		return
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


func _process(_delta):    
	if alive:
		if not engine_sound.playing:
			engine_sound.play()
		if not music_player.playing:
			music_player.play()


func hit() -> void:
	if alive:
		alive = false
		engine_sound.stop()
		music_player.stop()
		explosion_player.play()        
		thruster_anim.visible = false        
		explosion_sprite.visible = true
		await get_tree().create_timer(1.5).timeout        
		set_process(false)
		set_physics_process(false)
		get_tree().change_scene_to_file("res://scenes/GameOverScene.tscn")


func shoot_bullet():
	shoot_burst()


func shoot_burst():
	for i in 1:
		var bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position

		var direction = (get_global_mouse_position() - global_position).normalized()
		bullet.set_direction(direction)

		shoot_sound.play()
		await get_tree().create_timer(0.2).timeout
