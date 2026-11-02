extends Node3D

class_name WeaponBase

signal ammo_changed(current_magazine: int, reserve_ammo: int)
signal weapon_state_changed(state_name: String)
signal fired(hit_position: Vector3, hit_target: Node)

@export var weapon_name: String = "Weapon"
@export var weapon_type: String = "generic"
@export var magazine_size: int = 12
@export var reserve_ammo: int = 48
@export var fire_rate: float = 0.18
@export var reload_time: float = 1.25
@export var damage: float = 22.0
@export var effective_range: float = 60.0
@export var automatic: bool = false
@export var muzzle_offset: Vector3 = Vector3(0.12, 0.08, 0.0)

var current_magazine: int = 0
var reserve_count: int = 0
var is_reloading: bool = false
var next_fire_time: float = 0.0
var reload_timer: float = 0.0
var active: bool = true

func _ready() -> void:
	current_magazine = magazine_size
	reserve_count = reserve_ammo
	emit_signal("ammo_changed", current_magazine, reserve_count)

func can_fire(now_seconds: float) -> bool:
	if not active or is_reloading:
		return false
	if current_magazine <= 0:
		return false
	return now_seconds >= next_fire_time

func begin_reload() -> bool:
	if is_reloading or current_magazine >= magazine_size or reserve_count <= 0:
		return false
	is_reloading = true
	reload_timer = 0.0
	emit_signal("weapon_state_changed", "reloading")
	return true

func _process(delta: float) -> void:
	if not is_reloading:
		return
	reload_timer += delta
	if reload_timer >= reload_time:
		_finish_reload()

func _finish_reload() -> void:
	var ammo_needed := magazine_size - current_magazine
	var loaded := min(ammo_needed, reserve_count)
	current_magazine += loaded
	reserve_count -= loaded
	is_reloading = false
	emit_signal("ammo_changed", current_magazine, reserve_count)
	emit_signal("weapon_state_changed", "ready")

func try_fire(from_position: Vector3, direction: Vector3, ignore_node: Node = null) -> Dictionary:
	var now := Time.get_ticks_msec() / 1000.0
	if not can_fire(now):
		return {"hit": false, "hit_position": from_position + direction * effective_range, "target": null}

	next_fire_time = now + fire_rate
	if current_magazine <= 0:
		return {"hit": false, "hit_position": from_position + direction * effective_range, "target": null}

	current_magazine -= 1
	emit_signal("ammo_changed", current_magazine, reserve_count)

	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.new()
	query.from = from_position
	query.to = from_position + direction * effective_range
	query.collide_with_areas = true
	query.collide_with_bodies = true
	if ignore_node != null:
		query.exclude = [ignore_node]

	var result := space_state.intersect_ray(query)
	var hit_position := from_position + direction * effective_range
	var target: Node = null
	if result.size() > 0:
		hit_position = result["position"]
		if result.get("collider", null) != null:
			target = result["collider"]
		if target != null and target.has_method("apply_damage"):
			target.apply_damage(damage, weapon_name)
		emit_signal("fired", hit_position, target)
		return {"hit": true, "hit_position": hit_position, "target": target}

	emit_signal("fired", hit_position, null)
	return {"hit": false, "hit_position": hit_position, "target": null}

func set_active(flag: bool) -> void:
	active = flag
	if not active and is_reloading:
		is_reloading = false
		emit_signal("weapon_state_changed", "ready")

func get_ammo_state() -> Dictionary:
	return {"magazine": current_magazine, "reserve": reserve_count}
