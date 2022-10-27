## Sleep()

**实现一个sleep函数，它可以模拟UNIX中sleep的功能，括号里的参数是时间片(ticks)，是计算机中对时间的一种计量单位**

调用 sleep()函数，atoi()把字符串转换成整型数的一个函数.

```c
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc,char *argv[])
{
    char* tickCount=argv[1];
    if(argc==2)
    {
        sleep(atoi(tickCount));
    }
    if(argc==1)
    {
        printf("Error: no enough arguments with sleep\n");
        exit(1);
    }
    if(argc>2)
    {
        printf("Warning:arguments overflow\n");
    }
    exit(0);

}
```

## pingpong()

**编写一个程序，使用UNIX系统调用“pingpong”，在两个进程之间传递一个字节，每个方向一个(父子方向各一个)。父节点应该将一个字节发送给子节点。子节点应该打印“<pid>：接收ping”，其中<pid>是其进程ID，将pipe上的字节写入父节点，然后退出；父节点应该从子节点读取字节，打印“<pid>：接收pong”，然后退出。**

此题目用到了pipe这个管道，而pipe则是一块带有2个文件描述符的缓冲区域，一个文件描述符用来读取，而另一个用来写入，由pipe(int *p)来初始化，其中p是一个int类型的长度为2的数组，其可用于进程间的通信。

```c
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
int main(int argc,char *argv[])
{
    if (argc>1)
    {
      printf("Warning:no argument needed");
      exit(1);
    }
    
    int p[2];
    pipe(p);  
    if (fork()==0)
    {
        if(read(p[0],0,1)==1)
        {

            printf("%d: received ping\n",getpid());
        }
        write(p[1]," ",1);
        close(p[0]);
        close(p[1]);
        exit(0);  
    }
    
    else{
        write(p[1]," ",1);
         wait(0);
        if(read(p[0],0,1)==1)
        {
            printf("%d: received pong\n",getpid());
        }
        close(p[0]);
        close(p[1]);
        exit(0);
    }
    
}
```

写的时候发现，read 里的buffer为空地址也不会报错

```c
read(p[0],0,1)
```

**在这里困惑比较久的是，pipe所分配的文件描述符在传输时该怎么用，事实上，不管进程是父进程还是子进程，往往都选择同一个文件描述符来读，而另一个来写**，如题解中所示，父进程和子进程都是，p[0]用于读取，而p[1]用于写入。（一方写入，再由另一方读取）

## primes()

**使用管道编写一个并发版本的素筛（prime sieve）。**

具体的素筛流程如图：

![image-20221024213042630](C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221024213042630.png)

将2-35(题目要求)由单个主进程放入管道，每个数字都由一个新进程通过该管道读取，并且如果有需要，就会由另外一个管道传递到下一个新进程中进行下一轮筛查。每一轮筛查的指标是去mod该轮最小的质数，如果得到的结果为0就drop，如果是当前最小质数，则输出。

该题目的难点是要意识到要主动使用pipe传输数据，而不是为了筛查使用而使用。一些你想在进程间传输的变量数据，都可以另起一个pipe来传递。

还有比较重要的一点是read()函数，该函数只有在不可能再从pipe的另一端得到数据的情况下被调用才会返回0，即，要么pipe中的buffer没有数据了，或者要么write一端的fd都关闭了，不然不会返回0。题目中暗示的一点是，当你子进程写入数据，将WriteFd关闭后，又在父进程关闭WriteFd后，如果管道里还有数据，则不会返回0，如果没有数据，则会返回0,。该点可以用来区分，数据是被drop,printf还是被传递到下一进程用于筛选。

其中还有一个知识点，当你在父进程创建pipe的描述符时，在你fork过后的复制的描述符，指向的是同一个管道，所以父子进程在都将write关闭的情况下才会有read返回0的可能性，只在一方关闭是不会返回0的。

```c
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
```

## find()

**编写一个具有特定名称的UNIX find()程序的简单版本：找到目录树(Entry Tree)中的所有文件。**

需要注意的是每个目录下的头2个条目（entry）是 ‘ . ’和'  .. '即当前目录和父目录，由于我们是采用==递归方法==由当前目录向下寻找，所以该两条Entry我们并不需要考虑。<img src="C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221025153120713.png" alt="image-20221025153120713" style="zoom:67%;" />

上述代码即为排除不考虑父级目录（..），

<img src="C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221025153253831.png" alt="image-20221025153253831" style="zoom:67%;" />

上述代码为排除不考虑(.)。

再描述一遍该函数执行流程，最先先将路径与需要找到的文件名写入递归函数。<img src="C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221025153822705.png" alt="image-20221025153822705" style="zoom:50%;" />

