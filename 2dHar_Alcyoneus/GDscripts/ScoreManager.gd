extends Node

const SUPABASE_URL: String = "https://kszubcxejomdsmoahnxc.supabase.co" 
const SUPABASE_ANON_KEY: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtzenViY3hlam9tZHNtb2FobnhjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg3MjIzMTQsImV4cCI6MjA3NDI5ODMxNH0.CJ5pod2xEpMurg9EY6qhP-O-gFl7rK1UJJX337-w99M" 

var score: int = 0
var best_score: int = 0 

func add_score(value: int):
	score += value

func reset_score():
	score = 0

func on_login_success():
	load_best_score_from_supabase()


func save_score_to_supabase(final_score: int):
	if final_score > best_score:
		best_score = final_score

	if Global.access_token == "":
		return

	if final_score <= 0:
		return

	print("Zahajuji proces ukládání skóre: " + str(final_score))

	var http_check = HTTPRequest.new()
	add_child(http_check)
	http_check.request_completed.connect(_on_check_for_save_completed.bind(http_check, final_score))
	
	var query = "/rest/v1/high_scores?user_id=eq." + Global.user_id + "&select=id,score&order=score.desc&limit=1"
	var url = SUPABASE_URL + query
	var headers = ["apikey: " + SUPABASE_ANON_KEY, "Authorization: Bearer " + Global.access_token]
	
	http_check.request(url, headers, HTTPClient.METHOD_GET)

func _on_check_for_save_completed(result, response_code, headers, body, http_node, final_score):
	http_node.queue_free()

	if response_code != 200:
		print("Chyba při kontrole skóre v DB. Kód: " + str(response_code))
		return

	var json = JSON.parse_string(body.get_string_from_utf8())
	var existing_id = null
	var existing_score = -1

	if json and json.size() > 0:
		existing_id = int(json[0]["id"]) 
		existing_score = int(json[0]["score"])
		
		if existing_score > best_score:
			best_score = existing_score
	
	if existing_id != null:
		if final_score > existing_score:
			print("Nový rekord! Aktualizuji ID: " + str(existing_id))
			_patch_existing_score(existing_id, final_score)
		else:
			print("Skóre není vyšší než v DB. Neukládám.")
	else:
		print("První hra. Vytvářím záznam.")
		_post_new_score(final_score)

func _patch_existing_score(record_id, score_val):
	var http_save = HTTPRequest.new()
	add_child(http_save)
	http_save.request_completed.connect(_on_save_completed.bind(http_save, "Aktualizováno"))
	
	var url = SUPABASE_URL + "/rest/v1/high_scores?id=eq." + str(int(record_id))
	
	var headers = [
		"Content-Type: application/json",
		"apikey: " + SUPABASE_ANON_KEY,
		"Authorization: Bearer " + Global.access_token
	]
	var data = JSON.stringify({ "score": score_val })
	
	http_save.request(url, headers, HTTPClient.METHOD_PATCH, data)

func _post_new_score(score_val):
	var http_save = HTTPRequest.new()
	add_child(http_save)
	http_save.request_completed.connect(_on_save_completed.bind(http_save, "Vytvořeno"))
	
	var url = SUPABASE_URL + "/rest/v1/high_scores"
	var headers = [
		"Content-Type: application/json",
		"apikey: " + SUPABASE_ANON_KEY,
		"Authorization: Bearer " + Global.access_token
	]
	var data = JSON.stringify({
		"user_id": Global.user_id,
		"score": score_val
	})
	
	http_save.request(url, headers, HTTPClient.METHOD_POST, data)

func _on_save_completed(result, response_code, headers, body, http_node, action_type):
	http_node.queue_free()
	
	if response_code == 200 or response_code == 201 or response_code == 204:
		print("Skóre úspěšně uloženo (" + action_type + ")")
	else:
		print("Chyba při ukládání (" + action_type + "). Kód: " + str(response_code))
		print("Odpověď: " + body.get_string_from_utf8())


func load_best_score_from_supabase() -> int:
	if Global.access_token == "":
		return best_score

	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_load_completed.bind(http))
	
	var query = "/rest/v1/high_scores?user_id=eq." + Global.user_id + "&select=score&order=score.desc&limit=1"
	var url = SUPABASE_URL + query
	var headers = ["apikey: " + SUPABASE_ANON_KEY, "Authorization: Bearer " + Global.access_token]
	
	http.request(url, headers, HTTPClient.METHOD_GET)
	return best_score

func _on_load_completed(result, response_code, headers, body, http_node):
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json and json.size() > 0:
			var loaded_score = int(json[0]["score"])
			if loaded_score > best_score:
				best_score = loaded_score
			print("Skóre načteno: " + str(best_score))
	
	http_node.queue_free()

#func save_best_score_local(score_to_save: int):
	#if score_to_save > best_score:
		#best_score = score_to_save
	#var file = FileAccess.open("user://best_score.save", FileAccess.WRITE)
	#if file:
		#file.store_var(score_to_save)
#
#func load_best_score_local() -> int:
	#if FileAccess.file_exists("user://best_score.save"):
		#var file = FileAccess.open("user://best_score.save", FileAccess.READ)
		#var loaded = file.get_var()
		#if loaded > best_score:
			#best_score = loaded
		#return loaded
	#return 0
