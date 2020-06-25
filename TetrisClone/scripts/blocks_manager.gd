extends Node2D

signal lineDestroied(value)
signal next_piece(value)
signal gameOver

var block = preload("res://scenes/objects/object_blocks.tscn")
var barrier = preload("res://scenes/objects/object_barrier.tscn")

# Script where i keep the shape of the pieces in a matrix format
const blocks_ID = preload("res://scripts/blocks_ID.gd")
onready var b_ID = blocks_ID.new()

# Script where i keep the functions to rotate the piece (and one to clean)
const piece_management = preload("res://scripts/piece_management.gd")
onready var p_manager = piece_management.new()

# The Grid
var matrix = []

onready var timer = $timer # Timer to control the piece fall
var interval = 0.5 # Timer interval

# Mark the line and colun of the piece
var piece_pos = Vector2(7,-1) # .x = colun and .y = line

# The var who will say to the code what type of piece has to spawn
var piece_shape = 0 # This work directly with the blocks_ID.gd

# That is the 'piece keeper', during the execution of the code
# I will use this to make all the changes, movements and verifications
var piece = [[0,0,0,0], # This work directly with the piece_management.gd
	[0,0,0,0],
	[0,0,0,0],
	[0,0,0,0]]

func _ready():
	randomize()
	piece_shape = randi()%7
	emit_signal("next_piece", piece_shape)
	
	set_process_input(true)
	
	gen_grid()
	
	start_grid()
	
	pass

func _input(event):
	if event.is_action_pressed("ui_left"):
		move_piece(-1,0)
	elif event.is_action_pressed("ui_right"):
		move_piece(1,0)
	if event.is_action_pressed("ui_select"):
		rot_piece()
	if event.is_action_pressed("ui_down"):
		interval = 0.1
	elif event.is_action_released("ui_down"):
		interval = 0.5
	pass

func gen_grid(): # Just create the matrix
	for x in range(18):
		matrix.append([])
		matrix[x] = []
		for y in range(30):
			matrix[x].append([])
			matrix[x][y] = null
	pass

func start_grid(): # Filling in the grid...
	for x in range(18):
		for y in range(30):
			if x > 3 and x < 14 and y < 26:
				matrix[x][y] = null # ... with null in the middle
			else:
				matrix[x][y] = gen_block(barrier,x,y) # ... with blocks to make a "visible barrier"
	pass

func grid_check(): # Validates that the block is in an empty position
	# Used to see if the movement is possible
	for m in range(4):
		for n in range(4):
			if matrix[piece_pos.x+m][piece_pos.y+n] && piece[n][m]:
				return false
	return true # Return true if the movement is possible
	pass

func gen_block(type,x,y): # Create a single block
	var b = type.instance()
	b.set_pos(x,y)
	add_child(b)
	return b
	pass

func gen_piece(): # Create the piece (with blocks)
	for x in range(4):
		for y in range(4):
			if b_ID.blocks[piece_shape][x][y]: # Using the script with all the shapes like a guide
				piece[x][y] = gen_block(block, y+piece_pos.x, x+piece_pos.y) # to fill the piece
	piece_shape = randi()%7 # Gen the number who represent the next piece shape
	emit_signal("next_piece", piece_shape) # Emit the signal to the HUD to use in "Piece Preview"
	pass

func set_piece(): # Put the piece in the grid
	for x in range(4):
		for y in range(4):
			if piece[x][y]:
				matrix[y+piece_pos.x][x+piece_pos.y] = piece[x][y]
	new_piece() # Create the next piece
	pass

func new_piece(): # Start to create a new piece in the top
	piece_pos = Vector2(7,-1) # Reset the position
	p_manager.clear_piece(piece) # Reset the piece (Filling in with 0 'zeros')
	gen_piece()
	pass

func rot_piece(): # Try rotate
	p_manager.try_rotate(matrix, piece, piece_pos.x, piece_pos.y) # Using a function from piece_management.gd
	att_piece() # Update the piece position
	# If the part is rotated, it is necessary to adjust the position of the blocks,
	# because they have changed their position in the piece matrix (The 'piece' variable in this script).
	pass

func move_piece(x,y): # Make all the movements (Vertical and Horizontal)
	piece_pos += Vector2(x,y)
	if grid_check(): # Verify the obstacles (Return true if the movement is possible)
		att_piece() # Update the piece position
		if piece_pos.y == 24: # 24 is the maximum line that the block arrives falling without obstacles
			set_piece() # If this happen, whe pute the piece in the grid
			match_pieces() # And verify if have a line filled
	else: # If for some reason, has an obstacle to the movement what he whants
		piece_pos -= Vector2(x,y) # Reset the pos to the original
		if piece_pos.y == -1: # If it collides and its position at y is -1, it means that it has not
							  # even left its initial position, that is, it has been stuck on top of
							  # a pile. And that in tetris, it means game over
			emit_signal("gameOver")
		elif y > 0: # And verify if that movement is a "fall", because, could be a collision with a block bellow him
			set_piece() # If this happen, whe pute the piece in the grid
			match_pieces() # And verify if have a line filled
	pass

func att_piece(): # Update the piece position
	for x in range(4):
		for y in range(4):
			if piece[x][y]:
				piece[x][y].set_pos(y+piece_pos.x,x+piece_pos.y)
	pass

func match_pieces(): # Verify if a line is filled
	var mult = 1 # A score multiplier
	for y in range(4,26):
		var line_del = true
		for x in range(4,14):
			if matrix[x][y] == null: # If i find a null position i cancel the proceed
				line_del = false
		if line_del: # In case the line is filled
			for x in range(4,14): 
				matrix[x][y].queue_free() # I destroy all the blocks
				matrix[x][y] = null # and put a empty space in grid
			emit_signal("lineDestroied",100*mult) # Emit a signal to compute the score
			mult += 1 # Up the score multiplier
			piece_fall(y) # And make the pieces fall (from the line that was removed 'y')
	pass

func piece_fall(line): # Make some pieces fall
	for y in range(line,0,-1): # Reading 'bottom to up' from the removed line 
		for x in range(4,14):
			if matrix[x][y]: # If i find a piece
				if matrix[x][y+1] == null: # I check if is empty below it
					matrix[x][y].global_position.y += 13 # And make the piece fall
					matrix[x][y+1] = matrix[x][y] # Change the position in the grid
					matrix[x][y] = null # And put a empity space in the past position 
	pass

func _on_timer_timeout(): # Timer to control the piece fall
	move_piece(0,1)
	timer.wait_time = interval
	timer.start()
	pass

func _on_HUD_move(dir):
	move_piece(dir,0)
	pass
func _on_HUD_rotate():
	rot_piece()
	pass
func _on_HUD_speedUP():
	interval = 0.1
	pass
func _on_HUD_speedDown():
	interval = 0.5
	pass
func _on_HUD_start():
	gen_piece()
	timer.start()
	pass
