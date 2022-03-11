FROM jrruethe/base_image:latest
WORKDIR /mnt
COPY Gemfile /mnt
COPY Gemspec.yml /mnt
COPY *.gemspec /mnt
RUN bundle install
