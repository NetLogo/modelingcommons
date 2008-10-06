class Model < ActiveRecord::Base
  has_and_belongs_to_many :tags
  def image_url
    return self[:path] + "/" + self[:name] + ".png"
  end
  def information_webbified
    #return self[:information].gsub(/\n/,"<BR>")
    puts "HI!!!!!!!"
    what_is_it_start = self[:information].index('-----------') + 11 + 1
    puts "start! " + what_is_it_start.to_s
    what_is_it_first_paragraph_end = self[:information].index(/\n/,what_is_it_start)
    puts "first paragraph end! " + what_is_it_first_paragraph_end.to_s
    return self[:information][what_is_it_start..what_is_it_first_paragraph_end]
  end
end
