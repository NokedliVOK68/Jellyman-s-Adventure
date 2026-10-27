extends Camera2D

@onready var screen_size: Vector2 = get_viewport_rect().size
@onready var player_node = get_tree().get_first_node_in_group("Player")

@export var max_shake = 5.0
@export var shake_fade = 10.0

var _shake_strength = 0.0

func trigger_shake():
	_shake_strength = max_shake


func _ready() -> void:
	set_screen_position()
	await get_tree().process_frame
	position_smoothing_enabled = true
	position_smoothing_speed = 7.0

func _process(delta: float) -> void:
	if _shake_strength > 0:
		_shake_strength = lerp(_shake_strength, 0.0, shake_fade * delta)
		offset = Vector2(randf_range(-_shake_strength, _shake_strength), randf_range(-_shake_strength,_shake_strength))
	
	set_screen_position()


func set_screen_position():
	var player_pos = player_node.global_position
	var x = floor(player_pos.x / screen_size.x) * screen_size.x + screen_size.x /2
	var y = floor(player_pos.y / screen_size.y) * screen_size.y + screen_size.y /2
	global_position = Vector2(x,y)
