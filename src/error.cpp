#include "error.hpp"
#include <cstdio>
#include <stdlib.h>

int error(int status) {
    if (status == -1 || !WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        system("printf \"\\e[31m\"");
        if (status == -1)
            printf("system error!\n");

        else if (WIFEXITED(status))
            printf("exit status = %d\n", WEXITSTATUS(status));

        else if (WEXITSTATUS(status) != 0)
            printf("run shell script fail, script exit code: %d\n",
                       WEXITSTATUS(status));

        printf("run error: [0x%x] [%d] [%d]\n", status, WIFEXITED(status),
                   WEXITSTATUS(status));
        system("printf \"\\e[0m\"");
        return 0;
    }
    return 1;
}