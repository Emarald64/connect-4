class_name Main extends CanvasItem

enum scoreOutcome {none,blue,red,draw}

var slots:Array[Array]=[]
var physicsPieces:Array[Array]=[]

var currentlyRed:=false

var bombPieceProgress:=8

var redScore:=0
var blueScore:=0

static var winningLine:Array[Vector2i]=[]

var clearing:=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setupBoard()
func setupBoard()->void:
	# Add column selectors
	for i in range(7):
		var selector=preload("res://scenes/move_selector.tscn").instantiate()
		selector.pressed.connect(moveWithChangingColor.bind(i))
		$HBoxContainer/VBoxContainer/HBoxContainer.add_child(selector)
	# Build grid 
	for y in range(6):
		slots.append(Array())
		physicsPieces.append(Array())
		for x in range(7):
			#var slot=preload("res://scenes/slot.tscn").instantiate()
			#slot.pressed.connect(moveWithChangingColor.bind(x))
			#%Board.add_child(slot)
			physicsPieces[y].append(null)
			slots[y].append(Slot.new())

func moveWithChangingColor(col:int)->void:
	if await move(col,currentlyRed):
		currentlyRed=not currentlyRed

func move(col:int,red:bool)->bool:
	if slots[0][col].filled or not $"Placing Cooldown".is_stopped() or clearing:
		return false
	var row=0
	while row<5 and not slots[row+1][col].filled:
		row+=1
	if bombPieceProgress==9 and not red:
		var piece=preload("res://scenes/bomb_piece.tscn").instantiate()
		piece.position=Vector2((col*88)+44,0)
		piece.get_node("Sprite2D").self_modulate=Color(1,0,0) if red else Color(0.0, 0.6, 1.0, 1.0)
		piece.targetPos=Vector2i(col,row)
		add_child(piece)
		bombPieceProgress=0
		updateBombProgress()
	else:
		slots[row][col].filled=true
		slots[row][col].red=red
		var piece=preload("res://scenes/piece.tscn").instantiate()
		piece.position=Vector2((col*88)+44,0)
		piece.modulate=Color(1,0,0) if red else Color(0.0, 0.6, 1.0, 1.0)
		add_child(piece)
		physicsPieces[row][col]=piece
		if not red:
			bombPieceProgress+=1
			updateBombProgress()
	#slots[row][col].get_node('Piece').show()
	var score:=scoreBoard(slots)
	if score!=scoreOutcome.none:
		for i in range(2):
				var linePoint:=Vector2(winningLine[i])
				linePoint.x=(linePoint.x*88)+44
				linePoint.y=(linePoint.y*86)+129
				print(winningLine[i])
				print(linePoint)
				$Line2D.set_point_position(i,linePoint)
		var time=(0.418939379961*(row**0.5))
		clearing=true
		await get_tree().create_timer(time).timeout
		if score!=scoreOutcome.draw:
			$Line2D.show()
			if score==scoreOutcome.blue:
				$GPUParticles2D.process_material.color=Color(0.0, 0.6, 1.0, 1.0)
				blueScore+=1
				%BlueScore.text=str(blueScore)
				$SFXPLayer.volume_db=-10
				$SFXPLayer.stream=preload("res://assets/tada.mp3")
			elif score==scoreOutcome.red:
				$GPUParticles2D.process_material.color=Color.RED
				redScore+=1
				%RedScore.text=str(redScore)
				$SFXPLayer.volume_db=-15
				$SFXPLayer.stream=preload("res://assets/buzzer.mp3")
		$SFXPLayer.play()
		$GPUParticles2D.emitting=true
		bombPieceProgress=0
		updateBombProgress()
		await get_tree().create_timer(2).timeout
		#print('reset')
		clear(score==scoreOutcome.red)
	else:$"Placing Cooldown".start()
	return true
	
@warning_ignore("shadowed_variable")
static func scoreBoard(slots:Array[Array])->scoreOutcome:
	#Verticals
	for y in range(3):
		for x in range(7):
			if slots[y][x].red==slots[y+1][x].red and slots[y][x].red==slots[y+2][x].red and slots[y][x].red==slots[y+3][x].red and slots[y][x].filled and slots[y+1][x].filled and slots[y+2][x].filled and slots[y+3][x].filled:
				winningLine=[Vector2i(x,y),Vector2i(x,y+3)]
				return scoreOutcome.red if slots[y][x].red else scoreOutcome.blue
				
	# Horazontals
	for y in range(6):
		for x in range(4):
			if slots[y][x].red==slots[y][x+1].red and slots[y][x].red==slots[y][x+2].red and slots[y][x].red==slots[y][x+3].red and slots[y][x].filled and slots[y][x+1].filled and slots[y][x+2].filled and slots[y][x+3].filled:
				winningLine=[Vector2i(x,y),Vector2i(x+3,y)]
				return scoreOutcome.red if slots[y][x].red else scoreOutcome.blue
				
	# down-right Diagonals
	for y in range(3):
		for x in range(4):
			if slots[y][x].red==slots[y+1][x+1].red and slots[y][x].red==slots[y+2][x+2].red and slots[y][x].red==slots[y+3][x+3].red and slots[y][x].filled and slots[y+1][x+1].filled and slots[y+2][x+2].filled and slots[y+3][x+3].filled:
				winningLine=[Vector2i(x,y),Vector2i(x+3,y+3)]
				return scoreOutcome.red if slots[y][x].red else scoreOutcome.blue
				
	# up-right diagonals
	for y in range(3):
		for x in range(4):
			if slots[y][x+3].red==slots[y+1][x+2].red and slots[y][x+3].red==slots[y+2][x+1].red and slots[y][x+3].red==slots[y+3][x].red and slots[y+3][x].filled and slots[y+2][x+1].filled and slots[y+1][x+2].filled and slots[y][x+3].filled:
				winningLine=[Vector2i(x+3,y),Vector2i(x,y+3)]
				return scoreOutcome.red if slots[y][x].red else scoreOutcome.blue
	
	# draws
	var willDraw=true
	for x in range(7):
		if not slots[0][x].filled:
			willDraw=false
	
	return scoreOutcome.draw if willDraw else scoreOutcome.none

func clear(computerPlay:bool)->void:
	$ClearTimer.start()
	$StaticBody2D.set_collision_layer_value(1,false)
	$Line2D.hide()
	await $ClearTimer.timeout
	$StaticBody2D.set_collision_layer_value(1,true)
	for y in range(6):
		for x in range(7):
			slots[y][x].filled=false
	if computerPlay:
		move(ComputerPlayer.getMove(slots),true)
	currentlyRed=false
	clearing=false


func checkPlayComputerMove() -> void:
	if currentlyRed:
		moveWithChangingColor(ComputerPlayer.getMove(slots))

static func duplicateBoard(board:Array[Array]) -> Array[Array]:
	var newBoard:Array[Array]=[]
	for y in range(6):
		newBoard.append(Array())
		for x in range(7):
			newBoard[y].append(board[y][x].duplicate())
	return newBoard
	
func updateBombProgress()->void:
	%BombPieceProgress.value=bombPieceProgress
	%BombPieceProgress/Label.text=str(bombPieceProgress)+'/10'
