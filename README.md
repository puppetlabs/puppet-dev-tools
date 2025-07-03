# Puppet Dev Tools

![GitHub Actions Build-Test-Push status](https://github.com/puppetlabs/puppet-dev-tools/workflows/Build-Test-Push/badge.svg)
[![Dependabot Status](https://api.dependabot.com/badges/status?host=github&repo=puppetlabs/puppet-dev-tools)](https://dependabot.com)
[![](https://images.microbadger.com/badges/version/puppet/puppet-dev-tools.svg)](https://microbadger.com/images/puppet/puppet-dev-tools "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/puppet/puppet-dev-tools.svg)](https://microbadger.com/images/puppet/puppet-dev-tools "Get your own commit badge on microbadger.com")

## Docker Tags

- `<year>-<month>-<day>-<a short string>`: Each merge to master generates an image tagged with the date of its build followed by a short git SHA. These images are suitable for pinning to if you do not wish to live on the edge with `4.x`. Changes from one image to the next will include things shown in the [commit history](https://github.com/puppetlabs/puppet-dev-tools/commits/master) on GitHub and updated operating system packages pulled in at build time.
- `<year>-<month>-<day>-<a short string>-rootless`: This is just like the tag above but the container runs as a user named `puppetdev`.
- `4.x`: This the tag that is shipped by default in CD4PE. This tag is updated manually from time to time.
- `latest`: This is a legacy tag and not not actually the current build of puppet-dev-tools. It is the build used in older versions of CD4PE (prior to 4.0). These builds are manually created by the CD4PE team.
- `puppet8`: This tag contains tooling updates to support Puppet 8. Use this image if you want to test code that has been updated for Puppet 8. This tag is updated manually from time to time.

## Running

You can use this container by running `docker run --rm -v $(pwd):/repo puppet/puppet-dev-tools <command>` where `<command>` is any of the ones listed below.

## Supported Commands

1. PDK - `pdk`
   - run `docker run --rm puppet/puppet-dev-tools:puppet8 pdk --help` to see builtin help
   - see the [PDK command reference](https://www.puppet.com/docs/pdk/3.x/pdk_reference.html) for details
2. Onceover - `onceover`
   - run `docker run --rm puppet/puppet-dev-tools:puppet8 onceover --help` to see builtin help
   - see [Onceover's readme](https://github.com/dylanratcliffe/onceover/blob/master/README.md) for details
3. Rake tasks from the installed gems (see below)
   - run a single rake task like so: `docker run --rm -v $(pwd):/repo puppet/puppet-dev-tools:puppet8 rake -f /Rakefile lint`
   - run multiple rake tasks sequentially like so: `docker run --rm -v $(pwd):/repo puppet/puppet-dev-tools:puppet8 rake -f /Rakefile lint syntax yamllint`

### A note on Onceover usage

If your control repository contains a Gemfile you will likely want to modify the commands listed above to something like this:

```bash
docker run --rm -v $(pwd):/repo puppet/puppet-dev-tools:puppet8 \
/bin/bash -c "bundle install && bundle exec onceover run spec --force --trace --parallel"
```

<!-- Everything below the Rake Tasks header will be overwritten by build.sh -->

### Rake Tasks

| Command | Description |
| ------- | ----------- |
| rake check  |  Run static pre release checks |
| rake check:dot_underscore  |  Fails if any ._ files are present in directory |
| rake check:git_ignore  |  Fails if directories contain the files specified in .gitignore |
| rake check:symlinks  |  Fails if symlinks are present in directory |
| rake check:test_file  |  Fails if .pp files present in tests folder |
| rake check_for_spec_tests  |  Get spec test status |
| rake compute_dev_version  |  Print development version of module |
| rake generate_fixtures  |  Writes a `fixtures.yml` file based on the Puppetfile / Generate Fixtures files for role/profile |
| rake generate_spec_tests  |  Generate spec tests for missing classes |
| rake help  |  Display the list of available rake tasks |
| rake hiera_setup  |  Modifies your `hiera.yaml` to point at the hieradata relative to its position |
| rake lint  |  Run puppet-lint |
| rake lint_fix  |  Run puppet-lint |
| rake parallel_spec  |  Run spec tests in parallel and clean the fixtures directory if successful |
| rake parallel_spec_standalone  |  Parallel spec tests |
| rake pe_only_mods  |  Show PE Only Modules |
| rake r10k:dependencies  |  Print outdated forge modules |
| rake r10k:deprecation  |  Validate that no forge modules are deprecated |
| rake r10k:diff[branch_a,branch_b]  |  Check for module differences between two branches of a Puppetfile |
| rake r10k:duplicates  |  Check Puppetfile for duplicates |
| rake r10k:install  |  Install modules specified in Puppetfile |
| rake r10k:print_git_conversion  |  Convert and print forge modules to git format |
| rake r10k:solve_dependencies[allow_major_bump]  |  Find missing or outdated module dependencies |
| rake r10k:syntax  |  Syntax check Puppetfile |
| rake r10k:validate  |  Validate the git urls and branches, refs, or tags |
| rake release_checks  |  Runs all necessary checks on a module in preparation for a release |
| rake rubocop  |  Run RuboCop |
| rake rubocop:autocorrect  |  Autocorrect RuboCop offenses (only when it's safe) |
| rake rubocop:autocorrect_all  |  Autocorrect RuboCop offenses (safe and unsafe) |
| rake run_tests  |  Run tests |
| rake spec  |  Run spec tests and clean the fixtures directory if successful |
| rake spec:simplecov  |  Run spec tests with ruby simplecov code coverage |
| rake spec_clean  |  Clean up the fixtures directory |
| rake spec_clean_symlinks  |  Clean up any fixture symlinks |
| rake spec_list_json  |  List spec tests in a JSON document |
| rake spec_prep  |  Create the fixtures directory |
| rake spec_standalone  |  Run RSpec code examples |
| rake strings:generate[patterns,debug,backtrace,markup,json,markdown,yard_args]  |  Generate Puppet documentation with YARD |
| rake strings:generate:reference[patterns,debug,backtrace]  |  Generate Puppet Reference documentation |
| rake strings:gh_pages:update  |  Update docs on the gh-pages branch and push to GitHub |
| rake strings:validate:reference[patterns,debug,backtrace]  |  Validate the reference is up to date |
| rake syntax  |  Syntax check for Puppet manifests, templates and Hiera |
| rake syntax:hiera  |  Syntax check Hiera config files |
| rake syntax:manifests  |  Syntax check Puppet manifests |
| rake syntax:templates  |  Syntax check Puppet templates |
| rake validate  |  Check syntax of Ruby files and call :syntax and :metadata_lint |
| rake yamllint  |  Run yamllint |
