extends Control

@onready var hoverSound = $hover
@onready var ship_name_label = $Back/ShipName
@onready var ship_info_label = $Back/ShipInfo
@onready var ship_image = $Back/Panel/ShipImage
@onready var money_label = $Back/Money
@onready var action_button = $Back/buy_equip 

var ships = [
	{
		"id": "spike",
		"name": "Spike",
		"info": "Classic",
		"image": preload("res://modely/ships/Spike_SpriteSheet.png"),
		"cost": 0,
		"scale": Vector2(0.6, 0.6)
	},
	{
		"id": "gold_snitch",
		"name": "Gold Snitch",
		"info": "it's gold... hell yeeaa, i need it",
		"image": preload("res://modely/ships/goldSnitch_SpriteSheet.png"),
		"cost": 10000,
		"scale": Vector2(0.7, 0.7)
	},
	{
		"id": "bronz_spike",
		"name": "Bronz spike",
		"info": "Older version of Spike, used for mining",
		"image": preload("res://modely/ships/bronzSpike_spriteSheet.png"),
		"cost": 10000,
		"scale": Vector2(1.6, 1.6)
	},
	{
		"id": "golden_emerald",
		"name": "Golden emerald",
		"info": "if you assked your self 'why emerald?'\ncongratulation, you are colorblinde",
		"image": preload("res://modely/ships/emerald_spriteSheet.png"),
		"cost": 1000000,
		"scale": Vector2(0.7, 0.7)
	},
	{
		"id": "ruby",
		"name": "Corupted ruby",
		"info": "old ship that corupted by a unknow power from a special ruby knoe as HearthOfHell",
		"image": preload("res://modely/ships/demonicRuby_spriteSheet.png"),
		"cost": 1000000,
		"scale": Vector2(0.7, 0.7)
	},
	{
		"id": "archangel",
		"name": "Archangel",
		"info": "Archangel has descened upon this ship to fight unknow demonic coruption coming from hell",
		"image": preload("res://modely/ships/archengel_spriteSheet.png"),
		"cost": 2000000000,
		"scale": Vector2(0.7, 0.7)
	},
	{
		"id": "lucifer",
		"name": "Lucifer",
		"info": "He who holds the power of a angel and a demon, he alone is the closet to being a GOD...\nHELL IS HIS...£¥€¥©‖⟬⟭⟧⁜※⁂⁕⁜The walls are crumbling...⁜and⁜ soon theyr strenght⁜ will not be abel to hold me...and onec that day come, I will take my revenge...⁜",
		"image": preload("res://modely/ships/lucifer_spriteSheet.png"),
		"cost": 2000000000,
		"scale": Vector2(0.7, 0.7)
	}
]

var unknown_ship_data = {
	"name": "Unknown",
	"image": preload("res://modely/ships/shadow_spriteSheet.png"),
	"scale": Vector2(1, 1)
}

var current_index: int = 0

func _ready() -> void:
	
	ship_image.custom_minimum_size = Vector2(600, 600) 
	ship_image.size = Vector2(600, 600)
	
	ship_image.anchors_preset = Control.PRESET_CENTER
	
	ship_image.pivot_offset = ship_image.size / 2.0
	ship_image.rotation_degrees = 90
	
	update_money_label()
	update_ui()


func update_money_label() -> void:
	money_label.text = "CR: " + str(CurrencyManager.current_money)


func update_ui() -> void:
	var current_ship = ships[current_index]
	var is_owned = ShipManager.is_ship_unlocked(current_ship["id"])
	var is_equipped = (ShipManager.equipped_ship_id == current_ship["id"])

	if is_owned:
		ship_name_label.text = "Ship Name: \n" + current_ship["name"]
	else:
		ship_name_label.text = "Ship Name: \n" + unknown_ship_data["name"]
		
	ship_info_label.text = "Ship Info: \n" + current_ship["info"]
	
	if ship_image != null:
		var atlas = AtlasTexture.new()
		
		var display_image = current_ship["image"] if is_owned else unknown_ship_data["image"]
		var display_scale = current_ship["scale"] if is_owned else unknown_ship_data["scale"]
		
		atlas.atlas = display_image
		
		var frame_width = display_image.get_width() / 3.0
		var frame_height = display_image.get_height() / 2.0
		
		atlas.region = Rect2(0, 0, frame_width, frame_height)
		ship_image.texture = atlas
		ship_image.scale = display_scale

	if is_equipped:
		action_button.text = "Equipped"
		action_button.disabled = true 
	elif is_owned:
		action_button.text = "Equip"
		action_button.disabled = false 
	else:
		action_button.text = "Buy: " + str(current_ship["cost"]) + " CR"
		
		if CurrencyManager.current_money >= current_ship["cost"]:
			action_button.disabled = false 
		else:
			action_button.disabled = true 


func _on_action_button_pressed():
	var current_ship = ships[current_index]
	var is_owned = ShipManager.is_ship_unlocked(current_ship["id"])
	
	if is_owned:
		ShipManager.equip_ship(current_ship["id"])
		update_ui() 
	else:
		if CurrencyManager.spend_money(current_ship["cost"]):
			print("Loď zakoupena!")
			await ShipManager.unlock_ship(current_ship["id"])
			ShipManager.equip_ship(current_ship["id"])
			update_money_label()
			update_ui()


func _on_next_pressed() -> void:
	current_index += 1
	if current_index >= ships.size():
		current_index = 0
	update_ui()

func _on_previouse_pressed() -> void:
	current_index -= 1
	if current_index < 0:
		current_index = ships.size() - 1
	update_ui()

func _on_mouse_entered() -> void:
	hoverSound.play()

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
