extends Area2D

@export var speed := 400
var direction := Vector2.ZERO

func _ready():
	area_entered.connect(_on_area_entered)

func _process(delta):
	position += direction * speed * delta
	rotation = direction.angle()

func set_direction(dir: Vector2):
	direction = dir.normalized()

func _on_area_entered(area):
	if area.is_in_group("asteroid"):
		area.queue_free() 
		queue_free()       
