extends Spatial


var all_weapons = {}


var weapons = {}


var hud

var current_weapon 
var current_weapon_slot = "Empty" 

var changing_weapon = false
var unequipped_weapon = false

var weapon_index = 0 


func _ready():
	
	hud = owner.get_node("HUD")
	get_parent().get_node("Camera/RayCast").add_exception(owner) 
	
	all_weapons = {
		"Unarmed" : preload("res://scenes/Unarmed.tscn"),
		"Pistol" : preload("res://scenes/armed/Pistol.tscn"),
		"Rifle" : preload("res://scenes/armed/Rifle.tscn"),
		"Eagle" : preload("res://scenes/armed/Eagle.tscn"),
		"M4A1" : preload("res://scenes/armed/M4A1.tscn")
	}
	
	weapons = {
		"Empty" : $Unarmed,
		"Primary" : $Eagle,
		"Secondary" : $M4A1
	}
	
	
	for w in weapons:
		if weapons[w] != null:
			weapons[w].weapon_manager = self
			weapons[w].player = owner
			weapons[w].ray = get_parent().get_node("Camera/RayCast")
			weapons[w].visible = false
	
	
	current_weapon = weapons["Empty"]
	change_weapon("Empty")
	
	# Disable process
	set_process(false)


func _process(delta):
	
	if unequipped_weapon == false:
		if current_weapon.is_unequip_finished() == false:
			return
		
		unequipped_weapon = true
		
		current_weapon = weapons[current_weapon_slot]
		current_weapon.equip()
	
	if current_weapon.is_equip_finished() == false:
		return
	
	changing_weapon = false
	set_process(false)


func change_weapon(new_weapon_slot):
	
	if new_weapon_slot == current_weapon_slot:
		current_weapon.update_ammo() 
		return
	
	if weapons[new_weapon_slot] == null:
		return
	
	current_weapon_slot = new_weapon_slot
	changing_weapon = true
	
	weapons[current_weapon_slot].update_ammo() 
	update_weapon_index()
	
	
	if current_weapon != null:
		unequipped_weapon = false
		current_weapon.unequip()
	
	set_process(true)


func update_weapon_index():
	match current_weapon_slot:
		"Empty":
			weapon_index = 0
		"Primary":
			weapon_index = 1
		"Secondary":
			weapon_index = 2

func next_weapon():
	weapon_index += 1
	
	if weapon_index >= weapons.size():
		weapon_index = 0
	
	change_weapon(weapons.keys()[weapon_index])

func previous_weapon():
	weapon_index -= 1
	
	if weapon_index < 0:
		weapon_index = weapons.size() - 1
	
	change_weapon(weapons.keys()[weapon_index])


func fire():
	if not changing_weapon:
		current_weapon.fire()

func fire_stop():
	current_weapon.fire_stop()

func reload():
	if not changing_weapon:
		current_weapon.reload()


func add_ammo(amount):
	if current_weapon == null || current_weapon.name == "Unarmed":
		return false
	
	current_weapon.update_ammo("add", amount)
	return true


func update_hud(weapon_data):
	var weapon_slot = "1"
	
	match current_weapon_slot:
		"Empty":
			weapon_slot = "1"
		"Primary":
			weapon_slot = "2"
		"Secondary":
			weapon_slot = "3"
	
	hud.update_weapon_ui(weapon_data, weapon_slot)
