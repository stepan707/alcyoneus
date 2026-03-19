extends Node

var current_money: int = 0

var supabase_url = "https://kszubcxejomdsmoahnxc.supabase.co/rest/v1/profiles"
var apikey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtzenViY3hlam9tZHNtb2FobnhjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg3MjIzMTQsImV4cCI6MjA3NDI5ODMxNH0.CJ5pod2xEpMurg9EY6qhP-O-gFl7rK1UJJX337-w99M" 

signal money_updated(new_amount)

func get_headers() -> PackedStringArray:
	var auth_token = apikey
	
	if "access_token" in Global and Global.access_token != null and Global.access_token != "":
		auth_token = Global.access_token
	elif "token" in Global and Global.token != null and Global.token != "":
		auth_token = Global.token

	return [
		"apikey: " + apikey,
		"Authorization: Bearer " + auth_token,
		"Content-Type: application/json",
		"Prefer: return=representation"
	]

func add_money_from_score(final_score: int) -> void:
	var earned_money = final_score / 100 
	
	if earned_money > 0:
		current_money += earned_money
		print("Hráč vydělal: ", earned_money, " kreditů. Celkem má: ", current_money)
		
		money_updated.emit(current_money)
		save_money_to_supabase(current_money)

func spend_money(amount: int) -> bool:
	if current_money >= amount:
		current_money -= amount
		money_updated.emit(current_money)
		save_money_to_supabase(current_money)
		return true 
	else:
		print("Nedostatek financí!")
		return false 

# --- DATABÁZOVÉ FUNKCE ---

func load_money_from_supabase() -> void:
	print("Stahuji stav peněz ze Supabase...")
	var current_user_id = Global.user_id
	
	if current_user_id == null or current_user_id == "":
		print("CHYBA: Nemohu načíst peníze, Global.user_id je prázdné!")
		return
		
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_load_completed.bind(http))
	
	var url = supabase_url + "?id=eq." + str(current_user_id) + "&select=money" 
	
	var error = http.request(url, get_headers(), HTTPClient.METHOD_GET)
	if error != OK:
		print("Při vytváření HTTP requestu pro načtení peněz nastala chyba.")


func _on_load_completed(result, response_code, headers, body, http_node) -> void:
	http_node.queue_free()
	var body_string = body.get_string_from_utf8()
	
	if response_code >= 200 and response_code < 300:
		var data = JSON.parse_string(body_string)
		if typeof(data) == TYPE_ARRAY and data.size() > 0:
			if data[0].has("money"):
				current_money = int(data[0]["money"])
				money_updated.emit(current_money)
				print("Peníze úspěšně načteny z DB: ", current_money)
			else:
				print("Chyba: Odpověď DB neobsahuje sloupec 'money'. Struktura dat: ", data[0])
		else:
			print("Záznam pro uživatele nenalezen (možná nový uživatel).")
	else:
		print("--- CHYBA PŘI STAHOVÁNÍ PENĚZ ---")
		print("Kód: ", response_code)
		print("Odpověď od serveru: ", body_string)
		print("---------------------------------")


func save_money_to_supabase(new_amount: int) -> void:
	print("Ukládám nový stav peněz do Supabase: ", new_amount)
	var current_user_id = Global.user_id
	
	if current_user_id == null or current_user_id == "":
		print("CHYBA: Nemohu uložit peníze, Global.user_id je prázdné!")
		return
		
	var http = HTTPRequest.new()
	add_child(http)
	
	http.request_completed.connect(func(res, code, h, b):
		http.queue_free()
		if code >= 200 and code < 300:
			var response_body = b.get_string_from_utf8()
			if response_body == "[]":
				print("⚠️ POZOR: Úspěšný dotaz, ale uložilo se 0 řádků! (Blokuje tě RLS, chybí access_token v hlavičce!)")
			else:
				print("✅ Peníze úspěšně uloženy v DB! ", response_body)
		else:
			print("--- CHYBA PŘI UKLÁDÁNÍ PENĚZ ---")
			print("Kód: ", code)
			print("Odpověď od serveru: ", b.get_string_from_utf8())
			print("---------------------------------")
	)
	
	var url = supabase_url + "?id=eq." + str(current_user_id)
	
	var body_data = {
		"money": int(new_amount)
	}
	
	var error = http.request(url, get_headers(), HTTPClient.METHOD_PATCH, JSON.stringify(body_data))
	if error != OK:
		print("Při vytváření HTTP requestu pro uložení peněz nastala chyba.")
