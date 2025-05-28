require 'erb'
require 'fileutils'
require 'json'
require 'onceover/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppetlabs_spec_helper/rake_tasks'
require 'r10k/puppetfile'
require 'ra10ke'
require 'yamllint/rake_task'

#Use the environment variable EXCLUDE_PATHS, delineated by ':', to know what
#paths to exclude from syntax and linting checks
exclude_paths = if ENV['EXCLUDE_PATHS']
  ENV['EXCLUDE_PATHS'].split(':')
else
  [
    ".onceover/**/*",
    "bundle/**/*",
    "modules/**/plans/*",
    "pkg/**/*.pp",
    "site-modules/**/plans/*",
    "site/**/plans/*",
    "site/*/spec/**/*",
    "spec/**/*.pp",
    "vendor/**/*",
  ]
end

PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.send('relative')
PuppetLint.configuration.send('disable_140chars')
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.send('disable_documentation')
PuppetLint.configuration.ignore_paths = exclude_paths

PuppetSyntax.exclude_paths = exclude_paths
PuppetSyntax.check_hiera_keys = true

ps_hieradata_paths = [
  "data/*.yaml",
  "data/**/*.yaml",
  "hieradata/**/*.yaml",
  "hiera*.yaml",
]

yl_paths = %w(
  *.yml
  *.yaml
  data/*.yaml
  data/**/*.yaml
  hieradata/**/*.yml
  hieradata/**/*.yaml
)

if File.file?('spec/testing.yaml')
  ps_hieradata_paths.push('spec/testing.yaml')
  yl_paths.push('spec/testing.yaml')
end

PuppetSyntax.hieradata_paths = ps_hieradata_paths

YamlLint::RakeTask.new do |yamllint|
  yamllint.paths = yl_paths
  yamllint.exclude_paths = exclude_paths
end

Rake::Task[:spec_prep].enhance [:generate_fixtures]

# Pull in the ra10ke rake tasks
Ra10ke::RakeTask.new

desc "Run tests"
task :run_tests do
  print "Executing Lint Test...\n"
  Rake::Task[:lint].execute
  print "  -> Success!\n\n"

  print "Executing Syntax Test...\n"
  Rake::Task[:syntax].execute
  print "  -> Success!\n\n"

  print "Executing r10k(Puppetfile) Syntax Test...\n  -> "
  Rake::Task['r10k:syntax'].execute
  print "\n"

  print "Checking for missing spec tests...\n"
  Rake::Task[:check_for_spec_tests].execute
  print "  -> No missing tests!\n\n"

  print "Launching rspec tests...\n"
  Rake::Task[:spec].execute
end

desc "Generate Fixtures files for role/profile"
task :generate_fixtures do
  print "Generating Fixtures..."
  build_fixtures(File.dirname(__FILE__))
  print "Done!\n"
end

desc "Generate spec tests for missing classes"
task :generate_spec_tests do
  spec_gen(true)
end

desc "Get spec test status"
task :check_for_spec_tests do
  spec_gen
end

desc "Show PE Only Modules"
task :pe_only_mods do
  puts get_pe_modules
end

def get_pe_modules
  # Query Puppet Forge for the latest list of PE-only modules
  # Thanks to dan-wittenberg for the original logic on this!
  modules = {}

  url="https://forgeapi.puppetlabs.com/v3/modules?module_groups=pe_only"
  r = RestClient.get url, { :accept => 'application/json', :charset => 'utf-8' }

  JSON.parse(r.force_encoding("UTF-8"))['results'].each do |x|
    name = x['current_release']['metadata']['name'].gsub('/','-')
    modules[name] = "git@github.com:puppetlabs/#{name}.git"
  end

  modules
end

