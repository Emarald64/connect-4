extends TextureRect

signal boardClicked(row:int)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index==MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
		print('click')
		boardClicked.emit(int(event.position.x/88))
