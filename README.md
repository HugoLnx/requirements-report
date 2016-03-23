# Requirements Report
Script to get all the data of a project of [Cenários e Léxico](http://transparencia.les.inf.puc-rio.br:8080)
and create a HTML with it.


## Configuring
### Create your config.yml
Copy `config.yml.sample` to `config.yml` and update it with your team members and credentials.

### Create your report.html.erb
Copy `report.html.erb.sample` to `report.html.erb` and edit if you would like to customize
the HTML of the report. The default works just fine. :)


## Installing and Running
### With docker - Only OSX and Linux (Easier if you don't know nothing about Ruby or Phantom JS)
1. Install [Docker](https://www.docker.com/)
2. Build docker image running `./prepare.sh`. (Do it every time you update the script)
3. Run the script with `./generate.sh "PART OF PROJECT NAME"`

### With Ruby and Phantom JS 
1. Install Ruby 2.3.0
2. Install Phantom JS
3. Install bundler: "gem install bundler"
4. Install Ruby dependencies running: `bundle install`
5. Run the script: `ruby generate_report.rb "PART OF PROJECT NAME"`
