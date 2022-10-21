#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/param.h"
int main(int argc, char *argv[])
{
    char buf[512],exbuf[512];
    char *p = buf, *q = buf, *m = buf, exq;
    char *arg[MAXARG];
    int i = 1;
    arg[0] = exbuf;
    arg[1]=exbuf+1;
    memset(exbuf, 0, strlen(exbuf));
    while (read(0, p, 1) > 0)
    {
         memset(exbuf, 0, strlen(exbuf));
        for (i = 1; i < argc - 1; i++)
        {
            strcpy(arg[i], argv[i + 1]);
            arg[i+1] = exbuf + strlen(arg[i +2]);
        
        }
        if (*p == '\n')
        {
            while ((q - 1) != p)
            {
                while (*q != ' ' && *q != '\n')
                {
                    // printf(" q:%c",*q);
                    q++;
                }
                if (i < MAXARG)
                {
                    exq = *q;
                    *q = 0;
                    // printf("   m/length: %c %d\n",*m,strlen(m));

                    memmove(arg[i], m, strlen(m));
                    // printf("arg[%d]:%s\n",i, arg[i]);
                    i++;
                    arg[i] = exbuf + strlen(m);
                    *q = exq;
                    q++;
                    m = q;
                }
            }
            arg[i]=0;
            // printf("i/argc/arg/argv[1]:%d %d %s %s\n",i,argc,arg[0],argv[1]);
            if (fork() == 0)
            {
                exec(argv[1], arg);
                exit(0);
            }
            wait(0);
        }
        p++;
        memset(exbuf, 0, strlen(exbuf));
    }
    // if (*p == 0)
    // {
    //     while (q != p)
    //     {
    //         while (*q != ' ')
    //         {
    //             q++;
    //         }
    //         if (i < MAXARG)
    //         {
    //             memmove(arg[i++], m, q - m);
    //             q++;
    //             m = q;
    //         }
    //     }
    //     if (fork() == 0)
    //     {
    //         if (strcmp("-n", argv[1]))
    //         {
    //             memmove(cmd, argv[3], strlen(argv[3]));
    //         }
    //         else
    //         {
    //             memmove(cmd, argv[1], strlen(argv[1]));
    //         }
    //         j = argc;
    //         n = 0;
    //         while (n < i && j < MAXARG)
    //         {
    //             strcpy(argv[j++], arg[n++]);
    //         }
    //         if (j != MAXARG)
    //         {
    //             argv[j] = 0;
    //         }
    //         exec(cmd, argv);
    //         exit(0);
    //     }
    //     wait(0);
    //     q++;
    //     m = q;
    // }
    exit(0);
}