# Puppet Dev Tools

![GitHub Actions Build-Test-Push status](https://github.com/puppetlabs/puppet-dev-tools/workflows/Build-Test-Push/badge.svg)
[![Dependabot Status](https://api.dependabot.com/badges/status?host=github&repo=puppetlabs/puppet-dev-tools)](https://dependabot.com)
[![](https://images.microbadger.com/badges/version/puppet/puppet-dev-tools.svg)](https://microbadger.com/images/puppet/puppet-dev-tools "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/puppet/puppet-dev-tools.svg)](https://microbadger.com/images/puppet/puppet-dev-tools "Get your own commit badge on microbadger.com")

## Docker Tags

- `<year>-<month>-<day>-<a short string>`: Each merge to master generates an image tagged with the date of its build followed by a short git SHA. These images are suitable for pinning to if you do not wish to live on the edge with `4.x`. Changes from one image to the next will include things shown in the [commit history](https://github.com/puppetlabs/puppet-dev-tools/commits/master) on GitHub and updated operating system packages pulled in at build time. The latest version of the PDK is also pulled in at build time.
- `4.x`: This the tag that is used in the 4.x versions of CD4PE. This tag is updated manually from time to time.
- `latest`: This is not actually the build of `puppet-dev-tools`, but rather the latest build used in CD4PE < 4.0. These builds are manually created by the CD4PE team.

## Running

You can use this container by running `docker run --rm -v $(pwd):/repo puppet/puppet-dev-tools <command>` where `<command>` is any of the ones listed below.

## Supported Commands

1. PDK - `pdk`
   - run `docker run --rm puppet/puppet-dev-tools:4.x pdk --help` to see builtin help
   - see the [PDK command reference](https://puppet.com/docs/pdk/1.x/pdk_reference.html) for details
2. Onceover - `onceover`
   - run `docker run --rm puppet/puppet-dev-tools:4.x onceover --help` to see builtin help
   - see [Onceover's readme](https://github.com/dylanratcliffe/onceover/blob/master/README.md) for details
3. Rake tasks from the installed gems (see below)
   - run a single rake task like so: `docker run --rm -v $(pwd):/repo puppet/puppet-dev-tools:4.x rake lint`
   - run multiple rake tasks sequentially like so: `docker run --rm -v $(pwd):/repo puppet/puppet-dev-tools:4.x rake lint syntax yamllint`

### A note on Onceover usage

If your control repository contains a Gemfile you will likely want to modify the commands listed above to something like this:

```bash
docker run --rm -v $(pwd):/repo puppet/puppet-dev-tools:latest \
/bin/bash -c "bundle install && bundle exec onceover run spec --force --trace --parallel"
```

<!-- Everything below the Rake Tasks header will be overwritten by build.sh -->

### Rake Tasks

| Command | Description |
| ------- | ----------- |
| rake beaker  |  Run beaker acceptance tests |
| rake beaker:sets  |  List available beaker nodesets |
| rake beaker:ssh[set,node]  |  Try to use vagrant to login to the Beaker node |
| rake build  |  Build puppet module package |
| rake build:pdk  |  Build Puppet module with PDK |
| rake build:pmt  |  Build Puppet module package with PMT (Puppet < 6.0.0 only) |
| rake check  |  Run static pre release checks |
| rake check:dot_underscore  |  Fails if any ._ files are present in directory |
| rake check:git_ignore  |  Fails if directories contain the files specified in .gitignore |
| rake check:symlinks  |  Fails if symlinks are present in directory |
| rake check:test_file  |  Fails if .pp files present in tests folder |
| rake check_for_spec_tests  |  Get spec test status |
| rake clean  |  Clean a built module package |
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
| rake r10k:duplicates  |  Check Puppetfile for duplicates |
| rake r10k:install  |  Install modules specified in Puppetfile |
| rake r10k:solve_dependencies[allow_major_bump]  |  Find missing or outdated module dependencies |
| rake r10k:syntax  |  Syntax check Puppetfile |
| rake r10k:validate  |  Validate the git urls and branches, refs, or tags |
| rake release_checks  |  Runs all necessary checks on a module in preparation for a release |
| rake rubocop  |  Run RuboCop |
| rake rubocop:auto_correct  |  Auto-correct RuboCop offenses |
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
| rake syntax  |  Syntax check Puppet manifests and templates |
| rake syntax:hiera  |  Syntax check Hiera config files |
| rake syntax:manifests  |  Syntax check Puppet manifests |
| rake syntax:templates  |  Syntax check Puppet templates |
| rake validate  |  Check syntax of Ruby files and call :syntax and :metadata_lint |
| rake yamllint  |  Run yamllint |
