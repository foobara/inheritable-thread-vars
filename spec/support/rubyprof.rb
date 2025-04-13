RSpec.configure do |config|
  config.around(:each, :profile) do |example|
    require "ruby-prof"
    RubyProf.start
    example.run
    result = RubyProf.stop

    printer = RubyProf::GraphHtmlPrinter.new(result)
    File.open("tmp/profile-out.html", "w+") do |file|
      printer.print(file)
    end
  end
end
