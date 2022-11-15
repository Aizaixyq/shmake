#include "analyze.hpp"
#include "error.hpp"
#include "sh_string.hpp"
#include "shmake.hpp"
#include <cctype>
#include <cstring>
#include <fmt/core.h>
#include <string>

extern int jobs;

bool path_check(char *path){
    int status = 
        system(("~/.shmake/.sh/linux_sh/fun.sh path_check " + std::string(path)).data());
    return error(status);
}

bool isnum(const std::string &x) {
    if (x.size() > 4) {
        return false;
    }
    for (const auto &i : x) {
        if (i < '0' && i > '9') {
            return false;
        }
    }
    return std::stoi(x) <= jobs * 4 && std::stoi(x) >= 1 ? true : false;
}

int analyze(int argc, char *argv[]) {

    std::string r("n"), a("n");
    std::string target{"sh.sh"};
    std::string job{std::to_string(jobs)};
    std::string path{"."};

    for (int i = 1; i < argc; ++i) {
        if (!strcmp(argv[i], "-r") || !strcmp(argv[i], "--rebuild")) {
            r = 'y';
        } 
        
        else if (!strcmp(argv[i], "-a") || !strcmp(argv[i], "--all")) {
            a = 'y';
            if(target == "sh.sh") target = "sh*.sh";
        } 
        
        else if (!strcmp(argv[i], "b") || !strcmp(argv[i], "build")) {
            continue;
        }
        
        else if (!strcmp(argv[i], "-j") || !strcmp(argv[i], "--jobs")) {
            if (i + 1 < argc && isnum(std::string(argv[i + 1]))){
                job = argv[i + 1];
                ++i;
            }
            else
                fmt::print("-j: invalid number\n");
        } 
        
        else if (!strcmp(argv[i], "target")) {
            if (i + 1 < argc){
                target = argv[i + 1];
                ++i;
            }
            else {
                fmt::print("target: name not entered! use default\n");
            }
        } 
        
        else {
            if(path_check(argv[i])){
                path = argv[i];
                continue;
            }
            print_help();
            fmt::print("Invalid arg or path: {}\n", argv[i]);
            return 0;
        }
    }
    int status =
        system(("~/.shmake/.sh/linux_sh/build.sh  \
            " + path +" --rebuild " +
                r + " --all " + a + " --jobs " + job + " --target " + target)
                   .data());
    error(status);
    return 0;
}