extends Node2D


func _ready():
	# Spustí hudbu hned po startu
	$MusicPlayer.play()

func _process(_delta):
	# Pokud hudba dohrála, spustí ji znovu
	if not $MusicPlayer.playing:
		$MusicPlayer.play()
