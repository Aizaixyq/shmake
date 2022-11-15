#include "error.hpp"
#include <fmt/core.h>

int error(int status) {
    if (status == -1 || !WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        if (status == -1)
            fmt::print("system error!\n");

        else if (WIFEXITED(status))
            fmt::print("exit status = {}\n", WEXITSTATUS(status));

        else if (WEXITSTATUS(status) != 0)
            fmt::print("run shell script fail, script exit code: {}\n",
                       WEXITSTATUS(status));

        fmt::print("run error: [{}] [{}] [{}]\n", status, WIFEXITED(status),
                   WEXITSTATUS(status));
        return 0;
    }
    return 1;
}