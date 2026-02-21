extends Control

const SUPABASE_URL: String = "https://kszubcxejomdsmoahnxc.supabase.co" 
const SUPABASE_ANON_KEY: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtzenViY3hlam9tZHNtb2FobnhjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg3MjIzMTQsImV4cCI6MjA3NDI5ODMxNH0.CJ5pod2xEpMurg9EY6qhP-O-gFl7rK1UJJX337-w99M" 

const SETTINGS_PATH = "user://settings.cfg"

@onready var volume_slider = $CenterContainer/PanelContainer/VBoxContainer/HSlider
@onready var account_section = $CenterContainer/PanelContainer/VBoxContainer/AccountSection
@onready var http_request = $HTTPRequest

@onready var password_modal = $PasswordModal
@onready var new_password_input = $PasswordModal/VBoxContainer/NewPasswordInput
@onready var password_status_label = $PasswordModal/VBoxContainer/StatusLabel

@onready var hoverSound = get_node("hover")

var master_bus_index = AudioServer.get_bus_index("Master")
var config = ConfigFile.new()

func _ready():
	if not volume_slider.value_changed.is_connected(_on_h_slider_value_changed):
		volume_slider.value_changed.connect(_on_h_slider_value_changed)
	
	if not http_request.request_completed.is_connected(_on_http_request_completed):
		http_request.request_completed.connect(_on_http_request_completed)
	
	load_settings()
	
	if Global.access_token != "":
		account_section.visible = true
	else:
		account_section.visible = false
		
	password_modal.visible = false

func load_settings():
	var err = config.load(SETTINGS_PATH)
	
	if err == OK:
		var volume = config.get_value("audio", "volume", 1.0)
		volume_slider.value = volume
	else:
		volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus_index))

func save_settings():
	config.set_value("audio", "volume", volume_slider.value)
	config.save(SETTINGS_PATH)

func _on_mouse_entered() -> void:
	if hoverSound: hoverSound.play()

func _on_h_slider_value_changed(value):
	AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(value))
	save_settings()

func _on_back_btn_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_logout_btn_pressed():
	Global.access_token = ""
	Global.user_id = ""
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_change_password_btn_pressed():
	password_modal.visible = true
	new_password_input.text = ""
	password_status_label.text = ""

func _on_cancel_password_btn_pressed():
	password_modal.visible = false

func _on_confirm_password_btn_pressed():
	var new_pass = new_password_input.text
	
	if new_pass.length() < 6:
		password_status_label.text = "Heslo musí mít min. 6 znaků."
		password_status_label.add_theme_color_override("font_color", Color.RED)
		return
		
	password_status_label.text = "Odesílám..."
	password_status_label.add_theme_color_override("font_color", Color.WHITE)
	
	var url = SUPABASE_URL + "/auth/v1/user"
	var headers = [
		"Content-Type: application/json",
		"apikey: " + SUPABASE_ANON_KEY,
		"Authorization: Bearer " + Global.access_token
	]
	var data = JSON.stringify({ "password": new_pass })
	
	http_request.request(url, headers, HTTPClient.METHOD_PUT, data)

func _on_http_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	
	if response_code == 200:
		password_status_label.text = "Heslo úspěšně změněno!"
		password_status_label.add_theme_color_override("font_color", Color.GREEN)
		await get_tree().create_timer(1.5).timeout
		password_modal.visible = false
	else:
		password_status_label.text = "Chyba: " + str(response_code)
		password_status_label.add_theme_color_override("font_color", Color.RED)
