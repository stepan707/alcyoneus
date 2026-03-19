extends Node

var supabase_url = "https://kszubcxejomdsmoahnxc.supabase.co/rest/v1/hangar_items"
var apikey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtzenViY3hlam9tZHNtb2FobnhjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg3MjIzMTQsImV4cCI6MjA3NDI5ODMxNH0.CJ5pod2xEpMurg9EY6qhP-O-gFl7rK1UJJX337-w99M" 


var equipped_ship_id: String = "spike"
var unlocked_ships: Array = ["spike"]

func get_headers() -> PackedStringArray:
	return [
		"apikey: " + apikey,
		"Authorization: Bearer " + Global.access_token,
		"Content-Type: application/json",
		"Prefer: return=representation"
	]


func is_ship_unlocked(ship_id: String) -> bool:
	return unlocked_ships.has(ship_id)


func load_ships_from_db() -> void:
	if Global.user_id == "":
		print("Chyba: Global.user_id je prázdné, čekám na načtení hráče...")
		return

	var http = HTTPRequest.new()
	add_child(http)
	
	var url = supabase_url + "?user_id=eq." + Global.user_id
	http.request(url, get_headers(), HTTPClient.METHOD_GET)
	
	var response = await http.request_completed
	var response_code = response[1]
	var body = response[3]
	http.queue_free()
	
	if response_code >= 200 and response_code < 300:
		var data = JSON.parse_string(body.get_string_from_utf8())
		unlocked_ships.clear()
		unlocked_ships.append("spike")
		equipped_ship_id = "spike"
		
		if data != null:
			for row in data:
				var code = row["item_code"]
				
				if not unlocked_ships.has(code):
					unlocked_ships.append(code)
					
				if row.has("is_equiped") and row["is_equiped"] == true:
					equipped_ship_id = code
					
		print("Lodě načteny z DB. Odemčeno: ", unlocked_ships, " | Vybaveno: ", equipped_ship_id)
	else:
		print("Chyba při načítání lodí z DB: ", response_code)
		print("Detail chyby Supabase (GET): ", body.get_string_from_utf8())


func unlock_ship(ship_id: String) -> void:
	if not unlocked_ships.has(ship_id):
		unlocked_ships.append(ship_id)
		print("Loď odemčena lokálně: ", ship_id)
		
		if ship_id == "spike": 
			return
			
		var http = HTTPRequest.new()
		add_child(http)
		
		var body_data = {
			"user_id": Global.user_id,
			"item_code": ship_id,
			"is_equiped": false
		}
		
		http.request(supabase_url, get_headers(), HTTPClient.METHOD_POST, JSON.stringify(body_data))
		
		var response = await http.request_completed
		var code = response[1]
		var body = response[3]
		http.queue_free()
		
		if code >= 200 and code < 300:
			print("Loď ", ship_id, " úspěšně zapsána jako nový řádek do DB!")
		else:
			print("Chyba zápisu do DB: ", code)
			print("Detail chyby Supabase (POST): ", body.get_string_from_utf8())


func equip_ship(ship_id: String) -> void:
	equipped_ship_id = ship_id
	print("Nová loď vybavena: ", equipped_ship_id)
	

	var http_unequip = HTTPRequest.new()
	add_child(http_unequip)
	
	var url_unequip = supabase_url + "?user_id=eq." + Global.user_id
	var body_unequip = JSON.stringify({"is_equiped": false})
	http_unequip.request(url_unequip, get_headers(), HTTPClient.METHOD_PATCH, body_unequip)
	
	var response_unequip = await http_unequip.request_completed
	if response_unequip[1] >= 400:
		print("Chyba při resetování lodí: ", response_unequip[1])
		print("Detail chyby Supabase (PATCH 1): ", response_unequip[3].get_string_from_utf8())
	http_unequip.queue_free()
	
	if ship_id == "spike":
		return
		
	var http_equip = HTTPRequest.new()
	add_child(http_equip)
	
	var url_equip = supabase_url + "?user_id=eq." + Global.user_id + "&item_code=eq." + ship_id
	var body_equip = JSON.stringify({"is_equiped": true})
	http_equip.request(url_equip, get_headers(), HTTPClient.METHOD_PATCH, body_equip)
	
	var response = await http_equip.request_completed
	var code = response[1]
	var body = response[3]
	http_equip.queue_free()
	
	if code >= 200 and code < 300:
		print("Loď ", ship_id, " v DB označena jako EQUIPPED.")
	else:
		print("Chyba při updatu equip state v DB: ", code)
		print("Detail chyby Supabase (PATCH 2): ", body.get_string_from_utf8())
