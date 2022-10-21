#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void test(int num);

int main()
{
    int p_left[2], p_right[2];
    int buf, exbuf;
    int a[35], b[35];
    int n, i,cnt=35;
    int num = 2, exnum = num, np = 35, cpNum = num;
    int turn;
    pipe(p_left);
    for (n = 2, i = 0; n < 36; n++, i++)
    {
        b[i] = n;
    }
    while (np > 0)
    {
        pipe(p_right);
        for (n = cpNum, i = 0; i <=cnt; n++, i++)
        {
            a[i] = b[i];
            // printf("ai:%d\n",a[i]);
        }
        n = 0, turn = 1, i = 0;
        while (num <= np)
        {
            // printf("num/ai:%d %d\n", num, a[i]);
            if (num != a[i])
            {
                num++;
                continue;
            }
            if (write(p_left[1], &num, 4) < 0)
            {
                printf("Error:writeFault1\n");
            }
            i++;
            if (fork() == 0)
            {
                // test(1);
                if (read(p_left[0], &buf, 4) < 0)
                {
                    printf("Error:readFault\n");
                }
                // printf("buf/cpNum:%d %d\n", buf, cpNum);
                if (buf % cpNum != 0 && buf)
                {
                    if (write(p_right[1], &buf, 4) < 0)
                    {
                        printf("Error:writeFault\n");
                    }
                    close(p_right[0]);
                    close(p_right[1]);
                    close(p_left[0]);
                    close(p_left[1]);
                    exit(0);
                }
                else if (buf == cpNum)
                {
                    printf("prime %d\n", buf);
                    close(p_right[0]);
                    close(p_right[1]);
                    close(p_left[0]);
                    close(p_left[1]);
                    exit(0);
                }
                else
                {
                    close(p_right[0]);
                    close(p_right[1]);
                    close(p_left[0]);
                    close(p_left[1]);
                    exit(0);
                }
            }
            wait(0);
            // test(3);
            close(p_right[1]);
            if (read(p_right[0], &exbuf, 4) != 0)
            {
                if (turn)
                {
                    exnum = exbuf;
                    turn = 0;
                }
                b[n++] = exbuf;
                printf("n/exbuf:%d %d\n", n - 1, b[n - 1]);
            }
            close(p_right[0]);
            if (num != np)
            {
                pipe(p_right);
            }
            // test(4);
            num++;
            // printf("%d\n",num);
        }
        // test(1);
        if (n != 0)
        {
            np = b[n-1];
            cnt=n-1;
        }
        else
        {
            np = 0;
            cnt=0;
        }
        num = exnum;
        cpNum = num;
    }
    close(p_left[0]);
    close(p_left[1]);
    exit(0);
}
void test(int num)
{
    printf("i'm tesing%d\n", num);
}