# require 'digest'
# require 'fileutils'

# class CachedMechanize
#   def initialize(agent=default_agent, opts={})
#     @agent = agent
#     @base_path = opts.fetch(:base_path, default_base_path)
#     @argument_history = []
#   end

#   def self.test
#     c = CachedMechanize.new
#     page = c.get('https://reddit.com')
#     page.css('p').first(2).map(&:text)
#   end

#   def method_missing(m, *args, &block)
#     @argument_history.push m
#     @argument_history.push cached_params(*args)
#     # Check if folder named current_filepath exists
#     file_contents = JSON.parse(File.open(current_filepath_json, 'r').read()) rescue nil

#     if file_contents
#     # If so, read from folder
#       return file_contents
#     else # If not: 
#       # byebug if m.to_sym == :text
#       if !File.directory?(current_filepath)
#         # Response = Send message to @agent
#         response = @agent.send(m, *args)
#         if response.class == String
#           File.open(current_filepath_json, 'w+') {|f| f.write response }
#           return response
#         else
#           make_path current_filepath
#           @agent = response
#           return self
#         end
#       else
#         return self
#       end
#     end
#   end

#   private

#   def current_filepath_json
#     "#{current_filepath}.json"
#   end

#   def argument_history
#     @argument_history.map(&:to_s)
#   end

#   def default_agent
#     Mechanize.new {|agent| agent.user_agent_alias = 'Mac Safari'}
#   end

#   def current_filepath
#     Rails.root.join(default_base_path, *argument_history)
#   end

#   # def filepath(*params)
#   #   Rails.root.join(@base_path, cached_params(*params)
#   # end

#   def cached_params(*args)
#     Digest.hexencode(args.flatten.join('-'))
#   end

#   def default_base_path
#    "cached_mechanize/#{Rails.env}"
#   end

#   # def make_default_base_path
#   #   make_path default_base_path
#   # end

#   def make_path(path)
#     FileUtils.mkpath path
#   end

# end