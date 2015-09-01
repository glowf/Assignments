require 'colorize'

class Board
  attr_reader :rows, :cols, :wins, :board_cells, :winning_combinations

  def initialize(rows, cols, wins)
    @rows = rows
    @cols = cols
    @wins = wins
    @board_cells = initialize_board_cells(rows * cols)
    @winning_combinations = winning_combinations
  end

  def initialize_board_cells(total)
    cells =  (1..total).to_a
    cells.each_with_index do |value, index|
      cells[index] = Cell.new(value)
    end
  end

  def display_board
    puts ""
    puts "You'll need #{wins} to win".center(60)

    counter = 0
    spaces = ((11 - @cols) * 2.5)
    dashes = ("-" * @cols * 6)
    puts "\n" + " " *  spaces +  dashes
    rows.times do |x|
        print " " * spaces + "|"
        cols.times do |y|
           print "#{board_cell_value(counter)}".center(5).send(board_cell_color(counter))
        print "|"
        counter+=1
      end
      puts "\n" + " " * spaces +  dashes
    end
    puts "\n"
  end

  def board_cell_value(index)
    board_cells[index].value
  end

  def board_cell_color(index)
    board_cells[index].color
  end

  def cell_index(cell)
    cell - 1
  end

  def board_cells_values
    board_cells.map(&:value)
  end

  def mark_cell(cell, marker, color)
    cell = cell_index(cell)
    board_cells[cell].mark(marker,color)
  end

  def available?(cell)
    board_cells[cell_index(cell)].available?
  end

  def board_filled?
    sum = board_cells_values.map(&:to_i).reduce(:+)
    sum == 0
  end

  def match?(marker)
    match = winning_combinations.select do |combination|
     board_cells_values.values_at(*combination).count(marker) == @wins
    end
    match.length > 0
  end

  def empty_cells
    board_cells_values.select { |x| x.to_i > 0}
  end

  def winning_combinations
     array_rows = (0..rows*cols-1).each_slice(cols).to_a

     def columns_combinations(array_rows)
        array_cols = []
        array_rows.each_index {|i| array_cols.push(array_rows.collect { |r| r[i]}) }
        array_cols = wins < cols ? combinations(cols,array_cols) : array_cols
    end

    def rows_combinations(array_rows)
        array_rows = wins < rows ? combinations(rows,array_rows) : array_rows
    end

    def diagonal_combinations(array_rows)
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

      array_diagonal = combinations([cols,rows].max,array_diagonal)
      array_diagonal.delete(nil)
      array_diagonal.select! { |x| x.length>=wins}
    end

    def combinations(row_or_col,combination)
        combinations = []
        combination.each  do |combination|
          (row_or_col-wins+1).times do |x|
            range = x..(x+wins-1)
            combinations << combination[range]
          end
        end
        combinations
    end

    rows_combinations(array_rows) + columns_combinations(array_rows) + diagonal_combinations(array_rows)
  end

end


class Cell
  attr_accessor :value, :color

  def initialize(value,color="black")
    @value = value
    @color = color
  end

  def mark(marker, color)
    @value = marker
    @color = color
  end

  def available?
    @value.to_i >= 1
  end
end

class Player
  attr_reader :name, :marker, :color

  def initialize(name, marker, color)
    @name = name
    @marker = marker
    @color = color
  end
end

class Human < Player
  def select_position(args)
    loop do
       print "Select your position: "
       position = gets.chomp.to_i
       return position if args[:empty_cells].include?(position)
       print "Sorry, position ##{position} is already taken or invalid.\n".red
    end
  end
end

class Computer < Player

  def select_position(args)
    @empty_cells = args[:empty_cells]
    puts "Computer choosing..."
    sleep 0.3
    best_position(args[:values], args[:combinations], args[:opponents_marker], args[:wins]-1)
  end

  def random_position
    @empty_cells.sample
  end

  def best_position(board_values, winning_combinations, marker_opponent, num_consecutive)

    win_pos, block_pos, best_pos = [],[],[]

    winning_combinations.each do |combination|
      num_opponent_markers =  board_values.values_at(*combination).count(marker_opponent)
      num_my_markers       =  board_values.values_at(*combination).count(self.marker)
      sum_board_values     =  board_values.values_at(*combination).map(&:to_i).reduce(:+)

      if (num_my_markers  == num_consecutive) && (sum_board_values > 0)
         win_pos << combination
      end
      if (num_opponent_markers == num_consecutive) && (sum_board_values > 0)
         block_pos << combination
      end
      if (num_my_markers>=1) && (num_opponent_markers == 0)
         best_pos << combination
      end
    end

    possible_pos  = if !win_pos.empty?
                      win_pos.first.flatten
                    elsif !block_pos.empty?
                      block_pos.first.flatten
                    elsif !best_pos.empty?
                      best_pos.first.flatten
                    end

    if possible_pos != nil
      possible_pos = possible_pos - (possible_pos - @empty_cells.collect { |x| x-1})

      possible_pos[0]+1

    else
      random_position
    end
  end
end


class Game
  attr_reader :board, :human, :computer, :board

  def initialize(player1, player2)
    @player1 = player1
    @player2 = player2
  end

  def display_title
    puts " ____  ____  ___    ____   __    ___    ____  _____  ____ "
    puts "(_  _)(_  _)/ __)  (_  _) /__\\  / __)  (_  _)(  _  )( ___)"
    puts "  )(   _)(_( (__     )(  /(__)\\( (__     )(   )(_)(  )__)"
    puts " (__) (____)\\___)   (__)(__)(__)\\___)   (__) (_____)(____)"
    puts ""
  end

  def clear_screen
    system "clear"
  end

  def update_screen
    clear_screen
    display_title
    @board.display_board
  end

  def settings
    cols,rows,win = 0
    loop do
      print "How many columns: "
      cols = gets.chomp.to_i
      break if cols > 2
      puts "Must be greater than 2".red
    end
    loop do
      print "How many rows: "
      rows = gets.chomp.to_i
      break if rows > 2
      puts "Must be greater than 2".red
    end
    loop do
      print "How many to win: "
      win = gets.chomp.to_i
      break if win <= [cols,rows].min && win > 2
      puts "Must be equal or less than #{[cols,rows].min} but greater than 2".red
    end
    return cols,rows,win
  end

  def place_marker(player)
    position = player.select_position({
           empty_cells: @board.empty_cells,
           values: @board.board_cells_values,
           combinations: @board.winning_combinations,
           wins: @board.wins,
           opponents_marker: switch_player(player).marker
    })
    @board.mark_cell(position, player.marker, player.color)
  end

  def switch_player(player)
    if player.name == @player1.name
      @player2
    else
      @player1
    end
  end

  def winner(name=nil)
    if name == nil
      "It's a Tie"
    else
      "#{name} wins!!"
    end
  end

  def again?
    print "Want to play again? [Y/N] : "
    answer = gets.chomp.upcase
    true if answer != 'N'
  end

  def start
    clear_screen
    display_title
    cols,rows,win = settings
    @board = Board.new(cols,rows,win)
    current_player = @player1
    update_screen

    loop do
       place_marker(current_player)
       update_screen

       if @board.match?(current_player.marker)
          puts  "#{winner(current_player.name)}\n\n".center(60)
          break
       elsif @board.board_filled?
          puts  "#{winner}\n\n"
          break
       end
       current_player = switch_player(current_player)
    end

    start if again?
  end
end

Game.new(Human.new("Human", "X", "green"),Computer.new("Computer", "O", "blue")).start
