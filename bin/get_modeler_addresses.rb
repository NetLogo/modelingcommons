#!/usr/bin/env ruby

require 'mbox'
mbox = Mbox.open('/Users/reuven/Downloads/ccl-tech.mbox')

community_model_authors = { }

model_count = 0
number_of_messages = mbox.length
mbox.each_with_index do |message, index|
  if message.headers['subject'] =~ /model contribution/i
    puts "\n#{index} / #{number_of_messages}: #{message.headers['subject']}"

    content = message.content.parse('')[0].to_s

    if content =~ /A model, "[^"]*?([^"\\]+)" was contributed/
      model_name = $1
      puts "\t#{model_count} Model name: '#{model_name}'"
      model_count += 1

      content =~ /E-?mail: *(\S+)/i
      email = $1 || '(none)'
      puts "\tEmail: '#{email}'"

      puts "\tStoring model '#{model_name}' under e-mail address '#{email}'"

      if community_model_authors.has_key?(email)
        community_model_authors[email] << model_name
      else
        community_model_authors[email] = [model_name]
      end

    else
      puts "\tNo model name found"
      puts content.gsub("\n", "\n\t")
    end

  end
end

puts community_model_authors.inspect 
community_model_authors.each do |email, models|
  puts email
  models.each do |model|
    puts "\t#{model}"
  end
end



# A model, "AntsOpt.nlogo" was contributed,
# and has been saved to /home/httpd/contrib_models/AntsOpt.nlogo.3885.

# Name: Erich Neuwirth
# E-mail: erich.neuwirth@univie.ac.at
# Organization: University of Vienna

