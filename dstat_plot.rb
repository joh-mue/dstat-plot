require 'gnuplot'
require 'csv'
require 'optparse'
require 'fileutils'

# dstat_plot
# plots csv data generated by dstat-monitor
#
# TODOS:
#   invertierte graphen mit max wert als optionsfeld default 100
#   Zeit auf x Achse -> epochen (parameter ob sekunden oder minuten) und option auf normierte Zeti (z.b. x-achse fest auf 6minuten)
#   titelgraphik sollte mehr infos erhalten
#   legende erstellen
#   optimierte moeglichkeit viele Dateien anzugeben foldername + *.csv
#   ausgabe in Datei
#   gemfile??
#

$verbose = false

def plot(dataSets, category, field)
  Gnuplot.open do |gp|
    Gnuplot::Plot.new(gp) do |plot|
      plot.title  "#{category}[#{field}] over time"
      plot.xlabel "Index"
      plot.ylabel "#{category}: #{field}"
      plot.key "out vert right top"

      plot.data = []
      dataSets.each do |gpDataSet|
        plot.data.push gpDataSet
      end
    end
  end
end

def read_csv(category, field, files, no_key)
  if $verbose then puts "Reading from csv." end
  gpDataSets = [] # gpDataSets = [Gnuplot::DataSet0,Gnuplot::DataSet1,Gnuplot::DataSet2]

  files.each do |file|
    CSV.open(file) do |csvFile| # set a mode?
      for i in 0..4 do # skip the first 5 rows, nothing in there that interests us 
    	  csvFile.shift
      end

      currentRow = csvFile.shift
      categoryIndex = currentRow.index(category)
    	if categoryIndex == "null"
    		puts "#{category} is not a valid parameter for 'category'. Value could not be found."
        puts "Categories: #{row.inspect}"
    		exit 1
    	end
    	
    	currentRow = csvFile.shift.drop(categoryIndex)
    	fieldIndex =  categoryIndex + currentRow.index(field)
    	if fieldIndex == "null"
    		puts "#{field} is not a valid parameter for 'field'. Value could not be found."
        puts "Fields: #{currentRow.inspect}"
    		exit 1
    	end

      # get all the interesting values and put them in an array
    	currentRow = csvFile.shift
      values = []
      until csvFile.eof do
        values.push currentRow.at(fieldIndex)
        currentRow = csvFile.shift
      end

      # create the GnuplotDataSet that is going to be printed
      x = (0..values.count-1).collect { |index| index }
      gpDataSet = Gnuplot::DataSet.new([x, values]) do |gpdataSet|
        gpdataSet.with = "lines"
        if no_key then
          gpdataSet.notitle
        else
          gpdataSet.title = File.basename file
        end
      end

      gpDataSets.push gpDataSet
    end
  end

  if $verbose then puts "gpDataSets: #{gpDataSets.count}" end

  gpDataSets # gpDataSets = [Gnuplot::DataSet0,Gnuplot::DataSet1,Gnuplot::DataSet2]
end


def read_options_and_arguments
  options = {} # Hash that hold all the options

  optparse = OptionParser.new do |opts|
    # banner that is displayed at the top
    opts.banner = "Usage: dstat_plot.rb [options] -c CATEGORY -f FIELD file1 file2 file3 | directory"

    ### options and what they do
    opts.on('-v', '--verbose', 'Output more information') do
      $verbose = true
    end

    options[:inverted] = false
    opts.on('-i', '--inverted', 'Invert the graph') do
      options[:inverted] = true
    end

    options[:nokey] = false
    opts.on('-n','--no-key', 'No plot key is printed') do
      options[:nokey] = true
    end

    options[:category] = nil
    opts.on('-c', '--category CATEGORY', 'Select the category') do |category|
      options[:category] = category
    end

    options[:field] = nil
    opts.on('-f', '--field FIELD' , 'Select the field') do |field|
      options[:field] = field
    end

    # This displays the help screen
    opts.on('-h', '--help', 'Display this screen' ) do
      puts opts
      exit
    end
  end

  # there are two forms of the parse method. 'parse' 
  # simply parses ARGV, while 'parse!' parses ARGV 
  # and removes all options parametersfound. What's
  # left is the list of files
  optparse.parse!
  if $verbose then puts "options: #{options.inspect}" end

  files = []
  if File.directory?(ARGV.last) then
    files = Dir.glob "#{ARGV.last}/*.csv"
    puts "Plotting data from #{files.count} files."
  else
    ARGV.each do |filename|
      files.push(filename)
    end
  end
  if $verbose then puts "files: #{files.count} #{files.inspect}" end
  options[:files] = files

  options
end

options = read_options_and_arguments
dataSets = read_csv(options[:category], options[:field], options[:files], options[:nokey])
plot(dataSets, options[:category], options[:field])
