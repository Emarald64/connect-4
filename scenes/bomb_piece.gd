extends RigidBody2D

var targetPos:Vector2i
@onready var physicsPieces=get_parent().physicsPieces
@onready var board=get_parent().slots

func _physics_process(_delta: float) -> void:
	#var worldTargetPos=convertBoardPosToWorldPos(targetPos)
	#print(str(worldTargetPos.x-position.x)+','+str(worldTargetPos.y-position.y))
	if abs(position.y-convertBoardPosToWorldPos(targetPos).y)<10:
		for y in range(targetPos.y+1,6):
			var piece=physicsPieces[y][targetPos.x]
			if piece!=null and piece is RigidBody2D:
				piece.set_collision_layer_value(1,false)
				piece.gravity_scale=0.0
				piece.get_node('AnimationPlayer').play('explosion')
			board[y][targetPos.x].filled=false
		queue_free()
		get_node('../SFXPLayer').stream=preload("res://assets/deltarune-explosion.mp3")
		get_node('../SFXPLayer').volume_db=-20
		get_node('../SFXPLayer').play()

static func convertBoardPosToWorldPos(boardPos:Vector2i)->Vector2:
	return Vector2((boardPos.x*88)+44,(boardPos.y*86)+129)
