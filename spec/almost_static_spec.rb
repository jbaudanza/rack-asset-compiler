require 'rack/almost_static'
require 'rack/lobster'
require "rack/test"

include Rack::Test::Methods

# XXX: Better names: Compiler, Transform
describe "AlmostStatic" do
  before do
    @compiler = lambda do |source_file|
      @source_file = source_file
      'chickenscript'
    end

    @source_dir = File.join(File.dirname(__FILE__), 'fixtures/eggscripts')

    @options = {
      :urls => '/chickenscripts/',
      :source_dir => @source_dir,
      :source_extension => 'eggscript',
      :content_type => 'text/chicken-script',
      :compiler => @compiler
    }
  end

  def app
    options = @options
    Rack::Builder.new {
      use Rack::Lint
      use Rack::AlmostStatic, options
      run Rack::Lobster.new
    }
  end

  it "should match files directly beneath the URL" do
    get '/chickenscripts/application.chickenscript'
    @source_file.should == "#{@source_dir}/application.eggscript"
    last_response.body.should == 'chickenscript'
  end

  it "should match files underneath a subdirectry" do
    get '/chickenscripts/subdir/application.chickenscript'
    @source_file.should == "#{@source_dir}/subdir/application.eggscript"
    last_response.body.should == 'chickenscript'
  end

  it "should not call the compiler for missing files" do
    get '/chickenscripts/missing.chickenscript'
    @source_file.should be_nil
  end

  it "should use the correct content-type" do
    get '/chickenscripts/application.chickenscript'
    last_response.content_type.should == 'text/chicken-script'
  end

  it "should not match files outside the URL parameter" do
    get '/lobster'
    last_response.body.should include('Lobstericious')
  end

  it "should include a last-modified header" do
    get '/chickenscripts/application.chickenscript'
    last_response.headers["Last-Modified"].should == File.mtime("#{@source_dir}/application.eggscript").httpdate
  end

  it "should respond with a 304 on a last-modified hit" do
    last_modified_time = File.mtime("#{@source_dir}/application.eggscript").httpdate
    get '/chickenscripts/application.chickenscript', {}, {'HTTP_IF_MODIFIED_SINCE' => last_modified_time}
    last_response.status.should == 304
    last_response.body.should == "Not modified\r\n"
  end

  it "should return the compiled code on a last-modified miss" do
    last_modified_time = (File.mtime("#{@source_dir}/application.eggscript") - 10).httpdate
    get '/chickenscripts/application.chickenscript', {}, {'HTTP_IF_MODIFIED_SINCE' => last_modified_time}
    last_response.status.should == 200
    last_response.body.should == "chickenscript"
  end

  it "should reject requests with a .." do
    get '/chickenscript/../somethingbad'
    last_response.status.should == 403
  end

  describe "Caching" do
    it "should not cache by default" do
      @options.delete(:cache)
      get '/chickenscripts/application.chickenscript'
      last_response.headers.should_not include('Cache-Control')
    end

    it "should cache by default on production" do
      @options.delete(:cache)
      ENV['RACK_ENV'] = 'production'
      get '/chickenscripts/application.chickenscript'
      last_response.headers.should include('Cache-Control')
    end

    it "should set not the cache header when the cache options is false" do
      @options[:cache] = false
      get '/chickenscripts/application.chickenscript'
      last_response.headers.should_not include('Cache-Control')
      last_response.headers.should_not include('Expires')
    end

    it "should set the cache header to a duration of one week when the cache options is true" do
      @options[:cache] = true
      get '/chickenscripts/application.chickenscript'
      last_response.headers['Cache-Control'].should == "public,max-age=604800"
      last_response.headers.should include('Expires')
    end
  end
end