require 'json'

valid_words = File.open('/usr/share/dict/words', 'r').read.split("\n")

def extract_features(base_path = 'texts_by_valence', low_or_high='low', filename='AA2018-02-26', valid_words)
  r = File.open([base_path, low_or_high, filename].join('/'), 'r').read
  r = r.split(' ')
  r = r.map(&:downcase)
  r = r.map {|r| r.gsub('<', '')}
  r = r.map {|r| r.gsub('>', '')}
  r = r.map {|r| r.downcase}
  h = {}
  r.each do |item|
    h[item] ||= 0
    h[item] += 1
  end
  h.keys.each {|qq| h.delete(qq) unless valid_words.include? qq}
  File.open("features_by_valence/#{low_or_high}/#{filename}", 'w+') do |file|
    file.write h.to_json
  end
end

paths = Dir.glob('texts_by_valence/*/*')

paths.each_with_index do |path, i|
  p "#{path} --- (#{i + 1}/#{paths.count})"
  ar = path.split('/')
  base_path = ar[0]
  low_or_high = ar[1]
  filename = ar[2]
  extract_features(base_path, low_or_high, filename, valid_words)
end
