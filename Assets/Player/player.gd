extends CharacterBody2D

@export var SPEED = 200

enum player_state{
	IDLE,
	RUN,
	FREEZE,
	MELEE_ATTACK
}

@onready var _anim = $body/animation/AnimationPlayer
@onready var _anim_state = $body/animation/AnimationTree
@onready var _sprite = $body/Sprite2D
@onready var _body = $body
@export var state: player_state = player_state.IDLE

@onready var _left_hand = $body/Sprite2D/hand/left
@onready var _right_hand = $body/Sprite2D/hand/right
var _left_weapon = null
var _right_weapon = null

func _ready():
	_anim_state.active = true
	
	select_weapon("left", load("res://Assets/Item/Weapons/Sword/sword.tscn").instantiate())

func _physics_process(delta):
	movement(delta)
	
	match state:
		player_state.RUN:
			_anim_state["parameters/conditions/walking"] = true
			_anim_state["parameters/conditions/idling"] = false
			_anim_state["parameters/conditions/freezing"] = false
			_anim_state["parameters/conditions/melee_attack"] = false
		player_state.IDLE:
			_anim_state["parameters/conditions/walking"] = false
			_anim_state["parameters/conditions/idling"] = true
			_anim_state["parameters/conditions/freezing"] = false
			_anim_state["parameters/conditions/melee_attack"] = false
		player_state.FREEZE:
			_anim_state["parameters/conditions/walking"] = false
			_anim_state["parameters/conditions/idling"] = false
			_anim_state["parameters/conditions/freezing"] = true
			_anim_state["parameters/conditions/melee_attack"] = false
		player_state.MELEE_ATTACK:
			_anim_state["parameters/conditions/walking"] = false
			_anim_state["parameters/conditions/idling"] = false
			_anim_state["parameters/conditions/freezing"] = false
			_anim_state["parameters/conditions/melee_attack"] = true
			

func flip_sprite():
	_body.scale.x = -_body.scale.x
	
func _input(event):
	if state == player_state.FREEZE or state == player_state.MELEE_ATTACK:
		return
	if not _left_weapon == null and _left_weapon.has_method("get_input"):
		_left_weapon.get_input("ui_left_mouse")
			
	if not _right_weapon == null and _right_hand.has_method("get_input"):
		_right_weapon.get_input("ui_right_mouse")

func start_using(item):
	if item is Weapon:
		match item.type:
			Weapon.type_weapon.MELEE:
				change_state(player_state.MELEE_ATTACK)
				return
	change_state(player_state.FREEZE)

func cancel_using(item):
	change_state(player_state.IDLE)

func movement(delta):
	if state == player_state.FREEZE or state == player_state.MELEE_ATTACK:
		return
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	input_direction = input_direction.normalized()

	if input_direction != Vector2.ZERO:
		velocity = input_direction * SPEED
	else:
		velocity = Vector2.ZERO
	
	if velocity != Vector2.ZERO:
		change_state(player_state.RUN)
	else:
		change_state(player_state.IDLE)
		
	if velocity.x < 0 and _body.scale.x == 1:
		_anim_state["parameters/playback"].travel("turning")
	elif velocity.x > 0 and _body.scale.x == -1:
		_anim_state["parameters/playback"].travel("turning")
	
	move_and_collide(velocity * delta)
	

func select_weapon(hand_name: String, weapon):
	var hand = _left_hand
	if hand_name == "right":
		hand = _right_hand
	for item in hand.get_children():
		item.remove_child(item)
		
	hand.add_child(weapon)
	
	if not weapon == null:
		weapon.connect("start_using_item", start_using)
		weapon.connect("end_using_item", cancel_using)
		weapon.player = self
	
	if hand_name == "left":
		_left_weapon = weapon
	else:
		_right_weapon = weapon

func change_state(new_state):
	state = new_state
