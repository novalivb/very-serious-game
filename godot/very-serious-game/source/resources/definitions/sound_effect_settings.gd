class_name SoundEffectSettings extends Resource

enum SOUND_EFFECT_TYPE {
	UI_ACCEPT,
	UI_CANCEL,
}

@export_range(0.0, 10.0, 1.0) var limit : float = 5
@export var type : SOUND_EFFECT_TYPE
@export var stream : AudioStream
@export_range(-80.0, 20.0) var volume_db : float = 0
@export_range(0.0, 4.0, 0.1) var pitch_scale : float = 1
@export_range(0.0, 1.0, 0.1) var randomness : float = 0

var audio_count : int = 0

## Can add negatives, won't pass 0
func add_audio_count(amount : int):
	audio_count = max(0, audio_count + amount)

## Limit not reached when true
func has_open_limit():
	return audio_count < limit

## Decrement audio count
func on_audio_finished():
	add_audio_count(-1)
