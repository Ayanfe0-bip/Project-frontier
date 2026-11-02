extends Node

signal health_changed(current_health: float, max_health: float)
signal stamina_changed(current_stamina: float, max_stamina: float)
signal died(source: String)

@export_group("Vitals")
@export var max_health: float = 100.0
@export var max_stamina: float = 100.0
@export var health_regen_per_second: float = 3.0
@export var stamina_regen_per_second: float = 18.0
@export var recovery_window_seconds: float = 1.2
@export var damage_cooldown_seconds: float = 0.3

var current_health: float = max_health
var current_stamina: float = max_stamina
var _last_damage_time: float = 0.0

func _ready() -> void:
	_reset_state()

func _reset_state() -> void:
	current_health = clamp(max_health, 0.0, max_health)
	current_stamina = clamp(max_stamina, 0.0, max_stamina)
	_last_damage_time = 0.0
	emit_signal("health_changed", current_health, max_health)
	emit_signal("stamina_changed", current_stamina, max_stamina)

func _process(delta: float) -> void:
	if current_health <= 0.0:
		return

	if current_health < max_health and (Time.get_ticks_msec() / 1000.0) - _last_damage_time >= recovery_window_seconds:
		current_health = clamp(current_health + health_regen_per_second * delta, 0.0, max_health)
		emit_signal("health_changed", current_health, max_health)

	if current_stamina < max_stamina:
		current_stamina = clamp(current_stamina + stamina_regen_per_second * delta, 0.0, max_stamina)
		emit_signal("stamina_changed", current_stamina, max_stamina)

func take_damage(amount: float, source: String = "unknown") -> float:
	if not is_alive() or amount <= 0.0:
		return current_health

	var now := Time.get_ticks_msec() / 1000.0
	if now - _last_damage_time < damage_cooldown_seconds:
		return current_health

	_last_damage_time = now
	current_health = clamp(current_health - amount, 0.0, max_health)
	emit_signal("health_changed", current_health, max_health)

	if current_health <= 0.0:
		emit_signal("died", source)

	return current_health

func heal(amount: float) -> float:
	if not is_alive() or amount <= 0.0:
		return current_health

	current_health = clamp(current_health + amount, 0.0, max_health)
	emit_signal("health_changed", current_health, max_health)
	return current_health

func consume_stamina(amount: float) -> bool:
	if amount <= 0.0:
		return true

	if current_stamina >= amount:
		current_stamina = clamp(current_stamina - amount, 0.0, max_stamina)
		emit_signal("stamina_changed", current_stamina, max_stamina)
		return true

	current_stamina = clamp(current_stamina, 0.0, max_stamina)
	return false

func recover_stamina(amount: float) -> float:
	if amount <= 0.0:
		return current_stamina

	current_stamina = clamp(current_stamina + amount, 0.0, max_stamina)
	emit_signal("stamina_changed", current_stamina, max_stamina)
	return current_stamina

func can_sprint() -> bool:
	return is_alive() and current_stamina > 0.0

func get_health_ratio() -> float:
	if max_health <= 0.0:
		return 0.0
	return current_health / max_health

func get_stamina_ratio() -> float:
	if max_stamina <= 0.0:
		return 0.0
	return current_stamina / max_stamina

func is_alive() -> bool:
	return current_health > 0.0
