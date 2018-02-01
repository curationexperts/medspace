# frozen_string_literal: true
namespace :import do
  desc "Import data from Medspace export"
  task medspace: :environment do
    import_data
    exit 0 # Make sure extra args aren't misinterpreted as rake task args
  end

  # helpers
  def import_data
    options = options(ARGV)
    puts "Importing records using options: #{options}"
    Medspace::Importer.import(options[:input_file], options[:data_path])
    puts "Import complete"
  end

  # Read the options that the user supplied on the command line.

  def options(args)
    require 'optparse'
    user_inputs = {}
    opts = OptionParser.new

    opts.on('-i INPUT FILE', '--input_file', '(required) The XML file containing the Medspace records you want to import') do |input_file|
      user_inputs[:input_file] = input_file
    end

    opts.on('-d DATA PATH', '--data_path', '(required) The path to the directory where the collection folders are stored') do |data_path|
      user_inputs[:data_path] = data_path
    end

    opts.on('-h', '--help', 'Print this help message') do
      puts opts
      exit 0
    end

    args = opts.order!(ARGV) {}
    opts.parse!(args)

    required_options = [:input_file, :data_path]
    missing_options = required_options - user_inputs.keys
    missing_options.each { |o| puts "Error: Missing required option: --#{o}" }

    # If any required options are missing, print the usage message and abort.
    if !missing_options.blank?
      puts ""
      puts opts
      exit 1
    end

    user_inputs
  end
end
