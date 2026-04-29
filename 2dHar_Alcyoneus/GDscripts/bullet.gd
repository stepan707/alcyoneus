extends Area2D

@export var speed := 450
@export var lifespan := 2.5

var direction := Vector2.ZERO
var time_alive := 0.0

func _ready():
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
		
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _process(delta):
	time_alive += delta
	if time_alive > lifespan:
		queue_free()
		
	position += direction * speed * delta
	
	if direction.length_squared() > 0:
		rotation = direction.angle()

func set_direction(dir: Vector2):
	direction = dir.normalized()


func _on_area_entered(area):
	if area.is_in_group("asteroid"):
		if has_node("/root/ScoreManager"):
			ScoreManager.add_score(100)
		area.queue_free() 
		queue_free()
		return
		
	if area.has_method("hit"):
		area.hit()
		queue_free()
		return


func _on_body_entered(body):
	if body.has_method("hit"):
		body.hit()
		queue_free()
