Gem::Specification.new do |spec|
  spec.name        = 'dstat_plot'
  spec.version     = '0.6.2'
  spec.date        = '2016-07-05'
  spec.summary     = "Plot dstat-monitor data with gnuplot"
  spec.description = "Uses gnuplot to plot csv data generated by mvneves' dstat-monitor."
  spec.authors     = ["joh-mue"]
  spec.email       = 'yesiamkeen@gmail.com'
  spec.homepage    = 'http://github.com/citlab/dstat-tools'
  spec.files       = ["lib/dstat_plot.rb"]
  spec.executables << 'dstat-plot'
  spec.license     = 'MIT'
  spec.add_runtime_dependency "gnuplot", ["~> 2.6"]
end
