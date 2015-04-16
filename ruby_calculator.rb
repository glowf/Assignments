def check_input(input)
  input_valid = !(input.count(".") > 1 || input.count(",") > 0)
  input_float = input.to_f != 0.0 || input.to_s == "0" || input.to_s == "0.0"
  input_valid && input_float
end

def check_operator(operator)
  %w(+ - * /).include? operator
end

def restart
  puts "\nDo you want to go again? y/n"
  answer = gets.chomp
  answer.downcase == "y"
end

def compute(numbers)
  puts "Choose an operator : +, -, *, /"
  operator = gets.chomp
  if check_operator(operator)
    if numbers.to_s.count(".") > 0 || operator == "/"
      numbers.map!(&:to_f)
    else
      numbers.map!(&:to_i)
    end
    result = numbers.inject(operator.to_sym)
    puts "##### Result is #{result} #####"
    start_calculator if restart
  else
    puts "Invalid Operator!"
    compute(numbers)
  end
end

def start_calculator
  question   = "Give me your first number:"
  numbers    = []
  max_inputs = 2

  system "clear"
  puts "\n-----------------------------"
  puts "------ RUBY CALCULATOR ------"
  puts "-----------------------------\n\n"

  loop do
    puts question
    answer = gets.chomp
    if check_input(answer)
      numbers << answer
      if numbers.size == max_inputs
        compute(numbers)
        break
      end
      question = "Give me your next number:"
    else
      puts "Oopps, that's not a valid input!"
    end
  end
end

start_calculator
