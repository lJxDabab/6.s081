## Using gdb

调用gdb,该实验建议用双窗口来调试，一个窗口用于输入shell命令，一个窗口用于gdb调试。该实验因为一些安全问题需要单独配置文件(在输入gdb时有文件内容告知)，并且采用gdb-mutiarch命令才能成功调用gdb。

```shell
layout src //用于打开当前运行代码行的上下文代码
```

```shell
backtrace//用于查看当前用户栈
```

```shell
p /x $sstatus//查看寄存器: p /x $。。。
```

一些寄存器包含了程序运行的一些信息，详细见riscv-privileged-20211203.pdf。

> Q:Looking at the backtrace output, which function called syscall? 
> A: argaddr();
>
> Q:What is the value of p->trapframe->a7 and what does that value represent? (Hint: look user/initcode.S, the first user program xv6 starts.) 
> A: 0x7;the order number of the sys_exec in syscall function table to get the corresponding function address(a7装着各种系统调用的号码，用于在系统调用表里查找)
>
> Q:What was the previous mode that the CPU was in? 
> A: user mode//这里可以查看mstatus或sstatus，在陷入trap前的模式在其中第9位，不包含机器模式，机器模式只在最初,在riscv-privileged-20211203.pdf中查看到mstatus是sstatus的兼容版本。
>
> Q:Write down the assembly instruction the kernel is panicing at. Which register corresponds to the varialable num?
> A:num = *(int *)0; a3//这个显而易见的在代码的改动处能看到
>
> Q:Why does the kernel crash? Hint: look at figure 3-3 in the text; is address 0 mapped in the kernel address space?\ 
> Is that confirmed by the value in scause above? (See description of scause in RISC-V privileged instructions) 
> A:it trys to access 0x0 which is not in kernel but contains I/O devices;it is confirmed by  the value in scause above,\
> scause is written with a code indicating the event that caused the trap.Otherwise, scause is never written by the\
> implementation, though it may be explicitly written bysoftware.
>
> Q:What is the name of the binary that was running when the kernel paniced? What is its process id (pid)? 
> A:initcode(),1

## System call tracing

**在此任务中，您将添加一个系统调用跟踪(trace)功能，它可以帮助您调试以后的实验。您将创建一个新的跟踪系统调用来控制跟踪。它应该采用一个参数，一个整数“掩码”(mask)，它的位指定要跟踪的哪个系统调用。例如，为了跟踪fork系统调用，一个程序调用跟踪（1 << SYS_fork），其中SYS_fork是来自kernel/syscall.h的syscall数字。如果系统调用的数字已经被记录为掩码(mask)(当然，如果没有被记录就报错)，则必须修改xv6内核，以便在每个系统调用即将返回（return）时打印出一行。该行应该包含进程Id、系统调用的名称和返回值；您不需要打印系统调用参数。跟踪系统调用应该替调用它的进程以及它随后fork的任何子进程启用跟踪，但不应该影响其他进程。**

### 一些自己需要注意的点：

#### **思路**：

我们这里写的是系统调用，而不是shell命令函数，因此user/trace.c已经被写好，我们需要关注的是它之下的系统调用函数该怎么写。让我们先来理清楚它调用的大体思路（部分技术不甚了解，但是知道大体逻辑）。首先我们得添加 $U/_trace 到Makefile里，不然无法执行trace 的shell命令，同时我们需要在user.h中添加trace的函数原型<img src="C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221027200121099.png" alt="image-20221027200121099" style="zoom: 80%;" />

之后，我们在usys.pl文件中添加trace的entry![image-20221027200326922](C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221027200326922.png)

![image-20221027200420908](C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221027200420908.png)

该文件最后生成usys.S文件如下图所示，应该用于汇编的系统调用的代码的快速生成，通过该ecall能进入到内核中

![image-20221027200511904](C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221027200511904.png)

再之后，我们要修改sysproc.c文件，该文件为我们系统调用的真正函数位置，sys_trace也写在该位置。

![image-20221027201911117](C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221027201911117.png)

最后我们进行trace的代码在syscall.c与syscall.h里进行修改，首先需要syscall.h添加系统调用号![image-20221027201134268](C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221027201134268.png)

，随后在syscall.c进行筛查：

