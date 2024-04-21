require 'csv'
require 'optparse'
require "redis"

SET_NAME = "wordchain-dict"

options = {}

# Returns the compound noun of two normalized nouns                                                                                                                                               
def normalized_compound(n1, n2)                                                                                                                                                                   
  "#{n1} #{n2}".downcase                                                                                                                                                                          
end

OptionParser.new do |opts|

  opts.banner = "Usage: cvs2redis.rb [options]"

  opts.on("-b", "--bool", "Respect boolean at end of CSV line") do |v|
    options[:bool] = v
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!

csv_file = ARGV.shift
redis = Redis.new

CSV.foreach(csv_file, headers: true) do |row|
  next if options[:bool] and row.fields.last != "TRUE"
  compound = normalized_compound(row[1], row[2])
  redis.sadd(SET_NAME, compound)
end