随后打开路径名的文件，读取其状态（fstat或stat）<img src="C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221025153909770.png" alt="image-20221025153909770" style="zoom:50%;" />

根据其状态，判断该文件类型，若为文件则比较其名字；若为目录，则读取该文件内容名，得到其目录条目，条目的长度题目已给出，即<img src="C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221025154105356.png" alt="image-20221025154105356" style="zoom:50%;" />

在讲该条目通过判断是不是' . '与‘ .. ’后再传入该递归函数。



```c
#include "kernel/types.h" 
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
char *fmtname(char *path) {
    static char buf[DIRSIZ + 1];
    char *p;

    for (p = path + strlen(path); p >= path && *p != '/'; p--);
    p++;

    if (strlen(p) >= DIRSIZ) {
        return p;
    }

    memmove(buf, p, strlen(p));
    memset(buf + strlen(p), 0, DIRSIZ - strlen(p));

    return buf;
}//将路径中最底层的那一级内容提出并返回。

void search(char *path, const char *file) {

    if (strcmp(fmtname(path), "..") == 0) {
        return;
    }

    char buf[512], *p;
    int fd;
    struct dirent de;
    struct stat st;

    if ((fd  = open(path, 0)) < 0) {
        fprintf(2, "find: cannot open %s\n", path);
        exit(1);
    }

    if (fstat(fd, &st) < 0) {
        fprintf(2, "find: cannot stat %s\n", path);
        close(fd);
        exit(1);
    }

    switch (st.type) {
        case T_FILE:
            if (strcmp(file, fmtname(path)) == 0) {
                fprintf(1, "%s\n", path);
            }
            break;
        case T_DEVICE:
            if (strcmp(file, fmtname(path)) == 0) {
                fprintf(1, "%s\n", path);
            }
            break;
        case T_DIR:
            if (strlen(path) + 1 + DIRSIZ + 1 > sizeof(buf)) {
                fprintf(2, "find: path too long\n");
                close(fd);
                exit(1);
            }

            strcpy(buf, path);

            p = buf + strlen(buf);

            *p++ = '/';

            while (read(fd, &de, sizeof(de)) == sizeof(de)) {
                if (de.inum == 0) {
                    continue;
                }

                memmove(p, de.name, DIRSIZ);
                p[DIRSIZ] = 0;

                struct stat prest;

                if (stat(buf, &prest) < 0) {
                    fprintf(2, "find: cannot stat %s\n", p);
                    continue;
                }

                if (st.ino == prest.ino) {
                    continue;
                }

                search(buf, file);
            }

            break;
        default:
            break;
    }

    close(fd);
}

int main(int argc, char *argv[]) {

    if (argc < 2 || argc > 3) {
        fprintf(2, "Usage: find <filename>\n");
        exit(1);
    }

    search(argv[1], argv[2]);

    exit(0);
}
```



## xargs()

**编写一个UNIX xargs程序的简单版本：它的参数描述一个要运行的命令，它从标准输入（stdin）中读取行，并为每一行运行命令，将该行附加到命令的参数中。**

Exp:

```shell
$ echo hello too | xargs echo bye
    bye hello too
```

请注意，这里的命令是“echo bye”，附加的参数是“hello too”，促使产生命令“echo bye hello too”，也就是会产生输出“bye hello too”。

该函数的思路是，先将标准输入里的buffer进行处理，题目中的要求为pipe左边的命令行可能为多行的，所以要按行处理，进行了while循环。这里的难点在于处理字符串，在这里我首次搞懂了，<img src="C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221025155222473.png" alt="image-20221025155222473" style="zoom: 67%;" />该声明不为二维数组，其只是字符指针，它只有在malloc过后会成为一种抽象的二维数组。因此不能直接采用:

```c
strcpy(arg[i],buf);
```

的形式赋值传递，因为左边的arg[ i ]为空指针，这样做是无效的。正确的其中一种做法是将arg[ i ]数组都指向同一个很长的buffer，然后依次储存，如图所示：

<img src="C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221025155656236.png" alt="image-20221025155656236" style="zoom:67%;" />

在每一行的命令参数都传递到arg[  ]中过后，再用memset清零buffer后进行下一行的参数读取。

这里要注意，在argv[ ]中任然有参数需要读取，而且根据题目要求，需要放在*arg[ ]的最前面，即为最前面的参数。

最后对于每一行的命令执行，调用exec()函数执行对应命令，该命令被放于该xarg函数同一父目录下，所以直接写入文件名就行了。（例如：echo hello命令，只需要把echo作为exce的路径参数就可以了，因为echo是xarg函数文件同一父目录下的函数文件）

```c
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
    exit(0);
}
```

