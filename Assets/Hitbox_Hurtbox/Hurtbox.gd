extends Area2D


@onready var timer = $Timer
@onready var collisionShape = $CollisionShape2D

signal invincibility_started
signal invincibility_ended

var invincible = false

func set_invincible(value):
	invincible = value
	if invincible == true:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")

func start_invincibility(duration):
	set_invincible(true)
	timer.start(duration)

func _on_timer_timeout():
	# print("Time up")
	set_invincible(false)

func _on_invincibility_started():
	set_deferred("monitoring", false)

func _on_invincibility_ended():
	monitoring = true
