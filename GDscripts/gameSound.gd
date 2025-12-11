extends Node2D

func _ready():
	$MusicPlayer.play()

func _process(_delta):
	if not $MusicPlayer.playing:
		$MusicPlayer.play()
