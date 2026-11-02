extends Node3D

@export var weapon_scenes: Array[PackedScene] = []
@export var weapon_anchor_path: NodePath = ^"WeaponAnchor"

@onready var weapon_anchor: Node3D = get_node_or_null(weapon_anchor_path)
@onready var player_ref: CharacterBody3D = get_parent()

var equipped_weapons: Array[Node3D] = []
var current_weapon_index: int = -1
var current_weapon: WeaponBase = null
var aiming: bool = false

func _ready() -> void:
	if player_ref == null:
		player_ref = get_parent()
	_spawn_weapons()
	if equipped_weapons.size() > 0:
		switch_to_weapon(0)

func _spawn_weapons() -> void:
	for weapon_scene in weapon_scenes:
		if weapon_scene == null:
			continue
		var weapon_instance: Node3D = weapon_scene.instantiate()
		if weapon_instance == null:
			continue
		add_child(weapon_instance)
		weapon_instance.visible = true
		equipped_weapons.append(weapon_instance)
		if weapon_instance.has_method("set_active"):
			weapon_instance.set_active(false)
		if weapon_instance is WeaponBase:
			weapon_instance.owner = self

func switch_to_weapon(index: int) -> bool:
	if index < 0 or index >= equipped_weapons.size():
		return false
	for i in range(equipped_weapons.size()):
		var weapon: Node3D = equipped_weapons[i]
		if weapon == null:
			continue
		if weapon.has_method("set_active"):
			weapon.set_active(i == index)
		weapon.visible = i == index
	if equipped_weapons[index] is WeaponBase:
		current_weapon = equipped_weapons[index]
	else:
		current_weapon = null
	current_weapon_index = index
	update_weapon_transform()
	return true

func cycle_weapon(delta_index: int) -> bool:
	if equipped_weapons.is_empty():
		return false
	var next_index := current_weapon_index + delta_index
	if next_index < 0:
		next_index = equipped_weapons.size() - 1
	if next_index >= equipped_weapons.size():
		next_index = 0
	return switch_to_weapon(next_index)

func _process(delta: float) -> void:
	var aim_pressed := Input.is_action_pressed("aim")
	if aim_pressed != aiming:
		aiming = aim_pressed
	update_weapon_transform()
	if current_weapon == null:
		return
	if Input.is_action_just_pressed("reload"):
		current_weapon.begin_reload()
	if Input.is_action_just_pressed("weapon_next"):
		cycle_weapon(1)
	if Input.is_action_just_pressed("weapon_prev"):
		cycle_weapon(-1)
	if Input.is_action_pressed("fire"):
		try_fire()

func update_weapon_transform() -> void:
	if current_weapon == null or weapon_anchor == null:
		return
	var target_position := Vector3.ZERO
	if aiming:
		target_position = Vector3(0.22, -0.06, -0.18)
	else:
		target_position = Vector3(0.18, -0.12, -0.05)
	current_weapon.global_position = weapon_anchor.global_position + target_position
	current_weapon.global_rotation = weapon_anchor.global_rotation
	current_weapon.rotation.x = 0.0
	current_weapon.rotation.y = 0.0
	current_weapon.rotation.z = 0.0

func try_fire() -> Dictionary:
	if current_weapon == null:
		return {"hit": false, "hit_position": Vector3.ZERO, "target": null}
	if player_ref == null:
		return {"hit": false, "hit_position": Vector3.ZERO, "target": null}
	var camera_ref := get_tree().current_scene.get_node_or_null("ThirdPersonCamera")
	var shoot_origin := weapon_anchor.global_position + current_weapon.muzzle_offset
	var look_direction := Vector3.FORWARD
	if camera_ref != null:
		look_direction = -camera_ref.global_transform.basis.z
		look_direction = look_direction.normalized()
	else:
		look_direction = -global_transform.basis.z
	var result := current_weapon.try_fire(shoot_origin, look_direction, player_ref)
	return result

func get_current_weapon_state() -> Dictionary:
	if current_weapon == null:
		return {"name": "None", "magazine": 0, "reserve": 0, "aiming": false}
	var ammo := current_weapon.get_ammo_state()
	return {
		"name": current_weapon.weapon_name,
		"magazine": ammo["magazine"],
		"reserve": ammo["reserve"],
		"aiming": aiming,
	}
