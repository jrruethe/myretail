#!/usr/bin/env ruby

require "pathname"
require "yaml"
require "fileutils"

AUTHOR = "jrruethe"
BASE_IMAGE = "#{AUTHOR}/base_image:latest"
SINATRA_PORT = 4567

# Main service components
COMPONENTS =
[
  :api,
  :product_name,
  :product_price
]

###############################################################################
# Shouldn't need to modify anything below

# Locations of the Dockerfiles
DOCKERFILE =
{
  base:  "./dockerfiles/Dockerfile.base",
  build: "./dockerfiles/Dockerfile.build",
  dist:  "./dockerfiles/Dockerfile.dist"
}

# Define the Dockerfile dependencies
file DOCKERFILE[:build] => DOCKERFILE[:base]
file DOCKERFILE[:dist]  => DOCKERFILE[:base]

# Location of build artifacts
ARTIFACT = "./build"
IMAGE_ARTIFACT = "#{ARTIFACT}/image"
TEST_IMAGE_ARTIFACT = "#{ARTIFACT}/image/test"
GEM_ARTIFACT = "#{ARTIFACT}/gem"
COMMON_GEM_ARTIFACT = "#{ARTIFACT}/gem/common"
INTERMEDIATE_ARTIFACT = "pkg"

# Build the artifact directory structure
directory ARTIFACT
directory IMAGE_ARTIFACT => ARTIFACT
directory TEST_IMAGE_ARTIFACT => IMAGE_ARTIFACT
directory COMMON_GEM_ARTIFACT => GEM_ARTIFACT
directory GEM_ARTIFACT => ARTIFACT

# Convert a Docker image name to a filename for saving
def image_to_filename(image)
  image.gsub(/[\/:]/, "_") + ".tar"
end
BASE_IMAGE_FILENAME = "#{IMAGE_ARTIFACT}/#{image_to_filename(BASE_IMAGE)}"

# Get the path of the first directory relative to the second
def relative_to(a, b)
  a = Pathname.new(File.join(Dir.pwd, a))
  b = Pathname.new(File.join(Dir.pwd, b))
  r = a.relative_path_from(b)
  return r
end

# Return a string that will run a given command inside of a Docker container
# with the current directory mounted, and the permissions of the host user
def docker_run(image, command)
  return <<~EOF
  docker run -it --rm \
  -u $(id -u ${USER}):$(id -g ${USER}) \
  -v $(pwd):/mnt -w /mnt \
  -p #{SINATRA_PORT}:#{SINATRA_PORT} \
  #{image} \
  #{command}
  EOF
end

# Uses Docker to build a gem
# only if a source file has changed
def build_intermediate_gem_file(source_directory, gem_name)

  # Derive the component name
  component = File.basename(source_directory)

  # Determine the gem file name
  intermediate_gem_file = source_directory + "#{INTERMEDIATE_ARTIFACT}/#{gem_name}"

  # Ensure the intermediate directory is created
  directory source_directory + INTERMEDIATE_ARTIFACT

  # Specify dependencies
  file intermediate_gem_file => BASE_IMAGE_FILENAME
  file intermediate_gem_file => FileList[source_directory + "**/*.rb"]
  file intermediate_gem_file =>
  [
    "Gemfile",
    "Gemspec.yml",
    "#{component}.gemspec",
    "pkg"
  ].map{|i| source_directory + i} 

  # Build the gem
  file intermediate_gem_file do
    sh <<~EOF
    cd #{source_directory}
    #{docker_run(BASE_IMAGE, "rake build")}
    EOF
  end
end

###############################################################################
# Build the base image
task :build_base_image => BASE_IMAGE_FILENAME
task :build_images => :build_base_image
file BASE_IMAGE_FILENAME => 
[
  IMAGE_ARTIFACT,
  DOCKERFILE[:base]
] do
  sh <<~EOF
  cd dockerfiles
  docker build . -q -f #{File.basename(DOCKERFILE[:base])} -t #{BASE_IMAGE}
  cd -
  docker save #{BASE_IMAGE} > #{BASE_IMAGE_FILENAME}
  EOF
end
###############################################################################

###############################################################################
# For each gem in the common directory
common_gems = []
Dir.glob("src/common/*/") do |source_directory|
  
  # Determine the gem name
  component = File.basename(source_directory)
  version = YAML.load_file(source_directory + "Gemspec.yml")["version"]
  gem_name = "#{component}-#{version}.gem"
  intermediate_gem_file = source_directory + "#{INTERMEDIATE_ARTIFACT}/#{gem_name}"
  final_gem_file = "#{COMMON_GEM_ARTIFACT}/#{gem_name}"
  common_gems << final_gem_file
  
  # Create the task dependencies
  task :build_common_gems => "build_#{component}".to_sym
  task "build_#{component}".to_sym => final_gem_file
  file final_gem_file => [COMMON_GEM_ARTIFACT, intermediate_gem_file] do
    FileUtils.cp(intermediate_gem_file, final_gem_file)
  end

  # Build the gem file
  build_intermediate_gem_file(source_directory, gem_name)
