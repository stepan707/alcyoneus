extends Area2D

@onready var animated_sprite = $FlyingObelisk
@export var lifetime: float = 30.0

func _ready():
	if animated_sprite:
		animated_sprite.play("default")
	
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		
	animated_sprite.visible = true
	start_despawn_timer()

func start_despawn_timer():
	await get_tree().create_timer(lifetime).timeout
	
	if is_instance_valid(self):
		queue_free()

func _on_body_entered(body: Node2D):
	if "level" in body:
		if body.level < 10:
			body.level += 1
			queue_free()
		else:
			if body.level == 777 or body.level == 707 or body.level == 717 or body.level == 727:
				pass
			else:
				body.activate_ultimate_mode()
	
	queue_free()
