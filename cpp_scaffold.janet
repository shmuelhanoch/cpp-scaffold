(import spork/argparse)
(import spork/path)

(defn- mkdir-p
  "Recursively ensure a directory path exists with robust error checking."
  [dir]
  (def [ok err]
    (protect
      (do
        (def parts (path/parts dir))
        (var current "")
        (each p parts
          (set current (if (empty? current) p (path/join current p)))
          (when (and (not= current "") 
                     (not= current ".") 
                     (not= current "/") 
                     (not (os/stat current)))
            (os/mkdir current))))))
  (unless ok
    (unless (os/stat dir)
      (error (string/format "Failed to create directory '%s': %s" dir err)))))

(defn- safe-slurp
  "Reads a file safely, returning nil and printing an error if reading fails."
  [path]
  (def [ok res] (protect (slurp path)))
  (if ok
    res
    (do
      (file/write stderr (string/format "  [ERROR] Could not read template '%s': %s\n" path res))
      nil)))

(defn- safe-spit
  "Writes to a file safely, raising an explicit error on permission or disk write failures."
  [path content]
  (def [ok err] (protect (spit path content)))
  (unless ok
    (error (string/format "Failed to write file '%s': %s" path err))))

(defn- strip-template-headers
  "Removes template header/metadata lines starting with @@."
  [content]
  (def lines (string/split "\n" (string/replace-all "\r\n" "\n" content)))
  (def clean-lines 
    (filter (fn [line] 
              (not (string/has-prefix? "@@" (string/triml line)))) 
            lines))
  (string/join clean-lines "\n"))

(defn- interpolate
  "Replace template placeholder specifiers with actual parameters."
  [content lib-name cxx-std]
  (->> content
       (string/replace-all "%1$s" lib-name)
       (string/replace-all "%2$s" cxx-std)
       (string/replace-all "@LIB_NAME@" lib-name)
       (string/replace-all "@CXX_STD@" cxx-std)))

(defn- process-file
  "Copies or interpolates a template file to its destination with error containment."
  [src-path dest-path lib-name cxx-std interpolate?]
  (if-not (os/stat src-path)
    (file/write stderr (string/format "  [SKIP] Template missing: %s\n" src-path))
    (let [[ok err]
          (protect
            (do
              (mkdir-p (path/dirname dest-path))
              (when-let [raw-content (safe-slurp src-path)]
                (def clean-content (strip-template-headers raw-content))
                (def output-content (if interpolate? 
                                      (interpolate clean-content lib-name cxx-std) 
                                      clean-content))
                (when (os/stat dest-path)
                  (file/write stderr (string/format "  [WARNING] Overwriting existing file: %s\n" dest-path)))
                (safe-spit dest-path output-content)
                (print (string/format "  [CREATED] %s" dest-path)))))]
      (unless ok
        (file/write stderr (string/format "  [FAILED] Could not create '%s': %s\n" dest-path err))))))

(defn- validate-lib-name
  "Ensure the library name is a valid project identifier."
  [name]
  (if (and name (string? name) (not (empty? name)) (nil? (string/find " " name)))
    true
    (do
      (file/write stderr (string/format "Error: Invalid project name '%s'. Name cannot be empty or contain spaces.\n" (or name "")))
      false)))

(defn main [& args]
  (def [ok err]
    (protect
      (do
        (def opts
          (argparse/argparse
            "Scaffold a modern C++ header-only library project."
            "name" {:kind :option
                    :short "n"
                    :help "Library project name"}
            "dir" {:kind :option
                   :short "d"
                   :help "Target directory where project folder will be created"}
            "cxx-std" {:kind :option
                       :default "23"
                       :help "C++ standard (e.g., 20, 23)"}
            "templates" {:kind :option
                         :default "templates"
                         :help "Path to templates directory"}))

        (unless opts
          (os/exit 1))

        (def raw-default (opts :default))
        (def pos-name (if (and (indexed? raw-default) (not (empty? raw-default)))
                        (first raw-default)
                        nil))

        (def lib-name (or (opts "name") pos-name))

        (unless (and lib-name (validate-lib-name lib-name))
          (file/write stderr "Error: Missing project name. Pass <NAME> positional argument or -n/--name <NAME>.\n")
          (os/exit 1))

        (def target-dir (opts "dir"))
        (def out-dir (if target-dir
                       (path/join target-dir lib-name)
                       lib-name))

        (def cxx-std (opts "cxx-std"))
        (def templates-dir (opts "templates"))

        (unless (os/stat templates-dir)
          (file/write stderr (string/format "Error: Template directory '%s' does not exist.\n" templates-dir))
          (os/exit 1))

        (def mappings
          [["CMakeLists.txt" "CMakeLists.txt" true]
           ["test_CMakeLists.txt" (path/join "tests" "CMakeLists.txt") true]
           ["clang-format" ".clang-format" false]
           ["clang-tidy" ".clang-tidy" false]
           ["envrc" ".envrc" false]
           ["flake.nix" "flake.nix" true]
           ["lib_header.hpp" (path/join "include" lib-name (string lib-name ".hpp")) true]
           ["test_main.cpp" (path/join "tests" "main.cpp") true]
           ["README.md" "README.md" true]])

        (print (string/format "Scaffolding C++ library project '%s' in '%s'..." lib-name out-dir))

        (each [src-file dest-rel is-temp] mappings
          (def src-path (path/join templates-dir src-file))
          (def dest-path (path/join out-dir dest-rel))
          (process-file src-path dest-path lib-name cxx-std is-temp)))))

  (unless ok
    (file/write stderr (string/format "\nFatal Error: %s\n" err))
    (os/exit 1)))
