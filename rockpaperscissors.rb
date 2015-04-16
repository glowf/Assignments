def ask
  puts "-----------------------------"
  puts "CHOOSE: rock, paper, scissors"
  puts "-----------------------------"
  answer = gets.chomp
end

def display_hand choice,player
  case choice
  when 0
    display_rock player
  when 1
    display_paper player
  when 2
    display_scissors player
  end
end

def display_rock player
  puts " #{player} chose: ROCK        "
  puts "        _______               "
  puts "    ---'   ____)              "
  puts "          (_____)             "
  puts "          (_____)             "
  puts "          (____)              "
  puts "    ---.__(___)               "
  puts "                              "
  puts "                              "
end

def display_paper player
  puts " #{player} chose: PAPER         "
  puts "        _______                 "
  puts "    ---'   ____)____            "
  puts "              ______)           "
  puts "              _______)          "
  puts "             _______)           "
  puts "    ---.__________)             "
  puts "                                "
  puts "                                "
end

def display_scissors player
  puts " #{player} chose: SCISSORS       "
  puts "        _______                  "
  puts "    ---'   ____)____             "
  puts "              ______)            "
  puts "           __________)           "
  puts "          (____)                 "
  puts "    ---.__(___)                  "
  puts "                                 "
  puts "                                 "
end

def valid_answer? options,answer
  options.include? answer
end

def computer_pick options
  options.sample
end

def clear_screen
  system "clear"
end

def again?
  puts "Want to play again? y/n"
  gets.chomp.downcase == 'y'
end

def check_winner user,computer
  if user == computer
    'draw'
  elsif user == 0 && computer == 2
    'user'
  elsif user > computer
    'user'
  else
    'computer'
  end
end

def display_winner winner
  text = ''
  case winner
  when 'user'
    text = 'Yey, you won! \(•◡•)/'
  when 'computer'
    text = 'Sorry, you lost! (ಥ﹏ಥ)'
  else
    text = 'It\'s a draw... (ಠ_ಠ)'
  end
  text = '••••••  ' + text + '  ••••••'
end

def rock_paper_scissors clear = 0
  clear_screen if clear == 0

  options        =  %w(rock paper scissors)
  answer_user    =  ask

  if valid_answer? options,answer_user
    answer_computer       = computer_pick options
    answer_user_index     = options.index(answer_user)
    answer_computer_index = options.index(answer_computer)

    puts ""
    display_hand answer_user_index,"You"
    display_hand answer_computer_index,"Computer"

    winner = check_winner answer_user_index , answer_computer_index
    puts display_winner winner
    puts ""

    rock_paper_scissors if again?
  else
    puts "Invalid choice."
    rock_paper_scissors 1
  end
end

rock_paper_scissors