def spec_gen(create=false)
  exit_code = 0
  ['role','profile'].each do |m|
    # For role or profile, find all the classes
    classes = Array.new

    pattern = 'site/profile/manifests/*/*.pp' if m == 'profile'
    pattern = 'site/role/manifests/*/*.pp' if m == 'role'
    Dir.glob("#{pattern}").each do |f|
      File.open(f).read.each_line do |l|
        c = l.scan(/(\s+)?class\s+([a-zA-Z:_]+)\s+[\{,\(]/)
        # Add this class to the classes array
        classes.push(c[0][1]) if !c.empty?
      end
    end

    # For each class, see if a spec file exists - using naming convention
    # <class>_<subclass>[_<subclass>_]_spec.rb
    classes.each do |c|
      spec_file = "#{File.dirname(__FILE__)}/spec/classes/#{m}/#{c.split('::').join('_')}_spec.rb"

      # If no spec file exists, create a blank should compile test file
      if File.exists?(spec_file)
        puts "Class #{c} - Spec file already exists at #{spec_file}!" if create == true
      else
        if create == true
          puts "Class #{c} - Creating... #{spec_file}!"
          File.open(spec_file, 'w') do |f|
            f.write evaluate_template('spec_template.rb.erb',binding)
          end
        else
          puts "Class #{c} - Spec file missing!"
          exit_code = 1
        end
      end
    end
  end

  if exit_code != 0
    raise(exit_code)
  end
end

# Most of this logic was lifted from onceover (comments and all) - thank you!
# https://github.com/dylanratcliffe/onceover/blob/98811bee7bf373e1a22706d98f9ccc1360aff482/lib/onceover/controlrepo.rb
def evaluate_template(template_name,bind)
  template_dir = File.expand_path('./scripts',File.dirname(__FILE__))
  template = File.read(File.expand_path("./#{template_name}",template_dir))
  ERB.new(template, nil, '-').result(bind)
end

def build_fixtures(controlrepo)
  # Load up the Puppetfile using R10k
  puppetfile = R10K::Puppetfile.new(controlrepo)
  fail 'Could not load Puppetfile' unless puppetfile.load
  modules = puppetfile.modules

  # Store PE Only Mods list
  pe_only = get_pe_modules

  # Iterate over everything and seperate it out for the sake of readability
  symlinks = []
  forge_modules = []
  repositories = []

  modules.each do |mod|
    # This logic could probably be cleaned up. A lot.
    if mod.is_a? R10K::Module::Forge
      if mod.expected_version.is_a?(Hash)
        # Set it up as a symlink, because we are using local files in the Puppetfile
        symlinks << {
          'name' => mod.name,
          'dir' => mod.expected_version[:path]
        }
      elsif mod.expected_version.is_a?(String)

        # Verify if this is a PE mod or not
        # if it is a PE only module; we need to set it up as a git repo for fixtures b/c of license issues
        if pe_only.keys.include?(mod.title.gsub('/','-'))
          # Its PE Only
          repositories << {
            'name' => mod.name,
            'repo' => mod.instance_variable_get(:@remote) =~ /\.git/ ? mod.instance_variable_get(:@remote) : pe_only[mod.title],
            # ^^ This isn't perfect, as some of the repo names don't match - but its a start
            'ref' => mod.expected_version
          }
        else
          # Set it up as a normal forge module
          forge_modules << {
            'name' => mod.name,
            'repo' => mod.title,
            'ref' => mod.expected_version
          }
        end

      end
    elsif mod.is_a? R10K::Module::Git
      # Set it up as a git repo
      repositories << {
          'name' => mod.name,
          'repo' => mod.instance_variable_get(:@remote),
          'ref' => mod.version
        }
    end
  end

  symlinks << {
    'name' => "profile",
    'dir'  => '"#{source_dir}/site/profile"',
  }

  symlinks << {
    'name' => "role",
    'dir'  => '"#{source_dir}/site/role"',
  }

  symlinks << {
    'name' => "manifests",
    'dir'  => '"#{source_dir}/manifests"',
  }

  File.open("#{File.dirname(__FILE__)}/.fixtures.yml",'w') do |f|
    f.write evaluate_template('fixtures.yml.erb',binding)
  end
end