end
task :build_gems => :build_common_gems
###############################################################################

###############################################################################
# Build the main components
COMPONENTS.each do |component|

  # Determine the image and filename
  image = "#{AUTHOR}/#{component}:latest"
  image_filename = "#{IMAGE_ARTIFACT}/#{image_to_filename(image)}"

  # Determine the gem name
  source_directory = "./src/#{component}/"
  version = YAML.load_file(source_directory + "Gemspec.yml")["version"]
  gem_name = "#{component}-#{version}.gem"
  intermediate_gem_file = source_directory + "#{INTERMEDIATE_ARTIFACT}/#{gem_name}"
  final_gem_file = "#{GEM_ARTIFACT}/#{gem_name}"

  # Build the gem file
  build_intermediate_gem_file(source_directory, gem_name)

  # Copy the gem to the artifact directory
  file final_gem_file => [ARTIFACT, intermediate_gem_file] do
    FileUtils.cp(intermediate_gem_file, final_gem_file)
  end
  task :build_gems => final_gem_file
  
  # Build the distribution image
  file image_filename => common_gems
  file image_filename => 
  [
    BASE_IMAGE_FILENAME,
    DOCKERFILE[:dist],
    intermediate_gem_file,
  ] do

    # Copy the common gems into the image
    Dir.glob("#{COMMON_GEM_ARTIFACT}/*.gem") do |file|
      FileUtils.cp(file, source_directory + INTERMEDIATE_ARTIFACT)
    end

    # Build and save the distribution image
    sh <<~EOF
    cd #{source_directory}
    docker build . -q -f #{relative_to(DOCKERFILE[:dist], source_directory)} -t #{image}
    cd -
    docker save #{image} > #{image_filename}
    EOF
  end

  # Create tasks
  task "build_#{component}_gem".to_sym => final_gem_file
  task "build_#{component}_image".to_sym => image_filename
  task "build_#{component}".to_sym =>
  [
    "build_#{component}_gem",
    "build_#{component}_image",
  ]
  task :build_images => "build_#{component}_image".to_sym
end

task :build => [:build_gems, :build_images]
###############################################################################

###############################################################################
# Build the test images
Dir.glob("src/**/Rakefile") do |file|
  source_directory = File.dirname(file)
  component = File.basename(source_directory)

  # Determine the image and filename
  image = "#{AUTHOR}/#{component}_test:latest"
  image_filename = "#{TEST_IMAGE_ARTIFACT}/#{image_to_filename(image)}"

  file image_filename => 
  [
    TEST_IMAGE_ARTIFACT,
    BASE_IMAGE_FILENAME,
    DOCKERFILE[:build],
    source_directory + "/Gemfile",
    source_directory + "/Gemspec.yml",
    source_directory + "/#{component}.gemspec",
  ] do
    sh <<~EOF
    cd #{source_directory}
    docker build . -q -f #{relative_to(DOCKERFILE[:build], source_directory)} -t #{image}
    cd -
    docker save #{image} > #{image_filename}
    EOF
  end
  task :build_test_images => image_filename

  # Run unit tests
  task "test_#{component}".to_sym => image_filename do
    sh <<~EOF
    cd #{source_directory}
    #{docker_run(image, "rake test")}
    EOF
  end
  task :test => "test_#{component}".to_sym

  # Run application for local testing
  task "run_#{component}".to_sym => image_filename do
    sh <<~EOF
    cd #{source_directory}
    #{docker_run(image, "bundle exec bin/app.rb")}
    EOF
  end
end
###############################################################################

###############################################################################
# Clean up
task :clean_gems do
  Dir.glob("./**/*.gem") do |f|
    FileUtils.rm f
  end
end

task :clean_tarballs do
  Dir.glob("#{IMAGE_ARTIFACT}/**/*.tar") do |f|
    FileUtils.rm f
  end
end

task :clean_docker_images => :clean_tarballs do
  sh <<~EOF
  docker images | grep '#{AUTHOR}/*' | awk '{print $1}' | xargs docker rmi 2>/dev/null || true
  EOF
end

task :clean => [:clean_gems, :clean_docker_images, :clean_tarballs]
###############################################################################

###############################################################################
# Deployment
task :deploy => :build do

end
###############################################################################

# Defaults
task :all => [:clean, :test, :build, :deploy]
task :default => :deploy
