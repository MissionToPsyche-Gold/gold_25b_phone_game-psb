extends Node
## Autoload "GameSettings": volume and motion preferences, saved on the device.
## No account or personal info is stored (report PDRS-2).

signal changed

const SAVE_PATH := "user://settings.cfg"

var music_volume := 70     # 0..100
var sfx_volume := 80       # 0..100
var reduce_motion := false # turns off drifting stars, meteors and bouncy intros


func _ready() -> void:
	_ensure_bus("Music")
	_ensure_bus("SFX")
	_load()
	_apply()


func set_music_volume(v: int) -> void:
	music_volume = clampi(v, 0, 100)
	_changed()


func set_sfx_volume(v: int) -> void:
	sfx_volume = clampi(v, 0, 100)
	_changed()


func set_reduce_motion(on: bool) -> void:
	reduce_motion = on
	_changed()


func _changed() -> void:
	_apply()
	_save()
	changed.emit()


func _apply() -> void:
	_set_bus("Music", music_volume)
	_set_bus("SFX", sfx_volume)


func _set_bus(bus_name: String, volume: int) -> void:
	var i := AudioServer.get_bus_index(bus_name)
	if i == -1:
		return
	AudioServer.set_bus_mute(i, volume == 0)
	AudioServer.set_bus_volume_db(i, linear_to_db(maxf(volume, 1) / 100.0))


func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) != -1:
		return
	AudioServer.add_bus()
	var i := AudioServer.bus_count - 1
	AudioServer.set_bus_name(i, bus_name)
	AudioServer.set_bus_send(i, "Master")


func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "music", music_volume)
	cfg.set_value("audio", "sfx", sfx_volume)
	cfg.set_value("display", "reduce_motion", reduce_motion)
	cfg.save(SAVE_PATH)


func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	music_volume = int(cfg.get_value("audio", "music", music_volume))
	sfx_volume = int(cfg.get_value("audio", "sfx", sfx_volume))
	reduce_motion = bool(cfg.get_value("display", "reduce_motion", reduce_motion))
