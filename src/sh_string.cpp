#include "sh_string.hpp"
#include "shmake.hpp"
#include <string>

void newsh_fun(std::string &x){
    std::string newsh = R"(sources=()
includedir=()
deps=()
compiler="g++"
)";
    x = newsh;
}

void show_version(){
    task("printf \"shmake version: \\e[35m0.5.1\\e[0m\n\"", false);
}

void print_help(){
    show_version();
    const std::string help = R"(
👉 $\e[36mshmake [Actions] [options] [target]\e[0m

Actions:
    \e[35mcreate         \e[0mCreate a new sh.sh file. (Project name)
    \e[35mr, run         \e[0mRun the project target. (Project name)
    \e[35mb, build       \e[0mBuild all targets if no given tasks. (file name)
    \e[35mc, clean       \e[0mRemove all binary and temporary files.

Command Options:
    \e[35m-v, --version  \e[0mShow your shmake tool version.
    \e[35m-h, --help     \e[0mPrint this help message and exit.

Command options (build):
    \e[32m-r, --rebuild  \e[0mRebuild the target.
    \e[32m-j, --jobs     \e[0mSet the number of parallel compilation jobs. (default: 16)
    \e[32m-a, --all      \e[0mBuild all targets.
                    Will rename the default file(sh.sh) to sh*.sh
        \e[32mtarget     \e[0mRename the default file (sh.sh)
)";
    task(("printf \"" + help + "\"").data(), false);
}