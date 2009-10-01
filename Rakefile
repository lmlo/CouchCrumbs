require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'

Hoe.plugin :newgem
# Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'couch_crumbs' do
  self.developer 'Often Void, Inc.', 'admin@oftenvoid.com'
  self.post_install_message = 'PostInstall.txt' # TODO remove if post-install message not required
  self.rubyforge_name       = self.name # TODO this is default value
  # self.extra_deps         = [['activesupport','>= 2.0.2']]
  self.version              = "0.0.1"
end

#require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
# task :default => [:spec, :features]

# Re-add the standard install task
task :install => [:install_gem]

# See: http://rspec.info/documentation/tools/rcov.html
desc "Run all examples with RCov"
Spec::Rake::SpecTask.new('coverage') do |t|
  t.spec_opts = ['--format', 'specdoc', '-c']
  t.spec_files = FileList['spec/*_spec.rb']
  t.rcov = true
  t.rcov_opts = ['--exclude', '/gems/,spec/']
end