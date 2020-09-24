
typedef struct fd_set_ fd_set;
struct timeval;

static int callcount;

int select_dummy(int nfds, fd_set *readfds, fd_set *writefds,
                 fd_set *exceptfds, struct timeval *timeout) {
    (void)nfds;
    (void)readfds;
    (void)writefds;
    (void)exceptfds;
    (void)timeout;

    return 10 - callcount++;
}
