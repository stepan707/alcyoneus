extends Area2D

@export var speed := 450
var direction := Vector2.ZERO
@export var lifespan := 5.0
var time_alive := 0.0



func _ready():
	area_entered.connect(_on_area_entered)

func _process(delta):
	time_alive += delta
	if time_alive > lifespan:
		queue_free()
	position += direction * speed * delta
	rotation = direction.angle()
	if direction.length_squared() > 0:
		rotation = direction.angle()

func set_direction(dir: Vector2):
	direction = dir.normalized()


func _on_area_entered(area):
	if area.is_in_group("asteroid"):
		area.queue_free() 
		queue_free()       
