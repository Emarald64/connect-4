extends CanvasItem

var slots:=[]
var currentlyRed:=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setupBoard()
func setupBoard()->void:
	# Add column selectors
	for i in range(7):
		var selector=preload("res://scenes/move_selector.tscn").instantiate()
		selector.pressed.connect(moveWithChangingColor.bind(i))
		%Board.add_child(selector)
	# Build grid 
	for y in range(6):
		slots.append(Array())
		for x in range(7):
			var slot=preload("res://scenes/slot.tscn").instantiate()
			slots[y].append(slot)
			%Board.add_child(slot)

func moveWithChangingColor(col:int)->void:
	if await move(col,currentlyRed):
		currentlyRed=not currentlyRed

func move(col:int,red:bool)->bool:
	if slots[0][col].filled or not $"Placing Cooldown".is_stopped() or not $ClearTimer.is_stopped():
		print('full')
		return false
	var row=0
	while row<5 and not slots[row+1][col].filled:
		row+=1
	print(row)
	slots[row][col].filled=true
	slots[row][col].red=red
	var piece=preload("res://scenes/piece.tscn").instantiate()
	piece.position=Vector2((col*88)+44,0)
	piece.modulate=Color(1,0,0) if red else Color(0.0, 0.6, 1.0, 1.0)
	add_child(piece)
	#slots[row][col].get_node('Piece').show()
	$"Placing Cooldown".start()
	var score:=scoreBoard()
	if score!=&"none":
		print(score+" Won!")
		var time=1+pow((row*-172)/(piece.get_gravity().y),0.5)
		print(time)
		await get_tree().create_timer(time).timeout
		print('reset')
		clear()
	return true
	
func scoreBoard()->StringName:
	#Verticals
	for y in range(3):
		for x in range(7):
			if slots[y][x].red==slots[y+1][x].red and slots[y][x].red==slots[y+2][x].red and slots[y][x].red==slots[y+3][x].red and slots[y][x].filled and slots[y+1][x].filled and slots[y+2][x].filled and slots[y+3][x].filled:
				return &"red" if slots[y][x].red else &"blue"
				
	# Horazontals
	for y in range(6):
		for x in range(4):
			if slots[y][x].red==slots[y][x+1].red and slots[y][x].red==slots[y][x+2].red and slots[y][x].red==slots[y][x+3].red and slots[y][x].filled and slots[y][x+1].filled and slots[y][x+2].filled and slots[y][x+3].filled:
				return &"red" if slots[y][x].red else &"blue"
				
	# down-right Diagonals
	for y in range(3):
		for x in range(4):
			if slots[y][x].red==slots[y+1][x+1].red and slots[y][x].red==slots[y+2][x+2].red and slots[y][x].red==slots[y+3][x+3].red and slots[y][x].filled and slots[y+1][x+1].filled and slots[y+2][x+2].filled and slots[y+3][x+3].filled:
				return &"red" if slots[y][x].red else &"blue"
				
	# up-right diagonals
	for y in range(3):
		for x in range(4):
			if slots[y][x+3].red==slots[y+1][x+2].red and slots[y][x+3].red==slots[y+2][x+1].red and slots[y][x+3].red==slots[y+3][x].red and slots[y+3][x].filled and slots[y+2][x+1].filled and slots[y+1][x+2].filled and slots[y][x+3].filled:
				return &"red" if slots[y][x].red else &"blue"
	return &"none"

func clear()->void:
	$ClearTimer.start()
	$StaticBody2D.set_collision_layer_value(1,false)
	await $ClearTimer.timeout
	$StaticBody2D.set_collision_layer_value(1,true)
	for y in range(6):
		for x in range(7):
			slots[y][x].filled=false
