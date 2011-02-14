require 'rack/coffee_compiler'
require 'rack/lobster'
require "rack/test"

include Rack::Test::Methods

describe "CoffeeCompiler" do
  before do
    @source_dir = File.join(File.dirname(__FILE__), 'fixtures/coffeescripts')

    @options = {
      :source_dir => @source_dir
    }
  end

  def app
    options = @options
    Rack::Builder.new {
      use Rack::Lint
      use Rack::CoffeeCompiler, options
      run Rack::Lobster.new
    }
  end

  it "should compile the coffeescript" do
    get '/javascripts/application.js'
    last_response.body.should == CoffeeScript.compile(File.read("#{@source_dir}/application.coffeescript"))
    last_response.status.should == 200
    last_response.content_type.should == 'text/javascript'
  end

  describe "when compiling a file with a syntax error" do
    def do_get
      get '/javascripts/syntax_error.js'
    end

    it "should render a window.alert by default" do
      @options.delete(:alert_on_error)
      do_get
      last_response.body.should include('window.alert')
    end

    it "should not render a window.alert by default on production" do
      @options.delete(:alert_on_error)
      old_rack_env = ENV['RACK_ENV']
      ENV['RACK_ENV'] = 'production'
      lambda { do_get }.should raise_error(CoffeeScript::CompilationError)
      ENV['RACK_ENV'] = old_rack_env
    end

    it "should not render a window.alert if alert_on_error is false" do
      @options[:alert_on_error] = false
      lambda { do_get }.should raise_error(CoffeeScript::CompilationError)
    end

    it "should render a window.alert if alert_on_error is true" do
      @options[:alert_on_error] = true
      do_get
      last_response.body.should include('window.alert')
    end
  end
end