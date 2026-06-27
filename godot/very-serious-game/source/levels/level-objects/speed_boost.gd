extends Powerup

@onready var animation_player: AnimationPlayer = %AnimationPlayer

var entered_screen : bool = false

func _ready() -> void:
	if not animation_player == null:
		animation_player.play("spin")


func _on_body_entered(body: Node2D) -> void:
	if collected: return
	if body is CharacterPlayer:
		AudioManager.create_sound_effect(SoundEffectSettings.SOUND_EFFECT_TYPE.POWERUP)
		collected = true
		body.collect_powerup(effect)
		queue_free()
	


# kill if left screen after entering
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	entered_screen = true

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if not entered_screen:
		return
	queue_free()
