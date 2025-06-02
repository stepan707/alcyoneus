extends CharacterBody2D

@onready var engine_sound = $EnginePlayer
@onready var thruster_anim = $AnimatedSprite2D
@onready var music_player = get_node("/root/Node2D/MusicPlayer")
@onready var explosion_player = get_node("/root/Node2D/ExplosionPlayer")

@export var speed = 400
var alive = true

func _ready():
	ScoreManager.score = 0
	ScoreManager.running = true
	get_tree().paused = false

	engine_sound.play()
	music_player.play()

	# Správně nastavený režim pauzy pro Godot 4
	engine_sound.set("pause_mode", "process")
	music_player.set("pause_mode", "stop")
	explosion_player.set("pause_mode", "process")

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

func _process(_delta):
	# Ruční looping audia (protože není možné použít .loop)
	if alive:
		if not engine_sound.playing:
			engine_sound.play()
		if not music_player.playing:
			music_player.play()

func hit():
	if alive:
		alive = false
		engine_sound.stop()
		music_player.stop()

		# Přehrajeme explozi před pauznutím hry
		explosion_player.play()

		# Pauzneme hru až PO spuštění exploze
		await get_tree().create_timer(0.1).timeout  # malá prodleva, aby měl čas přehrát se
		ScoreManager.running = false
		get_tree().paused = true

		print("Hráč byl zasažen!")
		print("Tvé skóre: ", ScoreManager.score)
