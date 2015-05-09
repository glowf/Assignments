class Player
  attr_reader :name, :hand

  def initialize(name)
    @name = name
  end

  def show_hand
    hand.display_hand
  end
end

class Human < Player
  def pick
    print "CHOOSE ONE: [#{Hand.show_options.upcase}] "
    value = gets.chomp.downcase
    Hand::OPTIONS.include?(value) ? @hand = Hand.new(value) : pick
  end
end

class Computer < Player
  def pick
    @hand = Hand.new(Hand::OPTIONS.sample)
  end
end

class Hand
  OPTIONS = ['r','p','s']

  attr_reader :value

  def initialize(value)
    @value = value
  end

  def ==(other_hand)
    self.value == other_hand.value
  end

  def >(other_hand)
    (self.value == get_rock && other_hand.value == get_scissors) ||
    (self.value == get_scissors && other_hand.value == get_paper) ||
    (self.value == get_paper && other_hand.value == get_rock)
  end

  def to_s
    case value
    when get_rock     then  "rock"
    when get_scissors then  "scissors"
    when get_paper    then  "paper"
    end
  end

  def self.show_options
    OPTIONS.join("/")
  end

  def get_rock
    OPTIONS[0]
  end

  def get_paper
    OPTIONS[1]
  end

  def get_scissors
    OPTIONS[2]
  end

  def display_hand
    case value
    when get_rock     then  display_rock
    when get_paper    then  display_paper
    when get_scissors then  display_scissors
    end
  end

  def display_rock
    puts "        _______               "
    puts "    ---'   ____)              "
    puts "          (_____)             "
    puts "          (_____)             "
    puts "          (____)              "
    puts "    ---.__(___)               "
    puts "                              "
    puts "                              "
  end

  def display_paper
    puts "        _______                 "
    puts "    ---'   ____)____            "
    puts "              ______)           "
    puts "              _______)          "
    puts "             _______)           "
    puts "    ---.__________)             "
    puts "                                "
    puts "                                "
  end

  def display_scissors
    puts "        _______                  "
    puts "    ---'   ____)____             "
    puts "              ______)            "
    puts "           __________)           "
    puts "          (____)                 "
    puts "    ---.__(___)                  "
    puts "                                 "
    puts "                                 "
  end
end

class Game
  attr_reader :human, :computer

  def initialize(human, computer)
    @human = human
    @computer = computer
  end

  def start
    display_title
    computer.pick
    human.pick

    display_title
    puts "#{human.name} chose #{human.hand}"
    human.show_hand
    puts "#{computer.name} chose #{computer.hand}"
    computer.show_hand

    display_winner(human.hand, computer.hand)

    again? ? start : display_bye
  end

  def display_winner(human_hand, computer_hand)
    if human_hand == computer_hand
      text = "It\'s a draw... (ಠ_ಠ)"
    elsif human_hand > computer_hand
      text = "Yey, #{human.name} won! \(•◡•)/"
    else
      text = "Sorry, #{human.name} lost! (ಥ﹏ಥ)"
    end
    puts "••••••  #{text} ••••••\n\n"
  end

  def again?
    print "Again? [Y/N] "
    answer = gets.chomp.downcase
    answer == 'y'
  end

  def display_bye
    puts "\nBye\n"
  end

  def display_title
    clear_screen
    puts "+-+-+-+-+ +-+-+-+-+-+ +-+-+-+-+-+-+-+-+"
    puts "|r|o|c|k| |p|a|p|e|r| |s|c|i|s|s|o|r|s|"
    puts "+-+-+-+-+ +-+-+-+-+-+ +-+-+-+-+-+-+-+-+"
    puts ""
  end

  def clear_screen
    system "clear"
  end
end

Game.new(Human.new("You"),Computer.new("Computer")).start
