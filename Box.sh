dependency "test"
as "hey"
src tarball "https://example.com/tarball.tar.gz"
install script: "./script.sh"

return 1

dependency "bake"
src git "https://github.com/hyperupcall/bake"
install bin: "./bake"
