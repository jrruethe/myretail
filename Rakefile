#!/usr/bin/env ruby

AUTHOR = "jrruethe"
BASE_IMAGE = "#{AUTHOR}/base_image:latest"

# Build the image in the given directory and tag it with the given name
def docker_build(image, directory)
  "cd #{directory}; docker build . -q -t #{image}"
end

# Run the given command inside a container using the given image
def docker_run(image, command)
  "docker run -it --rm -v $(pwd):/mnt -w /mnt #{image} /bin/bash -c '#{command}'"
end

# Build the gem in the given directory
def build_gem(directory)
  "cd #{directory}; #{docker_run(BASE_IMAGE, "rake build")}"
end

# Run the tests for the code in the given directory
def run_tests(image, directory)
  "cd #{directory}; #{docker_run(image, "rake test")}"
end

# Build the base image
task :base_image do
  sh docker_build(BASE_IMAGE, "base_image")
end

# Build all the common gems
task :common => :base_image do 
  Dir.glob("src/common/*/") do |d|
    sh build_gem(d)
  end
end

task :product_name => :common do 

end

task :product_price => :common do

end

task :api => :common do

end

task :test do
  Dir.glob("src/**/Rakefile") do |f|
    directory = File.dirname(f)
    image = "#{AUTHOR}/#{File.basename(directory)}:latest"
    sh docker_build(image, directory)
    sh run_tests(image, directory)
  end
end

task :all => [:common]
task :default => :all
