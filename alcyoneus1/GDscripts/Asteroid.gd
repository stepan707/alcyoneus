extends Area2D

@export var speed: float = 200.0
@export var direction: Vector2 = Vector2.DOWN

func _ready() -> void:
	connect("body_entered", self._on_body_entered)

func _process(delta: float) -> void:
	position += direction.normalized() * speed * delta
	if position.y > 2000:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		print("Byl jsi zasažen!")
		body.hit()
		queue_free()
