extends CharacterBody2D

@export var speed = 400
var thruster_anim: AnimatedSprite2D
var alive: bool = true


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

func hit() -> void:
	if alive:
		alive = false
		ScoreManager.running = false
		get_tree().paused = true
		print("Hráč byl zasažen!")
		print("Tvé skóre: ", ScoreManager.score)
