extends Node

func clear_piece(piece): # A function to reset the piece (fill with zeros)
	for x in range(4):
		for y in range(4):
			piece[x][y] = 0
	pass

func try_rotate(grid, piece, x, y): # The main function (Use all the others)
	if self._grid_check(grid,piece,x,y): 
		self._rotate_piece(piece)
	pass

func _rotate_piece(piece): # Function to rotate an pice
	var aux_piece = [[0,0,0,0], # An auxiliary matrix
	[0,0,0,0], # Used to clone the piece and make all the changes
	[0,0,0,0],
	[0,0,0,0]]
	self._clone_matrix(piece, aux_piece)
	var cordAux = Vector2(0,3)
	for m in range(4):
		for n in range(4):
			piece[cordAux.x][cordAux.y] = aux_piece[m][n]
			cordAux.x += 1
		cordAux.y -= 1
		cordAux.x = 0
	pass

func _clone_matrix(m1,m2): # Funtion to clone matrix
	for m in range(4): # I use this function to not change the input matrix, as rotation may not be possible
		for n in range(4):
			m2[m][n] = m1[m][n]
	pass

func _grid_check(grid,piece,x,y): # Funtion to check if a rotation is possible
	var ghost_piece = [[0,0,0,0], # Again, a auxiliary matrix
	[0,0,0,0],
	[0,0,0,0],
	[0,0,0,0]]
	self._clone_matrix(piece, ghost_piece)
	self._rotate_piece(ghost_piece)
	for m in range(4): # This is the part where i check the "collision"
		for n in range(4): # Its a code very similar to the image filters
			if grid[x+m][y+n] && ghost_piece[n][m]:
				return false
	return true
	pass
