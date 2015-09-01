require 'colorize'

class Deck
  attr_reader :cards

  def initialize
    @cards = []
    build_deck
  end

  def build_deck
     suits = ['d','h','s','c']
     cards_default = (('2'..'10').to_a + ['J','Q','K','A']).product(suits)

     cards_default.each  do |card|
       color,value,suit = "black",card[0],card[1]

       color = "red" if suit == "d" || suit == "h"

       value = if value == 'A'
                 1
               elsif value.to_i > 0
                 value.to_i
               else
                  10
               end
       cards << Card.new(card[0],suit,value,color)
      end
   end

  def deal
    cards.pop
  end

  def size
    cards.size
  end

  def shuffle_deck!
    cards.shuffle!
  end

  def reshuffle
    cards = []
    build_deck
  end
end

class Card
  attr_reader :facevalue, :suit, :value, :color

  def initialize(facevalue, suit, value, color)
    @facevalue = facevalue
    @suit      = suit
    @value     = value
    @color     = color
  end

  def graphic(hide="false")
    line1, line2, line3, line4, line5, line6 = "", "", "", "", "", ""
    cardsuit = self.suit
    cardsuit = 'e' if hide == true      #hide second dealer card
    fv = self.facevalue.center(2)

    case cardsuit
    when 'd'
      line2 += "|" + " #{fv} /\\  ".send(color) + "  | "
      line3 += "|" + "   /  \\  ".send(color) + " | "
      line4 += "|" + "   \\  /  ".send(color) + " | "
      line5 += "|" + "    \\/  #{fv}".send(color) + "| "
    when 'h'
      line2 += "|" + " #{fv}_  _ ".send(color) + "  | "
      line3 += "|" + "  ( \\/ ) ".send(color) + " | "
      line4 += "|" + "   \\  /  ".send(color) + " | "
      line5 += "|" + "    \\/ #{fv} ".send(color) + "| "
    when 's'
      line2 += "| #{fv} .     | "
      line3 += "|   / \\    | "
      line4 += "|  (_,_)   | "
      line5 += "|    I  #{fv} | "
    when 'c'
      line2 += "| #{fv} _     | "
      line3 += "|   ( )    | "
      line4 += "|  (_x_)   | "
      line5 += "|    Y  #{fv} | "
    when 'e'
      line2 += "| ?        | "
      line3 += "|          | "
      line4 += "|          | "
      line5 += "|        ? | "
    end
    line1 += ".----------. "
    line6 += "^----------^ "
    return line1 , line2, line3, line4, line5, line6
  end
end

class Player
  attr_reader :name,  :hand

  def initialize(name)
    @name  = name
    @hand  = Hand.new()
  end

  def hand_reset
    hand.hand=([])
  end

  def hand_contents
    hand.cards
  end

  def hand_size
    hand.size
  end

  def hand_total
    hand.total
  end

  def hand_display(hide=false)
    hand.draw_graphics(hide)
  end

  def hit(card)
    hand.add_card(card)
  end
end

class Dealer < Player
  HIT_REQUIREMENT = 17
end

class Human < Player
  attr_reader :hand
  attr_accessor :bet, :money

  def initialize(name, money=500, bet=100)
    super(name)
    @money = money
    @bet = bet
  end

  def deduct_bet
    @money-=bet
  end

  def add_bet(multiplier=1)
    @money+=(bet*multiplier)
  end

  def bankrupt?
    money == 0
  end

  def move
    loop do
      print "Do you want to Hit or Stay? [H/S]"
      move = gets.chomp.upcase
      return move if move == 'H' || move == 'S'
      puts "Invalid Choice".red
    end
  end
end

class Hand
  attr_accessor :hand

  def initialize
    @hand = []
  end

  def add_card(card)
    hand << card
  end

  def size
    hand.size
  end

  def card_values
    hand.map(&:value)
  end

  def card_facevalues
    hand.map(&:facevalue)
  end

  def card_value
    hand.value
  end

  def total
    sum = card_values.inject(0, :+)
    if card_facevalues.include?('A')
      if sum-1 <= 10
        sum = sum + 10 #count one ace as 11
      else
        sum
      end
    else
     sum
    end
  end

  def cards
     hand.map {|x| x}
  end

  def draw_graphics(hide=false)
    graphics = []
    hand.each_with_index do |card, index|
      if hide == true && index == 1
        graphics << card.graphic(true)
      else
        graphics << card.graphic
      end
    end
    lines_total = graphics[0].size
    counter = 0
    loop do
      puts (graphics.collect { |line| line[counter]}).join("")
      lines_total-=1
      counter+=1
      break if lines_total < 0
     end
  end
