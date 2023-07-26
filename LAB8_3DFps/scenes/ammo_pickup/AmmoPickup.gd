extends Area


export(int) var ammo = 15


func _on_AmmoPickup_body_entered(body):
	if body.name == "Player":
		var result = body.weapon_manager.add_ammo(ammo)
		
		if result:
			queue_free()
