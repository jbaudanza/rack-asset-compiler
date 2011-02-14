require "rspec/core"
require "rspec/core/rake_task"

desc "Run all specs"
RSpec::Core::RakeTask.new(:default) do |t|
  t.rspec_opts = ["--color", "--format", "documentation"]
  t.verbose = true
  t.pattern = ['spec/*.rb']
end
