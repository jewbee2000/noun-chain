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

redis = Redis.new

csv_file = ARGV.shift
ts = Time.now.to_i.to_s
redis.set("src:#{ts}", csv_file)

CSV.foreach(csv_file, headers: true) do |row|
  next if options[:bool] and row.fields.last != "TRUE"
  compound = normalized_compound(row[1], row[2])
  redis.sadd(SET_NAME, compound)
  redis.hset(compound, :freq, 1, :src, '')

end

