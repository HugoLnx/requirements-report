require 'bundler/setup'
require 'fileutils'
require 'capybara'
require 'capybara/poltergeist'
require 'yaml'
require 'erb'

Encoding.default_external = "UTF-8"


module Config
  CONFIG_FILE = "config.yml"
  
  def self.load
    if File.exists? CONFIG_FILE
      return YAML.load_file CONFIG_FILE
    else
      puts "You must create a #{CONFIG_FILE} on the same folder of this script, use #{CONFIG_FILE}.sample as example"
      exit 1
    end
  end
end

class Reporter
  REPORT_FOLDER = "./report"
  REPORT_TEMPLATE = "report.html.erb"
  
  def self.load
    if File.exists? REPORT_TEMPLATE
      Reporter.new ERB.new(File.read REPORT_TEMPLATE)
    else
      puts "You must create a #{REPORT_TEMPLATE} on the same folder of this script, use #{REPORT_TEMPLATE}.sample as example"
      exit 1
    end
  end
  
  def initialize(template)
    @template = template
  end

  def save(team: , project_name:, project_table: , scenario_tables: , lexico_tables: )
    @team = team
    @project_table = project_table
    @scenario_tables = scenario_tables
    @lexico_tables = lexico_tables
    
    html = @template.result binding
    
    write_report(html, filename: "#{project_name}.html")
  end
  
  private
  
  def write_report(html, folder: REPORT_FOLDER, filename: "report.html")
    FileUtils.mkdir_p(folder) rescue nil
    filepath = File.join(folder, filename)
    File.open(filepath, 'w'){|f| f.write html}
    puts "Report saved on #{filepath}"
  end
end

config = Config.load
reporter = Reporter.load

project_name = ARGV.join(" ")
if project_name.empty?
  puts "You must pass the project name as first argument of this script."
  exit 1
end

Capybara.current_driver = :poltergeist
Capybara.javascript_driver = :poltergeist
Capybara.app_host = "http://transparencia.les.inf.puc-rio.br:8080"
  
session = Capybara::Session.new :poltergeist

puts "Logging in C&L system using your credentials"
session.visit "/cel/visao/index.html"

session.within("form") do
  session.fill_in "input_login_index", with: config.dig('credentials', 'login')
  session.fill_in "input_senha_index", with: config.dig('credentials', 'pass')
  session.click_button "Entrar"
end

session.has_css? "select#select_menu_projetos"
session.find("select#select_menu_projetos option:first-child").has_content? "--- Selecione um projeto ---"
options = session.find_all("select#select_menu_projetos option")
option = options.find{|option| option.text =~ /#{project_name}/i }
if option.nil?
  puts "The project '#{project_name}' was not found."
  exit 1
else
  puts "Selecting project #{option.text}"
  session.select(option.text, from: "select_menu_projetos")
end

session.has_css? "#ul_menu_lateral_cenarios li a"
session.has_css? "#ul_menu_lateral_lexicos li a"
session.has_css? "#cmp_nome_pr"
session.find("#cmp_nome_pr").has_content? project_name

scenario_anchors = session.find_all("#ul_menu_lateral_cenarios li a")
lexico_anchors = session.find_all("#ul_menu_lateral_lexicos li a")
project_table = session.find(".tableestilocenario")['outerHTML']

puts "Scenarios found:"
scenario_anchors.each{|a| puts "  - #{a.text}"}

puts "Lexical symbols found:"
lexico_anchors.each{|a| puts "  - #{a.text}"}

puts "Getting scenario tables"
scenario_tables = scenario_anchors.map do |anchor|
  anchor.click
  session.has_css? "#cmp_titulo"
  title = session.find "#cmp_titulo"
  title.has_content? anchor.text
  session.find(".tableestilocenario")['outerHTML']
end

puts "Getting symbol lexico tables"
lexico_tables = lexico_anchors.map do |anchor|
  anchor.click
  session.has_css? "#cmp_nome"
  name = session.find "#cmp_nome"
  name.has_content? anchor.text
  session.find(".tableestilocenario")['outerHTML']
end

reporter.save(
  team: config['team'],
  project_name: project_name,
  project_table: project_table,
  scenario_tables: scenario_tables,
  lexico_tables: lexico_tables,
)