```c
#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "syscall.h"
#include "defs.h"

// Prototypes for the functions that handle system calls.
extern uint64 sys_fork(void);
extern uint64 sys_exit(void);
extern uint64 sys_wait(void);
extern uint64 sys_pipe(void);
extern uint64 sys_read(void);
extern uint64 sys_kill(void);
extern uint64 sys_exec(void);
extern uint64 sys_fstat(void);
extern uint64 sys_chdir(void);
extern uint64 sys_dup(void);
extern uint64 sys_getpid(void);
extern uint64 sys_sbrk(void);
extern uint64 sys_sleep(void);
extern uint64 sys_uptime(void);
extern uint64 sys_open(void);
extern uint64 sys_write(void);
extern uint64 sys_mknod(void);
extern uint64 sys_unlink(void);
extern uint64 sys_link(void);
extern uint64 sys_mkdir(void);
extern uint64 sys_close(void);
extern uint64 sys_trace(void);
extern uint64 sys_sysinfo(void);

// An array mapping syscall numbers from syscall.h
// to the function that handles the system call.
static uint64 (*syscalls[])(void) = {
[SYS_fork]    sys_fork,
[SYS_exit]    sys_exit,
[SYS_wait]    sys_wait,
[SYS_pipe]    sys_pipe,
[SYS_read]    sys_read,
[SYS_kill]    sys_kill,
[SYS_exec]    sys_exec,
[SYS_fstat]   sys_fstat,
[SYS_chdir]   sys_chdir,
[SYS_dup]     sys_dup,
[SYS_getpid]  sys_getpid,
[SYS_sbrk]    sys_sbrk,
[SYS_sleep]   sys_sleep,
[SYS_uptime]  sys_uptime,
[SYS_open]    sys_open,
[SYS_write]   sys_write,
[SYS_mknod]   sys_mknod,
[SYS_unlink]  sys_unlink,
[SYS_link]    sys_link,
[SYS_mkdir]   sys_mkdir,
[SYS_close]   sys_close,
[SYS_trace]   sys_trace,
[SYS_sysinfo] sys_sysinfo,
};
void
syscall(void)
{
  int num;
  char name[MAXLEN];
  struct proc *p = myproc();
  num = p->trapframe->a7;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    p->trapframe->a0 = syscalls[num]();
    if(p->turn&(1<<num))
    {
      memset(name,0,sizeof(name));
      switch (num)
      {
      case 1:
       strncpy(name,"fork",4);
        break;
     	//......
        case 18:
       strncpy(name,"unlink",6);
        break;
       
        case 22:
       strncpy(name,"trace",5);
        break;
        case 23:
       strncpy(name,"sysinfo",7);
        break;
      }
    printf("%d: syscall %s -> %d\n",p->pid,name,p->trapframe->a0); 
    }
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0

  } else {
    printf("%d %s: unknown sys call %d\n",
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
  }
}

```

**在该文件的解读中我发现了C语言数组另一种编写格式：**

```c
int a[20]={
    [x]   xxxx
        ...
      
}
```



#### 其中[x]中表示该数组下标，xxxx表示对应的值。

```c
(*syscalls[])(void)
```

而上述写法则是函数指针数组的写法，[ ]中对应的值为该数组的索引，可以找到对应函数的地址值，再用()进行函数调用。

因此，每当我们进行系统调用时，会先从usys.S文件对应入口进入内核，随后调用syscall.c函数（可以发现syscall.c中有在usys.S写入的p->...a7,在usys.S中,还要去连接syscall.h里的头文件。![image-20221027203118114](C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221027203118114.png))

最后在syscall里调用对应函数![image-20221027203523736](C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221027203523736.png)



### Trace函数实现的反思

题目的有一个暗示要求道，sys_trace的返回值必须是0

![image-20221027203749015](C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221027203749015.png)

因此我们在sys_trace()与syscall()函数中参数的传递依赖与该行代码执行在同一进程下，因此我们可以增添PCB参数并修改进程的PCB中该参数的值(该实验目前学习到的类似模块叫做**proc**,)来达到参数传递的目的。而为了获取参数，我们可以调用该Lab给与的arg...系列参数获取接口函数。

```c
uint64
sys_trace(void)
{
  int sysint;
  argint(0,&sysint);
  acquire(&tickslock);
   myproc()->turn=sysint; //传递参数
   release(&tickslock);
return 0;
}
```

