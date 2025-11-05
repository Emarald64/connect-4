extends CanvasItem

var slots:=[]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Add column selectors
	for i in range(7):
		var selector=preload("res://scenes/move_selector.tscn").instantiate()
		selector.pressed.connect(move.bind(i,false))
		%Board.add_child(selector)
	# Build grid 
	for y in range(6):
		slots.append(Array())
		for x in range(7):
			var slot=preload("res://scenes/slot.tscn").instantiate()
			slots[y].append(slot)
			%Board.add_child(slot)

func move(col:int,red:bool)->bool:
	if slots[0][col].filled:
		print('full')
		return false
	var row=0
	while row<5 and not slots[row+1][col].filled:
		row+=1
	print(row)
	slots[row][col].filled=true
	slots[row][col].red=red
	score()
	return true
	
func score()->void:
	pass
