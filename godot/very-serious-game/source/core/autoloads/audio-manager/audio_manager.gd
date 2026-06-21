extends Node

signal crossfade_finished

@export var sound_effect_settings : Array[SoundEffectSettings]

@onready var bg_track_1: AudioStreamPlayer = $BackgroundMusic/Track1
@onready var bg_track_2: AudioStreamPlayer = $BackgroundMusic/Track2
@onready var bg_animations: AnimationPlayer = $BackgroundMusic/BGAnimations
@onready var sfx: Node = $SFX
@onready var sfx_3d: Node3D = $SFX3D

var sound_effect_dict : Dictionary[SoundEffectSettings.SOUND_EFFECT_TYPE, SoundEffectSettings] = {}

func _ready() -> void:
	setup_sound_effects_dict()

#region music


## Plays a track on the first available player
func play(new_stream : AudioStream):
	if not bg_track_1.playing:
		bg_track_1.stream = new_stream
		bg_track_1.volume_db = 0
		bg_track_1.play()
	
	elif not bg_track_2.playing:
		bg_track_2.stream = new_stream
		bg_track_2.volume_db = 0
		bg_track_2.play()

## Fades out current track and in next track.
## Next track can be empty to just fade out
func crossfade_to(new_stream : AudioStream):
	# mid-fade
	if bg_track_1.playing and bg_track_2.playing:
		return
	
	if bg_track_2.playing:
		bg_track_1.stream = new_stream
		bg_track_1.play()
		#tween_crossfade_audio_players(bg_track_2, bg_track_1)
		bg_animations.play("FadeToTrack1")
	
	# track 1 or no track playing
	else:
		bg_track_2.stream = new_stream
		bg_track_2.play()
		#tween_crossfade_audio_players(bg_track_1, bg_track_2)
		bg_animations.play("FadeToTrack2")
	
	await bg_animations.animation_finished
	crossfade_finished.emit()


func tween_crossfade_audio_players(playing : AudioStreamPlayer, next : AudioStreamPlayer, new_volume : float = 0, duration_seconds : float = 1):
	var tween_1 = create_tween().set_ease(Tween.EASE_IN)
	tween_1.tween_property(playing, "volume_db", 0, duration_seconds)
	
	var tween_2 = create_tween().set_ease(Tween.EASE_IN)
	tween_2.tween_property(next, "volume_db", new_volume, duration_seconds)
	
#endregion

#region sound effects
func setup_sound_effects_dict():
	for setting : SoundEffectSettings in sound_effect_settings:
		sound_effect_dict[setting.type] = setting

func create_sound_effect(sound_effect_type : SoundEffectSettings.SOUND_EFFECT_TYPE):
	if not sound_effect_dict.has(sound_effect_type):
		printerr("Tried to create a sound effect of unknown tyoe: %s" %sound_effect_type)
		return
	
	var sound_effect_setting : SoundEffectSettings = sound_effect_dict[sound_effect_type]
	
	if not sound_effect_setting.has_open_limit():
		return
	
	sound_effect_setting.add_audio_count(1)
	
	# instantiate audio player node
	var new_sound_effect := AudioStreamPlayer.new()
	new_sound_effect.bus = "SFX"
	sfx.add_child(new_sound_effect)
	
	# get settings for type and apply to audio player
	new_sound_effect.stream = sound_effect_setting.stream
	new_sound_effect.volume_db = sound_effect_setting.volume_db
	new_sound_effect.pitch_scale = sound_effect_setting.pitch_scale
	# TODO add randomness
	
	# connect signals
	new_sound_effect.finished.connect(sound_effect_setting.on_audio_finished)
	new_sound_effect.finished.connect(new_sound_effect.queue_free)
	
	new_sound_effect.play()

func create_sound_effect_at(global_pos : Vector3, sound_effect_type : SoundEffectSettings.SOUND_EFFECT_TYPE):
	if not sound_effect_dict.has(sound_effect_type):
		printerr("Tried to create a sound effect of unknown type: %s" %sound_effect_type)
		return
	
	var sound_effect_setting : SoundEffectSettings = sound_effect_dict[sound_effect_type]
	
	if not sound_effect_setting.has_open_limit():
		return
	
	sound_effect_setting.add_audio_count(1)
	
	# instantiate audio player node at global pos
	var new_sound_effect := AudioStreamPlayer3D.new()
	new_sound_effect.bus = "SFX"
	sfx_3d.add_child(new_sound_effect)
	new_sound_effect.global_position = global_pos
	
	# get settings for type and apply to audio player
	new_sound_effect.stream = sound_effect_setting.stream
	new_sound_effect.volume_db = sound_effect_setting.volume_db
	new_sound_effect.pitch_scale = sound_effect_setting.pitch_scale
	# TODO add randomness
	
	# connect signals
	new_sound_effect.finished.connect(sound_effect_setting.on_audio_finished)
	new_sound_effect.finished.connect(new_sound_effect.queue_free)
	
	new_sound_effect.play()
	


#endregion
