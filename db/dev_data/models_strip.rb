require 'find'
require 'csv'

#holds the relevant data from the nlogo file
class NlogoModelFile
  #escape '@' and '#' cause they're special in ruby
  SEPARATOR = "\@\#$\#\@\#$\#\@\n"
  SOURCE_INDEX = 0
  WIDGETS_INDEX = 1
  INFO_INDEX = 2
  SHAPES_INDEX = 3
  VERSION_INDEX = 4
  PREVEW_COMMANDS_INDEX = 5
  AGGREGATE_INDEX = 6
  EXPERIMENTS_INDEX = 7
  CLIENT_INDEX = 8
  LINK_SHAPES_INDEX = 9
  attr_accessor :path, :full_path, :name, :categories, :source, :info, :file_lines, :separator_indices
  def initialize(path)
    @full_path = File.dirname(path)
    @path = @full_path[RELATIVENESS.length+"/public".length..-1]
    #ditch the relative path from the beginning of the path and 
    @categories = @path.split("/")
    @name = File.basename(path, ".nlogo")
    @file_lines = IO.readlines(path)
    #find separators
    @separator_indices = []
    file_lines.each_with_index do |line, index|
      if line == SEPARATOR
        @separator_indices << index
      end
    end
    @source = file_lines[0..@separator_indices[SOURCE_INDEX]-1].join
    @info = file_lines[@separator_indices[WIDGETS_INDEX]+1..@separator_indices[INFO_INDEX]-1].join
#    puts @source
#    puts @info
    puts @path
    puts @name
#    categories.each do |category|
#      puts "\tcategory: #{category}"
#    end
  end
  
  def write_to_fixture(outputfile)
    outfile = File.open(outputfile, 'a')
    CSV::Writer.generate(outfile) do |csv|
      csv << [@name,@path,@source,@info]
    end
    outfile.close
  end
end

# get all the files ending in ".nlogo" from the models directory
nlogo_files = []
RELATIVENESS ="../../.."
RELATIVE_PATH = "../../../public/models/"
Find.find(RELATIVE_PATH) do | fname |
  if fname[-6,6] == ".nlogo"
    nlogo_files << fname
  end
end

puts "there were " + nlogo_files.length.to_s + " nlogo files found"

# prepare the output file by clearing it and writing the header row
outfile = File.new("models.csv", 'w')
CSV::Writer.generate(outfile) do |csv|
  csv << ['name','path','source','information']
end
outfile.close

# grab a test model file
#testfile = nlogo_files[223]
#testNlogoModelFile = NlogoModelFile.new(testfile)
#testNlogoModelFile.write_to_fixture("models.csv")

model_files = nlogo_files[0..223]
model_files.each do |nextfile|
  testNlogoModelFile = NlogoModelFile.new(nextfile)
  testNlogoModelFile.write_to_fixture("models.csv")
end











