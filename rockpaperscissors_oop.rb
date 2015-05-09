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
    value == other_hand.value
  end

  def >(other_hand)
    (isRock?     && other_hand.isScissors?) ||
    (isScissors? && other_hand.isPaper?)    ||
    (isPaper?    && other_hand.isRock?)
  end

  def to_s
    case value
    when rock     then  "rock"
    when scissors then  "scissors"
    when paper    then  "paper"
    end
  end

  def self.show_options
    OPTIONS.join("/")
  end

  def isRock?
    value == rock
  end

  def isScissors?
    value == scissors
  end

  def isPaper?
    value == paper
  end

  def rock
    OPTIONS[0]
  end

  def paper
    OPTIONS[1]
  end

  def scissors
    OPTIONS[2]
  end

  def display_hand
    case value
    when rock     then  display_rock
    when scissors then  display_scissors
    when paper    then  display_paper
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

  def initialize
    @human    = Human.new("You")
    @computer = Computer.new("Computer")
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
    display_winner

    again? ? start : display_bye
  end

  def display_winner
    text = if human.hand == computer.hand
             "It\'s a draw... (ಠ_ಠ)"
          elsif human.hand > computer.hand
             "Yey, #{human.name} won! \(•◡•)/"
          else
            "Sorry, #{human.name} lost! (ಥ﹏ಥ)"
          end
    puts "•••••• #{text} ••••••\n\n"
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

Game.new.start
