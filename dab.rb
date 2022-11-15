#! /usr/bin/ruby
# frozen_string_literal: true

require_relative 'cli'
require 'json'

# Dab app
class Dab
  include CLI

  def self.run
    cli = Cli.new
    cli
      .add_arg(:help, 'help', 'h')
      .add_arg(:get, 'get', 'g')
      .add_arg(:sold, 'sold', 's')

    cli
      .add_description(:help, 'Show the list of all commands')
      .add_description(:get, 'Withdraw money to the distributor cli')
      .add_description(:sold, 'Show the sold of the user in Ariary')

    # cli.help_action
    # cli.sold_action
    if ARGV.empty?
      cli.help_action
    else
      case ARGV[0]
      when 'get', 'g'
        system 'clear'
        if ARGV[1] #  IF there is the out option for Withdrawing
          lang = JSON.parse(Dab.load_lang(Dab.choose_lang))
          sum_obj = Dab.load_and_parse_json('./data/sums.json')
          available_sums = sum_obj['available_sums']
          sums_choice = sum_obj['sums_choice']

          puts "\n\e[33m#{lang['amount_choice_phrase']} (Ariary)\e[0m"
          sums_choice.each_index do |i|
            puts "  #{i + 1}- #{sums_choice[i]} "
          end
          amount_index = Dab.choose_amount(sums_choice, lang)
          out_option = ARGV[1]
          case out_option
          when '--balanced'
            available_sums_total = Dab.get_sum(available_sums)
            sum = sums_choice[amount_index]
            result_amount = { '20000': sum / available_sums_total, '10000': sum / available_sums_total,
                              '5000': sum / available_sums_total }
            rest_result = Dab.get_minimum_result(sum % available_sums_total, sum % available_sums_total, available_sums)
            rest_result.each_pair do |k, v|
              result_amount[:"#{k}"] += v
            end
            Dab.print_result_amount(result_amount, lang)
          when '--minimum'
            sum = sums_choice[amount_index]
            rest = sum
            result_amount = Dab.get_minimum_result(sum, rest, available_sums)
            Dab.print_result_amount(result_amount, lang)
          else
            puts "\n\n\e[31m#{out_option}: #{lang['inappropriate_option']}\n\n"
            cli.help_action
          end
        else #  Else show the help
          cli.help_action
        end
      when 'sold', 's'
        cli.sold_action
      when 'help', 'h'
        cli.help_action
      else cli.help_action
      end
    end
  end

  def self.print_result_amount(result_amount, lang)
    result_amounts_string = String.new("\e[33m| #{lang['amount']}:\t")
    result_amount.each_pair do |k, v|
      result_amounts_string << " (#{v})#{k} Ar " if result_amount[:"#{k}"] || result_amount[k]
    end
    result_amounts_string << "|\e[m"
    hiphens = '-' * (result_amounts_string.length - 4)
    puts "\n \e[33m#{hiphens}\e[m"
    puts result_amounts_string
    puts " \e[33m#{hiphens}\e[m\n\n"
  end

  def self.get_sum(arr)
    sum = 0
    arr.each { |n| sum += n }
    sum
  end

  def self.get_minimum_result(sum, rest, available_sums)
    i = 0
    result_amount = {}
    while sum.positive? && rest.positive?
      i += 1 if available_sums[i] > sum
      result_amount[available_sums[i]] = sum / available_sums[i]
      rest = sum % available_sums[i]
      sum = rest
      i += 1
    end
    result_amount
  end

  def self.choose_lang
    lang = 0
    while lang < 1 || lang > 3
      system 'clear'
      puts "\e[33mChoose language:\e[0m\n  1- English\n  2- French\n  3- Malagasy"
      print "\e[33m>>> \e[m"
      lang = $stdin.gets.chomp.to_i
    end
    lang
  end

  def self.choose_amount(sums_choice, lang)
    amount_index = 0
    while amount_index < 1 || amount_index > sums_choice.length
      print "\e[33m>>> \e[m"
      amount_index = $stdin.gets.chomp.to_i
      if amount_index < 1 || amount_index > sums_choice.length
        puts "\e[31m>>> #{lang['choose_amount']} 1 - #{sums_choice.length}\e[m"
      end
    end
    amount_index if amount_index > sums_choice.length
    amount_index - 1
  end

  def self.load_lang(choice)
    case choice
    when 1 then File.read('./data/eng.json') #  English
    when 2 then File.read('./data/fr.json') # French
    when 3 then File.read('./data/mg.json') # Malagasy
    else 'Empty language'
    end
  end

  def self.load_and_parse_json(filename)
    JSON.parse(File.read(filename))
  end
end

Dab.run
