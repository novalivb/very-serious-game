extends Node

var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://settings.ini"

func _ready() -> void:
	
	# load config or create a new one with default values
	if not FileAccess.file_exists(SETTINGS_FILE_PATH):
		
		# ------ section, key, value ------ #
		# audio settings
		config.set_value("audio", "master_volume", 1.0)
		config.set_value("audio", "sfx_volume", 1.0)
		config.set_value("audio", "music_volume", 1.0)
		
		# player settings
		config.set_value("player", "score", 0.0)
		
		
		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)


#region save and load functions
func save_audio_setting(key: String, value):
	config.set_value("audio", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_audio_settings():
	var audioSettings = {}
	for key in config.get_section_keys("audio"):
		audioSettings[key] = config.get_value("audio", key)
	return audioSettings

func save_player_setting(key: String, value):
	config.set_value("player", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_player_settings():
	var playerSettings = {}
	for key in config.get_section_keys("player"):
		playerSettings[key] = config.get_value("player", key)
	return playerSettings

func save_video_setting(key: String, value):
	config.set_value("video", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_video_settings():
	var videoSettings = {}
	for key in config.get_section_keys("video"):
		videoSettings[key] = config.get_value("video", key)
	return videoSettings


#endregion