end

class Game
  BLACKJACK = 21

  attr_reader :deck, :player, :dealer

  def initialize
    @deck   = Deck.new
    @dealer = Dealer.new("Dealer")
    @player = Human.new(get_name,500)
    start
  end

  def title
     " _     _            _    _            _             " + "\n" +
     "| |   | |          | |  (_)          | |            " + "\n" +
     "| |__ | | __ _  ___| | ___  __ _  ___| | __         " + "\n" +
     "| '_ \\| |/ _` |/ __| |/ / |/ _` |/ __| |/ /        " + "\n" +
     "| |_) | | (_| | (__|   <| | (_| | (__|   <          " + "\n" +
     "|_.__/|_|\\__,_|\\___|_|\\_\\ |\\__,_|\\___|_|\\_\\ " + "\n" +
     "                       _/ |                         " + "\n" +
     "                      |__/                          " + "\n"
  end

  def clear_screen
    system "clear"
  end

  def draw_table(hide=false)
    clear_screen
    dealer_hand_total = dealer.hand_total.to_s
    dealer_hand_total = "?" if hide == true
    puts title
    puts "Total Money:" + " $#{player.money}".green
    puts
    puts "Dealer's Hand: #{dealer_hand_total}"
    dealer.hand_display(hide)
    puts "#{player.name}'s hand: #{player.hand_total}        Bet: $#{player.bet}"
    player.hand_display
  end

  def initial_cards
    player.hit(deck.deal)
    player.hit(deck.deal)
    dealer.hit(deck.deal)
    dealer.hit(deck.deal)
  end

  def get_bet
    loop do
       print "What's your bet? $"
       bet = gets.chomp.to_i
       return bet if bet > 0 && bet <= player.money
       puts "Invalid bet.".red
    end
  end

  def get_name
    clear_screen
    puts title
    puts
    loop do
       print "Hi, what's your name? "
       name = gets.chomp.capitalize
       return name if name.length > 0
       puts "Invalid name".red
    end
  end

  def players_move
    loop do
       choice = player.move
       break if choice == 'S'
       player.hit(deck.deal)
       draw_table(true)
       if player.hand_total >= BLACKJACK
         break
       end
     end
  end

  def dealers_move
    while dealer.hand_total < Dealer::HIT_REQUIREMENT do
      dealer.hit(deck.deal)
      sleep 0.5
      puts "Dealer hits"
      draw_table
      if dealer.hand_total > BLACKJACK
        break
      end
    end
  end

  def discard_hand
    player.hand_reset
    dealer.hand_reset
  end

  def get_winner
    dealer_total = dealer.hand_total
    player_total = player.hand_total

    if !(dealer_total > BLACKJACK)
        if player_total == dealer_total
          "push"
        elsif player_total > dealer_total
          "player"
        else
          "dealer"
        end
    else
       "player"
    end
  end

  def reshuffle?
    deck.size < 20 #random number i chose to prevent from running out of cards
  end

  def again?
      print "Do you want to play again? [Y/N] "
      answer = gets.chomp.upcase
      true if answer != 'N'
  end

  def start
       clear_screen
       puts title
       discard_hand

       if reshuffle?
         deck.reshuffle
         puts
         puts "Please wait while I reshuffle the cards..."
         sleep 0.3
       end

       puts "#{player.name} you have " + "$#{player.money}".green
       puts
       player.bet=(get_bet)
       player.deduct_bet
       deck.shuffle_deck!

       initial_cards
       draw_table(true)
       players_move if player.hand_total != BLACKJACK
       draw_table #player done, now don't hide dealers cards
       if player.hand_total <= BLACKJACK
           dealers_move

           message = case get_winner
                     when "player"
                       player.add_bet(2)
                       "#{player.name} you win $#{player.bet}! ٩(^‿^)۶".green
                     when "dealer"
                       "#{dealer.name} wins, sorry! (╥﹏╥)".red
                     when "push"
                       player.add_bet
                       "Push. You get your $#{player.bet} back. (ಠ_ಠ)".blue
                     end
           draw_table
           sleep 0.3
           puts message
           puts
       else
          draw_table(true)
          puts "Bust! You lost $#{player.bet}. (╥﹏╥) \n".red
       end

       if !player.bankrupt?
          if again?
            start
          else
            clear_screen
            puts title
            puts "\n Thank you for playing #{player.name} ٩(^‿^)۶ \n".blue
          end
       else
         puts "Sorry you'r bankrupt! (╥﹏╥)".red
       end
  end
end

Game.new
