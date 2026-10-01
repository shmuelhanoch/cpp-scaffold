(declare-project
  :name "cpp-scaffold"
  :description "Scaffold modern C++ header-only library projects"
  :dependencies ["https://github.com/janet-lang/spork.git"
                 "https://github.com/ianthehenry/judge.git"])

(declare-executable
  :name "cpp-scaffold"
  :entry "cpp_scaffold.janet")
