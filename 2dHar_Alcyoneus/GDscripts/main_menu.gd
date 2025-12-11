extends Control

@onready var music_player = get_node("MusicPlayer")
@onready var hoverSound = get_node("hover")

func _ready() -> void:
	music_player.play()
	

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Credit_Scene.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_setings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Settings.tscn")


func _on_garage_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Garage.tscn")
	
 

func _on_mouse_entered() -> void:
	hoverSound.play()



func _on_move_pressed() -> void:
	$login.visible=true
	$singup.visible=false


func _on_move_2_pressed() -> void:
	$login.visible=false
	$singup.visible=true





const SUPABASE_URL: String = "https://kszubcxejomdsmoahnxc.supabase.co" 
const SUPABASE_ANON_KEY: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtzenViY3hlam9tZHNtb2FobnhjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg3MjIzMTQsImV4cCI6MjA3NDI5ODMxNH0.CJ5pod2xEpMurg9EY6qhP-O-gFl7rK1UJJX337-w99M" 

@onready var http_request_node: HTTPRequest = $HTTPRequest

@onready var login_name_input = $login/VBoxContainer/name_input
@onready var login_password_input = $login/VBoxContainer/password_input

@onready var singup_name_input = $singup/VBoxContainer2/name_input
@onready var singup_password_input = $singup/VBoxContainer2/password_input
@onready var singup_password_input2 = $singup/VBoxContainer2/password_input2

var action = ""

var access_token = ""
var user_id = ""

func _on_singup_pressed() -> void:
	if singup_name_input == "" or singup_password_input == "" or singup_password_input2 == "":
		$singup/VBoxContainer2/Label3.text="Vyplňte všechna pole!"
		return
	else:
		action = "singup"
		var name = singup_name_input.text
		var password = singup_password_input.text
		var password2 = singup_password_input2.text
		
		if password == password2:
			var full_url = SUPABASE_URL + "/auth/v1/singup"
			
			var header =  [
					"Content-Type: application/json",
					"apikey: " + SUPABASE_ANON_KEY		
			]
			
			var data = {
				"name": name,
				"password": password
			}
			var json_data = JSON.stringify(data)
			http_request_node.request(full_url, header, HTTPClient.METHOD_POST, json_data)
		else:
			$singup/VBoxContainer2/Label3.text = "Hesla nejsou stejná! Zkuste to znovu"


func _on_login_pressed() -> void:
	if singup_name_input == null or singup_password_input == null:
		$login/VBoxContainer/Label3.text="Vyplňte všechna pole!"
		return
	else:
		action = "login"
		var name = login_name_input.text
		var password = login_password_input.text
		
		var full_url = SUPABASE_URL + "/auth/v1/token?grant_type=password"
		
		var header =  [
				"Content-Type: application/json",
				"apikey: " + SUPABASE_ANON_KEY		
		]
		
		var data = {
			"name": name,
			"password": password
		}
		
		var json_data = JSON.stringify(data)
		http_request_node.request(full_url, header, HTTPClient.METHOD_POST, json_data)


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	
	if parse_result != OK:
		if action == "login":
			$login/VBoxContainer/Label3.text = "Chyba při čtení odpovědi od servru"
		elif action == "singup":
			$singup/VBoxContainer2/Label3.text = "Chyba při čtení odpovědi od servru"
		return
	
	var response = json.get_data()
	if response_code >= 200 and response_code < 300:
		if action == "login":
			$login/VBoxContainer/Label3.text = "Přihlášení úspěšné!"
		elif action == "singup":
			$singup/VBoxContainer2/Label3.text = "Registrace úspěšná!"
			access_token = response["access_token"]
			user_id = response["user"]["id"]
	else:
		if action == "login":
			$login/VBoxContainer/Label3.text = "Chyba: " + str(response_code)
		elif action == "singup":
			$singup/VBoxContainer2/Label3.text = "Chyba: " + str(response_code)
