require 'colorize'

def get_player_marker
  "X".center(5).blue
end

def get_computer_marker
  "O".center(5).magenta
end

def display_title
  puts " ____  ____  ___    ____   __    ___    ____  _____  ____ "
  puts "(_  _)(_  _)/ __)  (_  _) /__\\  / __)  (_  _)(  _  )( ___)"
  puts "  )(   _)(_( (__     )(  /(__)\\( (__     )(   )(_)(  )__)"
  puts " (__) (____)\\___)   (__)(__)(__)\\___)   (__) (_____)(____)"
end

def clear_screen
  system "clear"
end

def display_winner(winner)
  case winner
  when get_computer_marker
    puts "~~~~ Sorry, you lost (✖╭╮✖) ~~~~ ".red.center(55)
  when get_player_marker
    puts "~~~~ You won! \\(•◡•)/ ~~~~ ".green.center(55)
  else
    puts "~~~~ It's a tie (ಠ_ಠ) ~~~~ ".center(42)
  end
  puts ""
end

def display_board(board,rows,cols,win,winning_combination=[])
  display_title
  puts "\n You need #{win} to win"
  counter = 0
  puts "\n" + " " * 8 +  ("-" * cols * 6)
  rows.times do |x|
    print " " * 7 + "|"
    cols.times do |y|
      if winning_combination.flatten.include?(counter)
        print "#{board[counter]}".blink #blink winning slots
      else
        print "#{board[counter]}".center(5)
      end
      print "|"
      counter+=1
    end
    puts "\n" + " " * 8 +  ("-" * cols * 6)
  end
  puts "\n"
end

def get_grid_settings
  clear_screen
  display_title
  puts "\n\n"
  puts "Let's customize your grid".center(40).blue
  puts "\n\n"
  def get_rows(error=false)
    print "Invalid. ".red if error == true
    print "How many rows [3-10]: "
    rows = gets.chomp.to_i
    return rows if rows.between?(3,10)
    get_rows(true)
  end

  def get_cols(error=false)
    print "Invalid. ".red if error == true
    print "How many columns [3-10]: "
    cols = gets.chomp.to_i
    return cols if cols.between?(3,10)
    get_cols(true)
  end

  def get_wins(min,error=false)
    print "Invalid. ".red if error == true
    print "How many to win [3-#{min}]: "
    wins = gets.chomp.to_i
    return wins if wins.between?(3,min)
    get_wins(min,true)
  end

  rows = get_rows
  cols = get_cols
  win  = [rows,cols].min > 3 ? get_wins([rows,cols].min) : 3
  return rows,cols,win
end

def generate_winning_combinations(board,rows,cols,win)
  winning_combinations, array_cols, array_rows,
  array_cols_combination, array_diagonals_combination = []

  def get_columns(board,rows,cols,win)
    counter    = 0
    array_cols = []
    cols.times do |x|
      counter = x
      combination = []
      (rows-1).times do |y|
        counter+=cols
        combination.push(x).push(counter)
      end
      array_cols << combination.uniq!
    end
    array_cols
  end

  def get_rows(board,rows,cols,win)
    counter    = 0
    array_rows = []
    rows.times do |x|
      counter = counter+cols
      counter = 0 if x == 0
      combination = []
      cols.times do |y|
        combination.push(counter).push(counter+y)
      end
      array_rows << combination.uniq!
    end
    array_rows
  end

  def get_diagonals(board,rows,cols,win,array_rows)
    array_diagonal = []
    array_rows.each_with_index do |y,index_y|
      y.each_with_index do |x,index_x|
        diagonal_right = []
        diagonal_left = []
        rows.times do |counter|
          row_num       = index_y + counter
          col_num_right = index_x + counter
          col_num_left  = index_x - counter
          if array_rows[row_num] != nil
             diagonal_right << array_rows[row_num][col_num_right]if array_rows[row_num][col_num_right ] != nil
             diagonal_left  << array_rows[row_num][col_num_left] if array_rows[row_num][col_num_left] != nil && col_num_left>=0
          end
        end
        array_diagonal.push(diagonal_right).push(diagonal_left)
      end
    end
    array_diagonal.select { |x| x.length>=win}
  end

  # required number to win may not equal the number of cols
  # and rows so we produce all possible combinations
  def get_combinations(row_or_col,win,combination)
      combinations = []
      combination.each  do |combination|
        (row_or_col-win+1).times do |x|
          range = x..(x+win-1)
          combinations << combination[range]
        end
      end
      combinations
  end

  array_cols      = get_columns(board,rows,cols,win)
  array_rows      = get_rows(board,rows,cols,win)
  array_diagonals = get_combinations([cols,rows].max,win,get_diagonals(board,rows,cols,win,array_rows))
  array_diagonals.delete(nil)

  array_cols_combination = win < rows ? get_combinations(rows,win,array_cols) : array_cols
  array_rows_combination = win < cols ? get_combinations(cols,win,array_rows) : array_rows
  array_diagonals_combination = array_diagonals.select { |x| x.length >= win}

  winning_combinations  = array_cols_combination +
                          array_rows_combination +
                          array_diagonals_combination
