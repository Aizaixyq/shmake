#include "sh_string.hpp"
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
    system("printf \"shmake version: \\e[35m0.43.11\\e[0m\n\"");
}

void print_help(){
    const std::string help = R"(shmake version: 0.43.11

Usage: $\e[36mshmake [Actions] [options] [target]\e[0m

Actions:
    \e[35mcreate         \e[0mCreate a new sh.sh file. (Project name)
    \e[35mr, run         \e[0mRun the project target. (Project name)
    \e[35mb, build       \e[0mBuild all targets if no given tasks. (file name)
    \e[35mc, clean       \e[0mRemove all binary and temporary files.
    \e[35m-v, version    \e[0mShow your shmake tool version.

Command options (build):
    \e[32m-r, --rebuild  \e[0mRebuild the target.
    \e[32m-j, --jobs     \e[0mSet the number of parallel compilation jobs. (default: 16)
    \e[32m-a, --all      \e[0mBuild all targets.
                    Will rename the default file(sh.sh) to sh*.sh
        \e[32mtarget     \e[0mRename the default file (sh.sh)
)";
    system(("printf \"" + help + "\"").data());
}