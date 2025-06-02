extends Node

var score: int = 0
var running: bool = true

func _process(delta: float) -> void:
	if running:
		score += int(delta * 100)
