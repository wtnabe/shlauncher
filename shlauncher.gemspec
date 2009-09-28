# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{shlauncher}
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["wtnabe"]
  s.date = %q{2009-09-29}
  s.default_executable = %q{tractor}
  s.description = %q{A shell script launcher}
  s.email = %q{wtnabe@gmail.com}
  s.executables = ["tractor"]
  s.extra_rdoc_files = ["README.rdoc", "ChangeLog"]
  s.files = ["README.rdoc", "ChangeLog", "Rakefile", "bin/shlauncher_test", "bin/tractor", "test/script", "test/script/example", "test/script/example.bak", "test/script/example~", "test/script/foo", "test/script/foo/bar", "test/script/foo/bar~", "test/script/foo/baz", "test/script/README", "test/shlauncher_test.rb", "test/tractor_test.rb", "lib/tractor.rb", "templates/bin", "templates/bin/shlauncher", "templates/ChangeLog", "templates/lib", "templates/lib/shlauncher.rb", "templates/Rakefile", "templates/README"]
  s.homepage = %q{}
  s.post_install_message = %q{
Use with zsh. And FOR LINUX USERS, Please be careful with shebang line of tractor'd `bin/exectable'.

}
  s.rdoc_options = ["--title", "shlauncher documentation", "--charset", "utf-8", "--opname", "index.html", "--line-numbers", "--main", "README.rdoc", "--inline-source", "--exclude", "^(examples|extras)/"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{}
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Scaffold your custom launcher. Launch from your shell script ( and also Ruby script ) collection.}
  s.test_files = ["test/shlauncher_test.rb", "test/tractor_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
