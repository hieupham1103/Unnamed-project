extends Node2D
class_name Item

@export var is_using = false:
	set(value):
		is_using = value
		if value == true:
			start_using_item.emit(self)
		else:
			end_using_item.emit(self)

signal start_using_item(item)
signal end_using_item(item)

var player = null

