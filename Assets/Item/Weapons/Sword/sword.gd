extends Weapon

@export var DASH_SPEED = 300

var count_attack = 0
var attackable = true
var vector_dash = Vector2.ZERO
@export var is_dasing = false

func execute():
	if not attackable:
		return
	is_using = true
	attackable = false
	var mouse_position = get_global_mouse_position()
	vector_dash = mouse_position - global_position
	vector_dash = vector_dash.normalized()
	if vector_dash.x * player._body.scale.x < 0:
		player.flip_sprite()
	look_at(mouse_position)
	match count_attack:
		0:
			$AnimationPlayer.play("attack_0")
		1:
			$AnimationPlayer.play("attack_1")
		2:
			$AnimationPlayer.play("attack_2")
		3:
			count_attack = 0
			$AnimationPlayer.play("attack_0")
	$AnimationPlayer/animation_timer.start(0.5)
	count_attack += 1
	return true
	
func _physics_process(delta):
	if is_dasing:
		player.move_and_collide(vector_dash * DASH_SPEED * delta)
	
func get_input(input):
	if Input.is_action_just_pressed(input):
		execute()

func _on_animation_timer_timeout():
	count_attack = 0

func _on_end_using_item(item):
	vector_dash = Vector2.ZERO
	$Timer.start(0.1)
	
func _on_timer_timeout():
	attackable = true

