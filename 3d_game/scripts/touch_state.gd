extends Node

## Analog move in Input.get_vector space: +x right, +y backward.
var move := Vector2.ZERO
var _look := Vector2.ZERO
var _jump := false


func add_look(relative: Vector2) -> void:
	_look += relative


func consume_look() -> Vector2:
	var value := _look
	_look = Vector2.ZERO
	return value


func press_jump() -> void:
	_jump = true


func consume_jump() -> bool:
	var pressed := _jump
	_jump = false
	return pressed


func clear() -> void:
	move = Vector2.ZERO
	_look = Vector2.ZERO
	_jump = false
