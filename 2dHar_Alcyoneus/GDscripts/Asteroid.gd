extends Area2D

@export var speed: float = 200.0

var direction: Vector2 = Vector2.DOWN
var rotation_speed: float = 0.0


func _ready() -> void:    
	rotation_speed = randf_range(-1.0, 1.0)
	var random_angle_deg = randf_range(-45.0, 45.0) 
	direction = Vector2.DOWN.rotated(deg_to_rad(random_angle_deg))
	connect("body_entered", self._on_body_entered)
	connect("area_entered", self._on_area_entered)

func _process(delta: float) -> void:
	position += direction.normalized() * speed * delta
	rotation += rotation_speed * delta
	if position.y > 2000: 
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.hit()
		queue_free()

func _on_area_entered(area: Node) -> void:
	if area.is_in_group("bullet"):
		area.queue_free()
		queue_free()
