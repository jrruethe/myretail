#!/usr/bin/env ruby

require "pathname"
require "yaml"
require "fileutils"
require "socket"

AUTHOR = "jrruethe"
REGISTRY = "registry.localhost:5000"
BASE_IMAGE = "#{REGISTRY}/#{AUTHOR}/base_image:latest"
TEST_IMAGE = "#{REGISTRY}/#{AUTHOR}/test_image:latest"
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
  base: "./dockerfiles/Dockerfile.base",
  test: "./dockerfiles/Dockerfile.test",
  dist: "./dockerfiles/Dockerfile.dist",
}

# Define the Dockerfile dependencies
file DOCKERFILE[:test] => DOCKERFILE[:base]
file DOCKERFILE[:dist] => DOCKERFILE[:base]

# Location of build artifacts
ARTIFACT              = "./build"
IMAGE_ARTIFACT        = "#{ARTIFACT}/image"
GEM_ARTIFACT          = "#{ARTIFACT}/gem"
COMMON_GEM_ARTIFACT   = "#{ARTIFACT}/gem/common"

# Build the artifact directory structure
directory ARTIFACT
directory IMAGE_ARTIFACT      => ARTIFACT
directory GEM_ARTIFACT        => ARTIFACT
directory COMMON_GEM_ARTIFACT => GEM_ARTIFACT

# Location of important folders
SOURCE                = "src"
COMMON                = "src/common"
INTERMEDIATE_ARTIFACT = "pkg"
VENDOR_CACHE          = "vendor/cache"
VENDOR_BUNDLER        = "vendor/bundler"

# Convert a Docker image name to a filename for saving
def image_to_filename(image)
  image.gsub(/[\.\/:]/, "_") + ".tar"
end

# Define the common docker image filenames and dependencies
BASE_IMAGE_FILENAME = "#{IMAGE_ARTIFACT}/#{image_to_filename(BASE_IMAGE)}"
TEST_IMAGE_FILENAME = "#{IMAGE_ARTIFACT}/#{image_to_filename(TEST_IMAGE)}"
file TEST_IMAGE_FILENAME => BASE_IMAGE_FILENAME

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
  /bin/sh -c '#{command}'
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
  file intermediate_gem_file => source_directory + "bin/app" unless source_directory.start_with?("./src/common/")
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
file BASE_IMAGE_FILENAME => 
[
  IMAGE_ARTIFACT,
  DOCKERFILE[:base]
] do
  sh <<~EOF
  cd dockerfiles
  docker build . -f #{File.basename(DOCKERFILE[:base])} -t #{BASE_IMAGE}
  cd -
  docker save #{BASE_IMAGE} > #{BASE_IMAGE_FILENAME}
  EOF
end
task :build_base_image => BASE_IMAGE_FILENAME
task :build_images => :build_base_image
###############################################################################

###############################################################################
# Build the test image
file TEST_IMAGE_FILENAME => 
[
  IMAGE_ARTIFACT,
  DOCKERFILE[:test]
] do
  sh <<~EOF
  cd dockerfiles
  docker build . -f #{File.basename(DOCKERFILE[:test])} -t #{TEST_IMAGE} \
  --build-arg USERNAME=${USER} \
  --build-arg UID=$(id -u ${USER}) \
  --build-arg GID=$(id -g ${USER})
  cd -
  docker save #{TEST_IMAGE} > #{TEST_IMAGE_FILENAME}
  EOF
end
task :build_test_image => TEST_IMAGE_FILENAME
task :build_images => :build_test_image
###############################################################################

###############################################################################
# For each gem in the common directory
common_gems = []
Dir.glob("./src/common/*/") do |source_directory|
  
  # Determine the gem name
  component = File.basename(source_directory)
  version = YAML.load_file(source_directory + "Gemspec.yml")["version"]
  gem_name = "#{component}-#{version}.gem"
  intermediate_gem_file = source_directory + "#{INTERMEDIATE_ARTIFACT}/#{gem_name}"
  final_gem_file = "#{COMMON_GEM_ARTIFACT}/#{gem_name}"

  # Store a list of common gems for later
  common_gems << final_gem_file
  
  # Create the task dependencies
  file final_gem_file => [COMMON_GEM_ARTIFACT, intermediate_gem_file] do
    FileUtils.cp(intermediate_gem_file, final_gem_file)
  end
  task "build_#{component}".to_sym => final_gem_file
  task :build_common_gems => "build_#{component}".to_sym

  # Build the gem file
  build_intermediate_gem_file(source_directory, gem_name)
end
task :build_gems => :build_common_gems
###############################################################################

