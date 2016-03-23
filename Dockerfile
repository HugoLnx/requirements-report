FROM ubuntu:14.04.1

# NOTE: This Dockerfile is in the current state only for development purpose!

# make sure rvm and ruby 2.3.0 are in PATH
ENV PATH=/usr/local/rvm/bin:/usr/local/rvm/rubies/ruby-2.3.0/bin:$PATH
ENV DEBIAN_FRONTEND noninteractive

# create /app folder and set it as workdir
RUN mkdir /app
WORKDIR /app

# update and upgrade packages
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
  curl \
	git \
	nodejs \
	phantomjs \
	&& apt-get clean

# install rvm
RUN command curl -sSL https://rvm.io/mpapis.asc | gpg --import -
RUN \curl -L https://get.rvm.io | bash -s stable

# install rvm requirements and ruby 2.3.0
RUN rvm requirements
RUN rvm install 2.3.0
RUN gem install bundler --no-ri --no-rdoc

ADD ./ /app/

# install app requirements
RUN bundle install

VOLUME /app/

CMD ruby generate_report.rb
