#!/usr/bin/env ruby

require "pathname"

AUTHOR = "jrruethe"
BASE_IMAGE = "#{AUTHOR}/base_image:latest"

# Get the path of the first directory relative to the second
def relative_to(a, b)
  a = Pathname.new(File.join(Dir.pwd, a))
  b = Pathname.new(File.join(Dir.pwd, b))
  r = a.relative_path_from(b)
  return r
end

def docker_run(image, command)
  return <<~EOF
  docker run -it --rm \
  -u $(id -u ${USER}):$(id -g ${USER}) \
  -v $(pwd):/mnt -w /mnt \
  #{image} \
  #{command}
  EOF
end

# Build the base image
task :base_image do
  sh <<~EOF
  cd dockerfiles
  docker build . -q -f Dockerfile.base -t #{BASE_IMAGE}
  EOF
end

# Build all the common gems
task :common => :base_image do

  # Built gems will be stored in the build directory
  sh <<~EOF
  mkdir -p build
  EOF

  # Build all the common gems
  Dir.glob("src/common/*/") do |directory|
    sh <<~EOF
    cd #{directory}

    # Build the gem inside of a Docker container
    #{docker_run(BASE_IMAGE, "rake build")}
    EOF
  end

  # Move the artifacts to the gem directory
  sh <<~EOF
  find src -type f -name '*.gem' -exec cp {} build \\;
  EOF
end

task :product_name => :common do 
  dockerfile = "./dockerfiles/Dockerfile.build"
  directory = "./src/product_name"
  image = "#{AUTHOR}/product_name:latest"

  sh <<~EOF

  # Copy the common gems to the pkg directory
  mkdir -p #{directory}/pkg
  cp build/*.gem #{directory}/pkg
  cd #{directory}

  # Build the gem inside of a Docker container
  #{docker_run(BASE_IMAGE, "rake build")}

  # Build the distribution image
  docker build . -q -f #{relative_to(dockerfile, directory)} -t #{image}
  EOF
end

task :product_price => :common do

end

task :api => :common do

end

task :test do
  # Run all tests inside of Docker
  dockerfile = "./dockerfiles/Dockerfile.build"
  Dir.glob("src/**/Rakefile") do |file|
    directory = File.dirname(file)
    image = "#{AUTHOR}/#{File.basename(directory)}_test:latest"
    sh <<~EOF
    cd #{directory}

    # Build the Docker image for running the tests
    docker build . -q -f #{relative_to(dockerfile, directory)} -t #{image}

    # Run the tests inside of a Docker container
    #{docker_run(image, "rake test")}
    EOF
  end
end

task :all => [:common]
task :default => :all
