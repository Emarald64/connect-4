extends TextureRect

signal boardClicked(row:int)

func _unhandled_input(event: InputEvent) -> void:
	#print(event)
	if event is InputEventMouseButton and event.button_index==MouseButton.MOUSE_BUTTON_LEFT and event.pressed and event.position.x<=612:
		print(event.position)
		boardClicked.emit(int(event.position.x/88))
