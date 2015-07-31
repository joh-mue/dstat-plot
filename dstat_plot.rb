require 'Gnuplot'
require 'CSV'

# dstat_plot
# plots csv data generated by dstat-monitor
#
#
# invertierte graphen
# Zeit auf x Achse -> epochen
#

$category = "total cpu usage"
$field = "usr"

def print_usage
  puts "Add usage here."
end

def plot(dataSet)

  Gnuplot.open do |gp|
    Gnuplot::Plot.new( gp ) do |plot|
  
      plot.title  "#{$category}[#{$field}] over time"
      plot.xlabel "Index"
      plot.ylabel "#{$category}: #{$field}"
      
      #x = (0..50).collect { |v| v.to_f }
      #y = x.collect { |v| v ** 2 }

      x = (0..dataSet.count-1).collect { |index| index }
      y = dataSet.collect { |item| item }

      plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
        # ds.with = "filledcurve x1"
        # ds.with = "linespoint"
        ds.with = "lines" 
        ds.notitle
      end
    end
  end
end

def read_csv
  puts "Reading from csv."
  dataSet = Array.new

  CSV.open("/Users/Johannes/arbeit/scripts/kmeans_clean_5000000.csv") { |file| # set a mode?
    for i in 0..4 # skip the first 5 rows, nothing in there that interests us
  		file.shift
  	end

    currentRow = file.shift
    categoryIndex = currentRow.index($category)
  	if categoryIndex == "null"
  		puts "#{$category} is not a valid parameter for 'category'. Item could not be found."
      puts "Categories: #{row.inspect}"
  		exit 1
  	end
  	
  	currentRow = file.shift.drop(categoryIndex)
  	fieldIndex =  categoryIndex + currentRow.index($field)
  	if fieldIndex == "null"
  		puts "#{$field} is not a valid parameter for 'field'. Item could not be found."
      puts "Fields: #{currentRow.inspect}"
  		exit 1
  	end

  	currentRow = file.shift
    until file.eof do
      dataSet.push currentRow.at(fieldIndex)
      currentRow = file.shift
    end
  }

  dataSet
end


def read_arguments
  puts "Reading arguments."
  # if not enough elements print usage
  # read csv file location
  # read element to be plotted

end

read_arguments

dataSet = read_csv
puts dataSet.inspect
plot(dataSet)