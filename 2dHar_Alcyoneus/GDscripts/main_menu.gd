extends Control

@onready var music_player = get_node("MusicPlayer")
@onready var hoverSound = get_node("hover")

const SUPABASE_URL: String = "https://kszubcxejomdsmoahnxc.supabase.co" 
const SUPABASE_ANON_KEY: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtzenViY3hlam9tZHNtb2FobnhjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg3MjIzMTQsImV4cCI6MjA3NDI5ODMxNH0.CJ5pod2xEpMurg9EY6qhP-O-gFl7rK1UJJX337-w99M" 

@onready var http_request_node: HTTPRequest = $HTTPRequest

@onready var login_panel = $login
@onready var login_name_input = $login/VBoxContainer/name_input
@onready var login_password_input = $login/VBoxContainer/password_input

@onready var signup_panel = $singup
@onready var singup_name_input = $singup/VBoxContainer2/name_input
@onready var singup_password_input = $singup/VBoxContainer2/password_input
@onready var singup_password_input2 = $singup/VBoxContainer2/password_input2

var action = ""

func _ready() -> void:
	music_player.play()	
	if not http_request_node.request_completed.is_connected(_on_http_request_request_completed):
		http_request_node.request_completed.connect(_on_http_request_request_completed)
	
	login_panel.visible = false
	signup_panel.visible = false

func _on_start_pressed() -> void:
	if Global.access_token != "":
		get_tree().change_scene_to_file("res://scenes/game.tscn")
	else:
		_on_move_pressed()
		set_msg("Musíte se nejprve přihlásit!", Color.YELLOW)

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Credit_Scene.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_setings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Settings.tscn")

func _on_garage_pressed() -> void:
	if Global.access_token != "":
		get_tree().change_scene_to_file("res://scenes/Garage.tscn")
	else:
		_on_move_pressed()
		set_msg("Hangár je jen pro přihlášené!", Color.YELLOW)

func _on_mouse_entered() -> void:
	hoverSound.play()

func _on_move_pressed() -> void:
	login_panel.visible = true
	signup_panel.visible = false
	$login/VBoxContainer/Label3.text = ""

func _on_move_2_pressed() -> void:
	login_panel.visible = false
	signup_panel.visible = true
	$singup/VBoxContainer2/Label3.text = ""

func _on_singup_pressed() -> void:
	var name = singup_name_input.text.strip_edges()
	var password = singup_password_input.text.strip_edges()
	var password_repeat = singup_password_input2.text.strip_edges()

	if name == "" or password == "" or password_repeat == "":
		action = "singup"
		set_msg("Vyplňte všechna pole!", Color.RED)
		return
	
	if password != password_repeat:
		action = "singup"
		set_msg("Hesla nejsou stejná!", Color.RED)
		return
		
	if password.length() < 6:
		action = "singup"
		set_msg("Heslo musí mít min. 6 znaků.", Color.RED)
		return

	action = "singup"
	set_msg("Registruji...", Color.WHITE)
	
	var fake_email = name.replace(" ", "").to_lower() + "@alcyoneus.com"
	var full_url = SUPABASE_URL + "/auth/v1/signup"
	var header = ["Content-Type: application/json", "apikey: " + SUPABASE_ANON_KEY]
	var data = {"email": fake_email, "password": password}
	
	http_request_node.request(full_url, header, HTTPClient.METHOD_POST, JSON.stringify(data))

func _on_login_pressed() -> void:
	var name = login_name_input.text.strip_edges()
	var password = login_password_input.text.strip_edges()

	if name == "" or password == "":
		action = "login"
		set_msg("Vyplňte jméno a heslo!", Color.RED)
		return
	
	action = "login"
	set_msg("Přihlašuji...", Color.WHITE)
	
	var fake_email = name.replace(" ", "").to_lower() + "@alcyoneus.com"
	var full_url = SUPABASE_URL + "/auth/v1/token?grant_type=password"
	var header = ["Content-Type: application/json", "apikey: " + SUPABASE_ANON_KEY]
	var data = {"email": fake_email, "password": password}
	
	http_request_node.request(full_url, header, HTTPClient.METHOD_POST, JSON.stringify(data))

func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	
	if parse_result != OK:
		set_msg("Chyba dat serveru", Color.RED)
		return
	
	var response = json.get_data()
	
	if response_code >= 200 and response_code < 300:
		if action == "login":
			set_msg("Přihlášení úspěšné!", Color.GREEN)
			if response.has("access_token"):
				Global.access_token = response["access_token"]
				Global.user_id = response["user"]["id"]
				ScoreManager.best_score = 0;
				ScoreManager.load_best_score_from_supabase()
				CurrencyManager.load_money_from_supabase()
				ShipManager.load_ships_from_db()
				
				await get_tree().create_timer(1.0).timeout
				login_panel.visible = false
				signup_panel.visible = false
				
		elif action == "singup":
			if response.has("access_token"):
				Global.access_token = response["access_token"]
				Global.user_id = response["user"]["id"]
				ScoreManager.load_best_score_from_supabase()
				CurrencyManager.load_money_from_supabase()
				ShipManager.load_ships_from_db()
				
				set_msg("Registrace úspěšná! Vítejte.", Color.GREEN)
				await get_tree().create_timer(1.5).timeout
				signup_panel.visible = false
			else:
				set_msg("Účet vytvořen! Automaticky přihlašuji...", Color.GREEN)
				login_name_input.text = singup_name_input.text
				login_password_input.text = singup_password_input.text
				await get_tree().create_timer(1.0).timeout
				_on_login_pressed()
	else:
		var error_msg = "Chyba: " + str(response_code)
		if response.has("error_description"): error_msg = response["error_description"]
		elif response.has("msg"): error_msg = response["msg"]
		
		if "Email not confirmed" in error_msg:
			error_msg = "Potvrďte email (vypněte Confirm v Supabase!)"
		if "Invalid login credentials" in error_msg:
			error_msg = "Špatné jméno nebo heslo"
		if "User already registered" in error_msg:
			error_msg = "Jméno je již obsazené"
			
		set_msg(error_msg, Color.RED)

func set_msg(text: String, color: Color):
	if action == "login":
		$login/VBoxContainer/Label3.text = text
		$login/VBoxContainer/Label3.add_theme_color_override("font_color", color)
	else:
		$singup/VBoxContainer2/Label3.text = text
		$singup/VBoxContainer2/Label3.add_theme_color_override("font_color", color)
