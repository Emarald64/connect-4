class_name ComputerPlayer

enum scoreOutcome {none,blue,red}

static func getMove(board:Array[Array])->int:
	return 0
	var scores:Array[int]=[0,0,0,0,0,0,0]
	for x in range(7):
		if board[0][x].filled:
			print(str(x) + " is filled")
			scores[x]=-2
		else:
			var boardCopy=Main.duplicateBoard(board)
			
			#place piece
			var row:=0
			while row<5 and not boardCopy[row+1][x].filled:
				row+=1
			boardCopy[row][x].filled=true
			boardCopy[row][x].red=true
			
			# If can win this turn play the move
			if Main.scoreBoard(boardCopy)==scoreOutcome.red:
				print(str(x)+" will win the game")
				return x
			
			# sumulate oponent moves
			for x2 in range(7):
				if not boardCopy[0][x2].filled:
					var boardCopy2=Main.duplicateBoard(boardCopy)
				
					#place piece
					var row2=0
					while row2<5 and not boardCopy2[row2+1][x2].filled:
						row2+=1
					boardCopy2[row2][x2].filled=true
					boardCopy2[row2][x2].red=false
					if Main.scoreBoard(boardCopy2)==scoreOutcome.blue:
						print(str(x)+','+str(x2)+' will make blue win')
						scores[x]=-1
						break
	
	#Pick randomly
	print(scores)
	var choices:Array[int]=[]
	var minScore=(-1 if scores.all(func(x):return x<0) else 0)
		
	for i in range(7):
		if scores[i]==minScore:choices.append(i)
		
	return choices.pick_random()
