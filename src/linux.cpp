#include "analyze.hpp"
#include "error.hpp"
#include "sh_string.hpp"
#include "linux.hpp"
#include <cstdio>
#include <cstring>
#include <fstream>

int task(const char *__command, bool sh){
    if(sh) 
        return system(("~/.shmake/.sh/linux_sh/" + std::string(__command)).data());
    return system(__command);
}

int start(int argc, char *argv[]) {
    if (argc == 1) {
        int status = system("~/.shmake/.sh/linux_sh/build.sh \
            . --rebuild n --all y --jobs 16 --target sh*.sh");
        error(status);
    }

    else {

        if (!strcmp(argv[1], "create")) {
            std::fstream create_sh;
            create_sh.open("sh.sh", std::ios::out);
            if (!create_sh) {
                system("printf \"\\e[31mcreate new sh.sh error\\e[0m\"");
                return 1;
            }

            std::string name{"new"};
            if (argc == 3) {
                name = argv[2];
            }
            std::string sh;
            newsh_fun(sh);
            create_sh << "project=(\"" + name + "\")\n";
            create_sh << sh;
        }

        else if (!strcmp(argv[1], "c") || !strcmp(argv[1], "clear")) {
            int status = system("rm -r ./*");
            error(status);
        }

        else if (!strcmp(argv[1], "-v") || !strcmp(argv[1], "--version")) {
            show_version();
        }

        else if (!strcmp(argv[1], "-h") || !strcmp(argv[1], "--help")) {
            print_help();
        }

        else if (!strcmp(argv[1], "r") || !strcmp(argv[1], "run")) {
            std::string path{"."};
            if(argc > 2)path = argv[2];
            int status = 
                task(("fun.sh run " + path).data(), true);
            error(status);
        }

        else {
            return analyze(argc, argv);
        }
    }
    return 0;
}