end

def get_winning_combination(board,winning_combinations,win,marker)
  match = winning_combinations.select do |combination|
     board.values_at(*combination).count(marker) == win
  end
end

def pick_valid?(board,pick)
  board.include?(pick.to_i)
end

def board_filled?(board)
  sum = board.map(&:to_i).reduce(:+)
  sum == 0
end

def player_pick_slot(board,error = false)
  print "Invalid choice, try again. ".red if error == true
  print "Your turn:  "
  answer = gets.chomp
  return answer.to_i if pick_valid?(board,answer.to_i)
  player_pick_slot(board,true)
end

def computer_pick_slot(board,winning_combinations,win)
  def find_block_win(board,winning_combinations,marker,num_consecutive)
    winning_combinations.select do |combination|
      board.values_at(*combination).count(marker) == num_consecutive &&
      board.values_at(*combination).map(&:to_i).reduce(:+)>0
    end
  end

  def find_best_move(board,winning_combinations,win)
    winning_combinations.select do |combination|
      board.values_at(*combination).count(get_computer_marker) >=1 &&
       board.values_at(*combination).count(get_player_marker) == 0
    end
  end

  def find_random_move(board)
    available = board.select { |x| x.to_i > 0}
    available.sample
  end

  win_combination     = find_block_win(board, winning_combinations, get_computer_marker,win-1)
  block_combination   = find_block_win(board, winning_combinations, get_player_marker,win-1)
  best_combination    = find_best_move(board, winning_combinations, win)

  if !win_combination.empty? || !block_combination.empty?
     possible_moves = (win_combination.shuffle + block_combination.shuffle).flatten!
     possible_moves = board.values_at(*possible_moves)
     possible_moves.delete(get_computer_marker)
     possible_moves.delete(get_player_marker)
     possible_moves.first #if there's a winning move, that comes first in the array
  elsif !best_combination.empty?
     possible_moves = board.values_at(*best_combination.flatten!)
     possible_moves.delete(get_computer_marker)
     possible_moves.delete(get_player_marker)
     possible_moves.sample
  else
     find_random_move(board)
  end
end

def tictactoe
  rows,cols,win        =  get_grid_settings
  total                =  rows * cols
  board                =  (1..total).to_a
  winning_combinations =  generate_winning_combinations(board,rows,cols,win)

  clear_screen
  display_board(board,rows,cols,win)
  player_current = get_player_marker

  loop do
    pick = if player_current == get_player_marker
              player_pick_slot(board)
           else
              puts "Computer is choosing..."
              sleep 0.3
              computer_pick_slot(board,winning_combinations,win)
           end

    board[pick-1] = player_current
    winning_combination = get_winning_combination(board,winning_combinations,win,player_current)
    clear_screen
    display_board(board,rows,cols,win,winning_combination)

    if board_filled?(board)
        display_winner('tie')
        break
    elsif !winning_combination.empty?
        display_winner(player_current)
        break
    end
    player_current = player_current == get_player_marker ? get_computer_marker : get_player_marker
  end
end

tictactoe
