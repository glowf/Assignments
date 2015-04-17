def player_pick
  puts "-----------------------------"
  puts "   Rock, Paper or Scissors?  "
  puts "     CHOOSE ONE: R, P, S     "
  puts "-----------------------------"
  gets.chomp
end

def display_hand(choice,player)
  case choice
  when 'r'
    display_rock(player)
  when 'p'
    display_paper(player)
  when 's'
    display_scissors(player)
  end
end

def display_rock(player)
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

def display_paper(player)
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

def display_scissors(player)
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

def valid_answer?(options,answer)
  options.include? answer
end

def computer_pick(options)
  options.sample
end

def clear_screen
  system "clear"
end

def again?
  puts "Want to play again? y/n"
  gets.chomp.downcase == 'y'
end

def check_winner(user,computer)
  if user == computer
    'draw'
  elsif (user == 'r' && computer == 's') ||
        (user == 's' && computer == 'p') ||
        (user == 'p' && computer == 'r')
    'user'
  else
    'computer'
  end
end

def display_winner(winner)
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
  puts text
end

def rock_paper_scissors(clear = true)
  clear_screen if clear == true

  options        =  %w(r p s)
  answer_user    =  player_pick.downcase

  if valid_answer?(options,answer_user)
    answer_computer = computer_pick(options)
    winner = check_winner(answer_user, answer_computer)

    puts ""
    display_hand(answer_user, "You")
    display_hand(answer_computer, "Computer")
    display_winner(winner)
    puts ""

    rock_paper_scissors if again?
  else
    puts "Invalid choice."
    rock_paper_scissors(false)
  end
end

rock_paper_scissors
