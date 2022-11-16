#include "error.hpp"
#include "shmake.hpp"
#include <cstdio>
#include <stdlib.h>

int error(int status) {
    if (status == -1 || !WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        task("printf \"\\e[31m\"", false);
        if (status == -1)
            printf("system error!\n");

        else if (WIFEXITED(status))
            printf("exit status = %d\n", WEXITSTATUS(status));

        else if (WEXITSTATUS(status) != 0)
            printf("run shell script fail, script exit code: %d\n",
                       WEXITSTATUS(status));

        printf("run error: [0x%x] [%d] [%d]\n", status, WIFEXITED(status),
                   WEXITSTATUS(status));
        task("printf \"\\e[0m\"", false);
        return 0;
    }
    return 1;
}