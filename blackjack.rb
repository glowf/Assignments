require 'colorize'

def clear_screen
  system "clear"
end

def draw_title
  puts " _     _            _    _            _            "
  puts "| |   | |          | |  (_)          | |           "
  puts "| |__ | | __ _  ___| | ___  __ _  ___| | __        "
  puts "| '_ \\| |/ _` |/ __| |/ / |/ _` |/ __| |/ /       "
  puts "| |_) | | (_| | (__|   <| | (_| | (__|   <         "
  puts "|_.__/|_|\\__,_|\\___|_|\\_\\ |\\__,_|\\___|_|\\_\\"
  puts "                       _/ |                "
  puts "                      |__/                 "
end

def draw_cards(cards, hide)
  line1, line2, line3, line4, line5, line6 = "", "", "", "", "", ""
  cards.each_with_index do |card, index|
    card_suit = card[1]
    card_suit = 'e' if index == 1 && hide == true                               #hide second dealer card
    line1 += ".----------. "
    line6 += "^----------^ "
    case card_suit
    when 'd'
      line2 += "| #{card[0].center(2)} /\\    | "
      line3 += "|   /  \\   | "
      line4 += "|   \\  /   | "
      line5 += "|    \\/  #{card[0].center(2)}| "
    when 'h'
      line2 += "| #{card[0].center(2)}_  _   | "
      line3 += "|  ( \\/ )  | "
      line4 += "|   \\  /   | "
      line5 += "|    \\/ #{card[0].center(2)} | "
    when 's'
      line2 += "| #{card[0].center(2)} .     | "
      line3 += "|   / \\    | "
      line4 += "|  (_,_)   | "
      line5 += "|    I  #{card[0].center(2)} | "
    when 'c'
      line2 += "| #{card[0].center(2)} _     | "
      line3 += "|   ( )    | "
      line4 += "|  (_x_)   | "
      line5 += "|    Y  #{card[0].center(2)} | "
    when 'e'
      line2 += "| ?        | "
      line3 += "|          | "
      line4 += "|          | "
      line5 += "|        ? | "
    end
  end
  puts line1, line2, line3, line4, line5, line6
end

def display_table(money, bet, name, dealer_cards, player_cards,
                  total_player, total_dealer = 0, hide_dealer_cards = true)
  clear_screen
  draw_title
  puts "\nMoney Left: $" + money.to_s.green + "    Current bet  : " + "$".red + bet.to_s.red + "\n\n"
  if total_dealer > 0
    puts "Dealer's Cards : " + total_dealer.to_s.blue
  else
    puts "Dealer's Cards : ?"
  end
  draw_cards(dealer_cards, hide_dealer_cards)
  puts "\n#{name.capitalize}'s Cards : " + total_player.to_s.blue
  draw_cards(player_cards, false)
  puts "\n"
end

def add_cards(cards)
  total = 0
  card_values = cards.map do |card|
                  if card[0].match(/[[:alpha:]]/) && card[0] != 'A'
                    '10'
                  else
                    card[0]
                  end
                end

  card_values.sort.each_with_index do |card, index|                             #sort is important because this puts all As at the end of the array
    if card  == 'A'
      if cards[index+1] == 'A'                                                  #force the first A to have value of 1 if next card is an A
        total += 1
      else
       if (total + 11) <= 21 then
         total += 11
       else
         total += 1
       end
      end
    else
       total += card.to_i
    end
  end

  total
end

def get_name
  print "\n\nWhat's your name? "
  name = gets.chomp
  name.length > 0 ? name : get_name
end

def get_bet(money, name, error = false)
  puts ""
  print "Invalid amount \n".red if error == true
  print "Hi #{name.capitalize}, you currently have $#{money}. \nPlace your bet: $"
  bet = gets.chomp.to_i
  if bet <= money && bet > 0
    bet
  else
    get_bet(money, name, true)
  end
end

def get_player_move
  print "Hit or Stay? [H/S] "
  move = gets.chomp.downcase
  case move
  when 'h'then 'hit'
  when 's'then 'stay'
  else  get_player_move
  end
end

def build_deck
  suits = ['d','h','s','c']
  card_values = ('2'..'10').to_a + ['J','Q','K','A']
  deck = card_values.product(suits)
end

def shuffle_deck
  build_deck.shuffle
end

def play_again
  print "\nPlay again? [Y/N] : "
  gets.chomp.downcase
end

def dealer_move(deck, money, bet, name, dealer_cards, player_cards,
                hide_dealer_cards = true, hit = false)
   dealer_cards.push(deck.pop) if hit == true
   sleep 1.2
   total_dealer = add_cards(dealer_cards)
   total_player = add_cards(player_cards)
   display_table(money, bet, name, dealer_cards, player_cards, total_player, total_dealer, false)

   if total_dealer < 17
     puts "Dealer hits"
     dealer_move(deck, money, bet, name, dealer_cards, player_cards, false, true)
   elsif  total_dealer <= 21
    move = 'stay'
   else
    move = 'bust'
   end
end

def player_move(deck, money, bet, name, dealer_cards, player_cards, hit = false)
  player_cards.push(deck.pop) if hit == true
  total_player = add_cards(player_cards)
  display_table(money, bet, name, dealer_cards, player_cards, total_player)

  if total_player < 21
    move = get_player_move
    if move == 'hit'
      player_move(deck, money, bet, name, dealer_cards, player_cards, true)
    else
      move = 'stay'
    end
  elsif total_player == 21 then move = 'stay'
  else move = 'bust'
  end
end

def blackjack(again = false, name = '', money = 500, deck = shuffle_deck)
  player_cards = []
  dealer_cards = []
  move         = ''
  total        = 0
  bet          = 0
  message      = 0

  clear_screen
  draw_title

  name = get_name if again == false
  bet = get_bet(money, name)
  money -= bet

  if deck.length <= 26
    deck = shuffle_deck
    puts "\nDeck has been shuffled."
    sleep 1.2
  end

  dealer_cards.push(deck.pop,deck.pop)
  player_cards.push(deck.pop,deck.pop)

  result_player = player_move(deck, money, bet, name, dealer_cards, player_cards)

  if result_player == 'stay'
    result_dealer = dealer_move(deck, money, bet, name, dealer_cards, player_cards, false)

    if  result_dealer == 'bust'
      message = "Dealer busts! You win $#{bet}!"
      money += bet * 2
    else
      total_player = add_cards(player_cards)
      total_dealer = add_cards(dealer_cards)

      if total_player > total_dealer
        message = "You win $#{bet} ٩(^‿^)۶"
        money += bet * 2
      elsif total_player < total_dealer
        message = "Dealer Wins. You lose $#{bet} (╥﹏╥)"
      else
        message = "It's a tite (ಠ_ಠ)"
        money += bet
      end
    end

  elsif result_player == 'bust'
    message = "Bust! You lose $#{bet}"
  end

  sleep 0.5
  puts "-=" * (message.length/2)
  puts message
  puts "-=" * (message.length/2)
  sleep 0.5
  puts "\nYour current balance is $#{money}. "

  if money == 0
    puts "Sorry #{name}, you have no money left.\n\n"
  else
    continue = play_again
    case continue
    when 'y'
      blackjack(true, name, money, deck)
    else
      clear_screen
      draw_title
      puts "\n\n"
      puts "Thanks for playing #{name}!".center(40)
      puts "\n\n"
    end
  end
end

blackjack
