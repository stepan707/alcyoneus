extends Node

const CHEATS = {
	"GODMODE": "_activate_god_mode",
	"KILLMENOT": "_is_invincible",
	"MAXLEVEL": "_giv_max_level",
	"BLUE": "_spawn_blue",
	"LILRED": "_spawn_litlleRed",
	"NOASTEROID": "_no_asteroid",
	"NORMAL": "_normal",
	"MOREOBELISK": "_more_obelisk",
	"NOPERED": "_nope_red",
	"NOPEBLUE": "_nope_blue",
	"MINIGUN": "_minigun_mode",
	"ONEWAYCANON": "_one_way_canon_mode",
	"LASER": "_laser_mode"
}

var current_input := ""
const MAX_BUFFER := 15
var timeout_timer := 0.0
const RESET_TIME := 2.0

func _unhandled_input(event: InputEvent):
	if event is InputEventKey and event.pressed and not event.echo:
		var key_char = OS.get_keycode_string(event.keycode).to_upper()
		
		if key_char.length() == 1:
			current_input += key_char
			timeout_timer = RESET_TIME
			
			if current_input.length() > MAX_BUFFER:
				current_input = current_input.right(MAX_BUFFER)
			
			_check_for_cheats()

func _process(delta):
	if timeout_timer > 0:
		timeout_timer -= delta
		if timeout_timer <= 0:
			current_input = ""

func _check_for_cheats():
	for code in CHEATS:
		if current_input.ends_with(code):
			var method_name = CHEATS[code]
			if has_method(method_name):
				call(method_name)

func _activate_god_mode():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		ScoreManager.score=-2000000000
		player.level = 777

func _giv_max_level():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		ScoreManager.score=-200000000
		player.level = 10

func _minigun_mode():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		ScoreManager.score=-200000000
		player.level = 707

func _one_way_canon_mode():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		ScoreManager.score=-200000000
		player.level = 717

func _laser_mode():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		ScoreManager.score=-200000000
		player.level = 727


func _spawn_blue():
	var blue = get_tree().get_first_node_in_group("blue")
	if blue:
		ScoreManager.score-=10000
		blue.max_enemies_total += 2


func _spawn_litlleRed():
	var red = get_tree().get_first_node_in_group("litlleRed")
	if red:
		ScoreManager.score-=10000
		red.max_enemies_total += 4
		


func _is_invincible():
	var player = get_tree().get_first_node_in_group("player")	
	if player:
		ScoreManager.score=-2000000000
		player.is_invincible = true


func _no_asteroid():
	var timers = get_tree().get_nodes_in_group("AsteroidTimers")
	for timer in timers:
		timer.wait_time = 5


func _more_obelisk():
	var obelisk = get_tree().get_first_node_in_group("obelisk")
	if obelisk:
		obelisk.min_spawn_time = 0.5
		obelisk.max_spawn_time = obelisk.min_spawn_time


func _nope_red():
	var red = get_tree().get_nodes_in_group("litlleRed")
	for x in red:
		x.max_enemies_total = 0


func _nope_blue():
	var blue = get_tree().get_nodes_in_group("blue")
	for x in blue:
		x.max_enemies_total = 0;



func _normal():
	var player = get_tree().get_first_node_in_group("player")	
	if player:
		player.level = 1
		player.is_invincible=false
	
	ScoreManager.score = 0;
	
	var timers = get_tree().get_nodes_in_group("AsteroidTimers")
	for timer in timers:
		timer.wait_time = 0.5
	
	var obelisk = get_tree().get_first_node_in_group("obelisk")
	if obelisk:
		obelisk.max_spawn_time = 17
		obelisk.min_spawn_time = 3
