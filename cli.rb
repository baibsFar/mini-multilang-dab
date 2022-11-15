# frozen_string_literal: true

require 'json'

# CLI
module CLI
  # Cli
  class Cli
    attr_reader :args

    def initialize
      @args = {}
    end

    def add_arg(arg_name, *args)
      @args[arg_name] = { command: args }
      self
    end

    def add_description(arg_name, description)
      @args[arg_name][:description] = description unless @args[arg_name].empty?
      self
    end

    def help_action
      puts "\t\e[33mUsage:\e[0m\t ./dab.rb [COMMAND] [PARAM]"
      puts "\t\e[33mCommands:\e[0m"
      @args.each_key { |key| puts "\t\t#{@args[key][:command].join(', ')}\t\t: #{@args[key][:description]}" }
      puts "\t\e[33mParam:\e[0m"
      puts "\t\t--balanced or --minimum\t: Specify the type of amount"
      puts "\t\e[33mExample:\e[0m"
      puts "\t\t./dab.rb get --minimum\n\n"
    end

    def sold_action
      sold = JSON.parse(File.read('./data/sums.json'))['sold']
      output = "\e[33m| SOLD: \t#{sold} Ariary |\e[0m"
      hiphens = '-' * (output.length - 4)
      puts "\e[33m #{hiphens}\e[0m"
      puts output
      puts "\e[33m #{hiphens}\e[0m"
    end
  end
end