###############################################################################
# Build the main components
COMPONENTS.each do |component|

  # Determine the image and filename
  image = "#{REGISTRY}/#{AUTHOR}/#{component}:latest"
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
  
  # Copy locally-built gems into the image
  common_gems.each do |gem|
    copy_to = "#{source_directory + INTERMEDIATE_ARTIFACT}/#{File.basename(gem)}"
    file copy_to => gem do
      FileUtils.cp(gem, copy_to)
    end
    file image_filename => copy_to
  end

  # Build the distribution image
  file image_filename => 
  [
    BASE_IMAGE_FILENAME,
    DOCKERFILE[:dist],
    intermediate_gem_file,
  ] do

    # Build and save the distribution image
    sh <<~EOF
    cd #{source_directory}
    docker build . -f #{relative_to(DOCKERFILE[:dist], source_directory)} -t #{image}
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

  # Run distribution image
  task "run_release_#{component}".to_sym => image_filename do
    sh <<~EOF
    cd #{source_directory}
    #{docker_run(image, "/usr/local/bin/app")}
    EOF
  end
end

task :build => [:build_gems, :build_images]
###############################################################################

###############################################################################
# Testing
Dir.glob("./src/**/Rakefile") do |file|
  # Don't test vendored gems
  next if file =~ /^\.\/src\/.+\/vendor\/.+$/

  # Determine which component is being tested
  source_directory = File.dirname(file)
  component = File.basename(source_directory)

  # Run unit tests
  task "test_#{component}".to_sym => TEST_IMAGE do
    sh <<~EOF
    cd #{source_directory}
    #{docker_run(TEST_IMAGE, "bundle config path vendor/bundler && bundle install && bundle exec rake test")}
    EOF
  end
  task :test => "test_#{component}".to_sym

  # Copy locally-built gems into the image
  common_gems.each do |gem|
    # Don't create circular dependencies among the common gems
    next if source_directory.start_with?("./#{COMMON}/")
    directory "#{source_directory}/#{VENDOR_CACHE}"
    copy_to = "#{source_directory}/#{VENDOR_CACHE}/#{File.basename(gem)}"
    file copy_to => [gem, "#{source_directory}/#{VENDOR_CACHE}"] do
      FileUtils.cp(gem, copy_to)
    end
    task "run_#{component}".to_sym => copy_to
  end

  # Run application for local testing
  task "run_#{component}".to_sym => TEST_IMAGE_FILENAME do
    sh <<~EOF
    cd #{source_directory}
    #{docker_run(TEST_IMAGE, "bundle config path vendor/bundler && bundle install --no-cache && bundle exec bin/app")}
    EOF
  end
end
###############################################################################

###############################################################################
# Clean up

task :clean_build do
  FileUtils.rm_rf(ARTIFACT)
end

task :clean_vendor do
  Dir.glob("./#{SOURCE}/**/vendor/") do |d|
    next if d.include?(VENDOR_BUNDLER)
    FileUtils.rm_rf(d)
  end
end

task :clean_gems do
  Dir.glob("./**/*.gem") do |f|
    FileUtils.rm(f)
  end
end

task :clean_tarballs do
  Dir.glob("#{IMAGE_ARTIFACT}/**/*.tar") do |f|
    FileUtils.rm(f)
  end
end

task :clean_images => :clean_tarballs do
  sh <<~EOF
  docker images | grep '#{AUTHOR}/*' | awk '{print $1}' | xargs docker rmi 2>/dev/null || true
  EOF
end

task :clean => [:clean_build, :clean_vendor, :clean_gems, :clean_images, :clean_tarballs]
###############################################################################

###############################################################################
# Deployment

def deploy(file)
  `./bin/k3s kubectl apply -f #{file}`
end

def wait_for(host, port)
  loop do
    begin
      TCPSocket.new(host, port.to_i)
      return true
    rescue Errno::ECONNREFUSED, Errno::ENETUNREACH
      sleep 3
    end
  end
end

task :push => :build do

  # Deploy the registry
  [
    "./deploy/kubernetes_manifests/registry/deployment.yml",
    "./deploy/kubernetes_manifests/registry/service.yml",
  ]
  .each{|i| deploy(i)}

  # Wait for the registry to come up
  wait_for(*REGISTRY.split(":"))

  # Push images to the registry
  `docker images | grep #{REGISTRY}/#{AUTHOR} | awk '{print $1}'`.split.each do |image|
    `docker push #{image}`
  end
end

task :deploy => :push do

  # Deploy the manifests
  [
    "./deploy/kubernetes_manifests/product_name/api/deployment.yml",
    "./deploy/kubernetes_manifests/product_name/api/service.yml",
    "./deploy/kubernetes_manifests/product_name/api/ingress.yml",
    "./deploy/kubernetes_manifests/product_name/mongodb/deployment.yml",
    "./deploy/kubernetes_manifests/product_name/mongodb/service.yml",
  ]
  .each{|i| deploy(i)}

end
###############################################################################

# Defaults
task :all => [:clean, :test, :build, :push, :deploy]
task :default => :deploy