```c
struct proc {
  struct spinlock lock;

  // p->lock must be held when using these:
  enum procstate state;        // Process state
  ......
  int pid;                     // Process ID
  int turn;                     //i'm be insert to handle trace   1111
  struct proc *parent;         // Parent process
 ......
  struct file *ofile[NOFILE];  // Open files
  struct inode *cwd;           // Current directory
  char name[16];               // Process name (debugging)
}
```

随后的代码我们在syscall()函数中处理。

题目要求打印的进程ID和函数返回值都比较简单，在用户PCB中都能获取

```c
 printf("%d: syscall %s -> %d\n",p->pid,name,p->trapframe->a0); 
```

名字是题目中比较难的考点，也有一个比较核心且巧妙的方法进行筛选，即位偏移，代码如下：

```c
num = p->trapframe->a7;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    p->trapframe->a0 = syscalls[num]();
    if(p->turn&(1<<num))  //i'm the key code
```

p->turn是从sys_trace函数里获得的需要追踪的位的集合（ep:111->4+2+1=7）表现为十进制。而num则为当前我需要进行的系统调用号，根据题目中的代码即可判断是否要进行跟踪与打印，而打印对应系统调用的名字，此处选择写一个switch，进行对    调用号->调用名称  的映射关系的维护。

题目中还要求对子进程也要实施跟踪，那么我们只需要在sys_fork函数中将p_turn给复制下来给子进程就好了。

我们在进程初始化时（即procint函数）进行了p->turn的初始化（初始化为0），同时该进程被杀死后，p->turn也不会被带入到下一个进程，在shell中表现的形式则为，每一行的命令如果带有trace并不会在下一行进行追踪。

## Sysinfo

**在此任务中，您将添加一个系统调用sysinfo，它收集有关正在运行的系统的信息。系统调用接收一个参数：一个指向结构体sysinfo的指针（参见kernel/sysinfo.h）。内核应该填写此结构的字段：'freemem'字段应该设置为空闲内存的字节数，nproc字段应该设置为state为UNUSED的进程数。****

对于Sysinfo，我们也需要重复sys_trace函数的路径添加过程，此处就不再赘述。重点讲述笔者在该题目代码写的时候的一些问题反思即提醒。

### Sysinfo的反思与提醒

对于该结构体中2个成员值的获取，我采取简单赘述：

```c
FreememGet(void)
{
    uint64 i=0;
    struct run *r;
    acquire(&kmem.lock);
  for(r=kmem.freelist;r;r=r->next)
  {
      i+=4096;
  }
  release(&kmem.lock);
  return i;
}
```

对于freemem值的获取，我们只需要在它自身所给的freelist(空闲块的列表)遍历到底就行了。（每个块大小为4096）

```c
uint64 
proc_NumGet(void)
{
  struct proc *p;
  uint64 i;
  for(p = proc,i=0; p < &proc[NPROC]; p++) {
    if(p->state!=UNUSED)
    {
      i++;
    }
  }
  return i;
}
```

而对于nproc则题目中都有提示，遍历进程列表找到其PCB中state状态不为UNUSED即可。

说来惭愧，该题目的难点对我来说是对C语言的认识不够充分。

```c
sys_sysinfo(void)
{
  struct proc *p=myproc();
  uint64 InfoGet;
  struct sysinfo foGet;
  argaddr(0,&InfoGet);
  foGet.freemem=FreememGet();
  foGet.nproc=proc_NumGet();
  if(copyout(p->pagetable,InfoGet,(char *)&foGet,sizeof(struct sysinfo))<0)
  {
    return -1;
  }

  return 0;
}
```

### Uint64与*p

这里我们可以先看一看copyout的参数要求：

```c
int copyout(pagetable_t,uint64,char*,uint64)
```

在题目中，我们相当于是将foGet地址的sizeof(struct sysinfo)长度大小的内容，传递给用户进程虚拟地址InfoGet,采用p->pagetable这个页表。

而在虚拟地址的位置，题目给出的类型为uint64,地址往往是32位的，而这里要求为64位unsigned，因此我们对于指针也只需要扩充到64位即可，只要原来的参数为地址，不管强制转化为(uint64 or uint64 *)都可以。

### 空指针不可取

这个问题其实很老生常谈，我们传入去接收参数时不能为空指针，错误实例如下：

```c
 struct sysinfo* foGet;
argaddr(0,InfoGet);
```

我们会在InfoGet处接收argaddr传递的值，但是这里我们的foGet为空指针，没有指向的地址，即其值也没有明确的地址值，所以这样写是无效的。
