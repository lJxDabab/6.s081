# PgtblLab

## Speed up system calls

Some operating systems (e.g., Linux) speed up certain system calls by sharing data in a read-only region between userspace and the kernel. This eliminates the need for kernel crossings when performing these system calls. To help you learn how to insert mappings into a page table, your first task is to implement this optimization for the `getpid()` system call in xv6.

一些操作系统（例如，Linux）通过在用户空间和内核之间的只读区域中共享数据来加速某些系统调用。这就消除了在执行这些系统调用时进行内核交叉(kernel crossing)的需要。为了帮助您学习如何将映射插入到页表，您的第一个任务是为xv6中中的gitpid（）系统调用实现优化。

> 创建每个进程后，在USYSCALL（一个在memlayout.h中定义的虚拟地址）上映射一个只读页面。在此页的开头，存储一个结构体usyscall（也在memlayout.h中定义），并将其初始化以存储当前进程的PID。对于这个实验，在用户空间侧提供了userpid()，该函数会自动使用该映射(即会去寻找USYSCALL地址上的值)。
>
> When each process is created, map one read-only page at USYSCALL (a virtual address defined in memlayout.h). At the start of this page, store a struct usyscall (also defined in memlayout.h), and initialize it to store the PID of the current process. For this lab, ugetpid() has been provided on the userspace side and will automatically use the USYSCALL mapping. You will receive full credit for this part of the lab if the ugetpid test case passes when running pgtbltest.

### **some hint:**

- You can perform the mapping in `proc_pagetable()` in `kernel/proc.c`.
- Choose permission bits that allow userspace to only read the page.
- You may find that `mappages()` is a useful utility.
- Don't forget to allocate and initialize the page in `allocproc()`.
- Make sure to free the page in `freeproc()`.

大致思路：

本题是要你完成在进程初始化的时候，同时添加一个物理页表，并将其映射到虚拟地址供进程使用（对于进程来说只能通过虚拟地址访问），因此我们在分配页表的时候（也就是proc_pagetable函数），要完成该操作，并且在hints提示中的allocproc()函数与freeproc函数分别进行填充题目要求的usyscall结构体以及释放该页。

proc_pagetable()：

```c
pagetable_t
proc_pagetable(struct proc *p)
{
  pagetable_t pagetable;
 uint64 commaddr=(uint64)kalloc();
  // An empty page table.
  pagetable = uvmcreate();
  if(pagetable == 0)
    return 0;

  // map the trampoline code (for system call return)
  // at the highest user virtual address.
  // only the supervisor uses it, on the way
  // to/from user space, so not PTE_U.
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
              (uint64)trampoline, PTE_R | PTE_X) < 0){
    uvmfree(pagetable, 0);
    return 0;
  }

  // map the trapframe page just below the trampoline page, for
  // trampoline.S.
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
              (uint64)(p->trapframe), PTE_R | PTE_W) < 0){
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmfree(pagetable, 0);
    return 0;
  }
    //here is the new code to add one page for usyscall
  if(mappages(pagetable, USYSCALL, PGSIZE,
              commaddr, PTE_W | PTE_R) < 0){
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    uvmfree(pagetable, 0);
    return 0;
  }

  return pagetable;
}
```

要建立一个新页的映射，首先先分配一个新的物理页(kalloc())，然后再将该物理页的地址与虚拟地址完成映射(mappages())，注意，如果分配失败，为了保证资源的释放，资源要进行回滚。

allocproc():

```c
static struct proc*
allocproc(void)
{
  struct proc *p;
  struct usyscall Usyscall;
  struct usyscall* pageP;
  uint64 *pbuf;
  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if(p->state == UNUSED) {
      goto found;//go2........
    } else {
      release(&p->lock);
    }
  }
  return 0;

found:
  p->pid = allocpid();
  p->state = USED;
  Usyscall.pid=p->pid;
  // Allocate a trapframe page.
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // An empty user page table.
  p->pagetable = proc_pagetable(p);
    //new codes here to finish fill the new page with the struct usyscall in which is the pid of the process
  pbuf= walk(p->pagetable,USYSCALL,0);
  pageP=(struct usyscall*)PTE2PA(*pbuf);
  *pageP=Usyscall;
  uvmunmap(p->pagetable,USYSCALL,1,0);
  mappages(p->pagetable,USYSCALL,PGSIZE,(uint64)pageP,PTE_R | PTE_U);
  if(p->pagetable == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // Set up new context to start executing at forkret,
  // which returns to user space.
  memset(&p->context, 0, sizeof(p->context));
  p->context.ra = (uint64)forkret;
  p->context.sp = p->kstack + PGSIZE;

  return p;
}
```

该段新添加的代码主要是为了在该新页的开头添加一个struct usyscall,该地方遇到了一个当时卡住的地方：walk返回的是第三级页表的pte的地址，即寻找物理地址的pte条目的地址，因此我们在使用时要采用***pte**的形式，才能得到pte条目的内容，即物理页框的地址。

```c
pbuf= walk(p->pagetable,USYSCALL,0);
  pageP=(struct usyscall*)PTE2PA(*pbuf);
```

还有一个点需要注意，我们最开始写入的pte是有置PTE_W的，因为我们需要写入一个结构体。而后来我们得去除这个位，所以我们进行了重新映射。

```c
uvmunmap(p->pagetable,USYSCALL,1,0);
  mappages(p->pagetable,USYSCALL,PGSIZE,(uint64)pageP,PTE_R | PTE_U);
```

最后我们在proc_free()里把分配的物理页释放了：

```c
static void
freeproc(struct proc *p)
{
  if(p->trapframe)
    kfree((void*)p->trapframe);
    //i'm here
  if(walk(p->pagetable,USYSCALL,0)) 
    kfree((void*)walkaddr(p->pagetable,USYSCALL));
  p->trapframe = 0;
  if(p->pagetable)
    proc_freepagetable(p->pagetable, p->sz);
  p->pagetable = 0;
  p->sz = 0;
  p->pid = 0;
  p->parent = 0;
  p->name[0] = 0;
  p->chan = 0;
  p->killed = 0;
  p->xstate = 0;
  p->state = UNUSED;
}
```

别忘了解除映射：

```c
proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
  uvmunmap(pagetable, USYSCALL, 1, 0);
  uvmfree(pagetable, sz);
}
```



## print a page table

To help you visualize RISC-V page tables, and perhaps to aid future debugging, your second task is to write a function that prints the contents of a page table.

为了帮助您可视化RISC-V页表， 并且可能也是为了帮助将来的调试，您的第二个任务是编写一个函数来打印页表的内容。

Define a function called `vmprint()`. It should take a `pagetable_t` argument, and print that pagetable in the format described below. Insert `if(p->pid==1) vmprint(p->pagetable)` in exec.c just before the `return argc`, to print the first process's page table. You receive full credit for this part of the lab if you pass the `pte printout` test of `make grade`.

定义一个名为vmprint（）的函数。它应该采用一个pagetable_t类型参数，并以下面描述的格式打印该可分页的格式。在返回argc之前插入if（p->pid==1） vmprint(p->pagetable)  到exec.c中，以打印第一个进程的页面表。

Now when you start xv6 it should print output like this, describing the page table of the first process at the point when it has just finished `exec()`ing `init`:

```c
page table 0x0000000087f6b000 //参数
 ..0: pte 0x0000000021fd9c01 pa 0x0000000087f67000//层数1
 .. ..0: pte 0x0000000021fd9801 pa 0x0000000087f66000//层数2
 .. .. ..0: pte 0x0000000021fda01b pa 0x0000000087f68000//层数3
 .. .. ..1: pte 0x0000000021fd9417 pa 0x0000000087f65000//层数3
 .. .. ..2: pte 0x0000000021fd9007 pa 0x0000000087f64000//......
 .. .. ..3: pte 0x0000000021fd8c17 pa 0x0000000087f63000
 ..255: pte 0x0000000021fda801 pa 0x0000000087f6a000
 .. ..511: pte 0x0000000021fda401 pa 0x0000000087f69000
 .. .. ..509: pte 0x0000000021fdcc13 pa 0x0000000087f73000
 .. .. ..510: pte 0x0000000021fdd007 pa 0x0000000087f74000
 .. .. ..511: pte 0x0000000020001c0b pa 0x0000000080007000
init: starting sh
```

第一行显示了vmprint的参数。之后，每个PTE表示为一行，包括引用树中更深的页表页面的PTE。每条PTE行由数字“..”缩进，表示它在树中的深度。每一个PTE行都在其页表页面中显示PTE索引、PTE位以及从PTE中提取的物理地址。不要打印无效的pte。在上面的例子中，顶层页表页面有条目0和255的映射。条目0的下一层只映射了索引0，而该索引0的底层只映射了条目0、1和2。

- You can put `vmprint()` in `kernel/vm.c`.
- Use the macros at the end of the file kernel/riscv.h.//macors 宏
- The function `freewalk` may be inspirational.
- Define the prototype for `vmprint` in kernel/defs.h so that you can call it from exec.c.
- Use `%p` in your printf calls to print out full 64-bit hex PTEs and addresses as shown in the example.

### 思路

该功能实现也比较简单,就是一个简单的递归。

```c
void
vmprint(pagetable_t pagetable)
{
  static int level=-1;
  pte_t pte;
  int n,cnt;
  level++;
    printf("page table %p\n",pagetable);
    for(n=0;n<512;n++)
    {
      pte=pagetable[n];
      if(pte&PTE_V)
      {
            for(cnt=level;cnt>=0;cnt--)
            {
              printf(" ..");
            }
        printf("%d: pte %p pa %p\n",n,pte,PTE2PA(pte));
        if(level<=1)
        {
        vmprint((pagetable_t)PTE2PA(pte));
        }
      }
    }
    level--;
}
```

该函数主要的知识点是设立一个静态变量(**static**)，该符号能表示变量在整个函数作用域是可行的。即，在函数被释放时，该变量仍然存在且值不变，递归进入后面的层数时，加有static的参数也是同样不会被改变的，从而达到递归时对页表层数的判断。



## Detect which pages have been accessed

Some garbage collectors (a form of automatic memory management) can benefit from information about which pages have been accessed (read or write). In this part of the lab, you will add a new feature to xv6 that detects and reports this information to userspace by inspecting the access bits in the RISC-V page table. The RISC-V hardware page walker marks these bits in the PTE whenever it resolves a TLB miss.

一些垃圾收集器（自动内存管理的一种形式机制）可以从已访问的页面（读或写）的信息中获益。在实验的这一部分中，您将向xv6添加一个新特性，该特性通过检查RISC-V页表中的访问位（PTE_A）来检测这些信息并将其报告给用户空间。RISC-V硬件页面漫步器(walker)在解决TLB miss时在PTE中标记这些位。

Your job is to implement `pgaccess()`, a system call that reports which pages have been accessed. The system call takes three arguments. First, it takes the starting virtual address of the first user page to check. Second, it takes the number of pages to check. Finally, it takes a user address to a buffer to store the results into a bitmask (a datastructure that uses one bit per page and where the first page corresponds to the least significant bit). You will receive full credit for this part of the lab if the `pgaccess` test case passes when running `pgtbltest`.

您的工作是实现`pgacctss（）`，这是一个报告哪些页面被访问的系统调用。系统调用需要三个参数。首先，它需要对要检查的第一个用户页面的起始虚拟地址。其次，它需要要检查的页面数。最后，它需要一个能访问到一个缓冲区的用户地址，将结果存储到一个位掩码中（每个页使用一个位的数据结构，其中第一页对应于最小重要的位）。

Some hints:

- Read `pgaccess_test()` in `user/pgtlbtest.c` to see how `pgaccess` is used.
- Start by implementing `sys_pgaccess()` in `kernel/sysproc.c`.
- You'll need to parse arguments using `argaddr()` and `argint()`.
- For the output bitmask, it's easier to store a temporary buffer in the kernel and copy it to the user (via `copyout()`) after filling it with the right bits.
- It's okay to set an upper limit on the number of pages that can be scanned.
- `walk()` in `kernel/vm.c` is very useful for finding the right PTEs.
- You'll need to define `PTE_A`, the access bit, in `kernel/riscv.h`. Consult the [RISC-V privileged architecture manual](https://github.com/riscv/riscv-isa-manual/releases/download/Ratified-IMFDQC-and-Priv-v1.11/riscv-privileged-20190608.pdf) to determine its value.
- Be sure to clear `PTE_A` after checking if it is set. Otherwise, it won't be possible to determine if the page was accessed since the last time `pgaccess()` was called (i.e., the bit will be set forever).
- `vmprint()` may come in handy to debug page tables.

### 思路：

我们用argaddr于argint得到从pgaccess_test()传来的3个参数后，在sys_pgaccess()进行处理对应地址的pte即可。

```c
void
pgaccess_test()
{
  char *buf;
  unsigned int abits;
  printf("pgaccess_test starting\n");
  testname = "pgaccess_test";
  buf = malloc(32 * PGSIZE);
  printf("va:%p\n",buf);
  if (pgaccess(buf, 32, &abits) < 0)
    err("pgaccess failed");
  buf[PGSIZE * 1] += 1;
  buf[PGSIZE * 2] += 1;
  buf[PGSIZE * 30] += 1;
  if (pgaccess(buf, 32, &abits) < 0)
    err("pgaccess failed");
  if (abits != ((1 << 1) | (1 << 2) | (1 << 30)))
    err("incorrect access bits set");
  free(buf);
  printf("pgaccess_test: OK\n");
}
```

我们可以看到我们能从上述函数得到3个参数，在1th,2th,30th的页进行写入操作后，我们再进行pgaccess(),随后将得到的bitmask写入abits，再对其对应的位进行判断是否有记录,同时需要注意，如果错线错误得返回-1。

我们再来看看sys_pgaccess()：

```c
int
sys_pgaccess(void)
{
  pte_t* pte;
  int i;
  unsigned int abits=0;
  uint64 va,uvmBuf;
  int npage;
    argaddr(0,&va);
    argint(1,&npage);
    argaddr(2,&uvmBuf);
    if(va==0||npage==0||uvmBuf==0)
    {
      return -1;
    }
    if(npage>32)
    {
      return -1;
    }
    for(i=0;i<npage;i++)
    {
      pte=walk(myproc()->pagetable,va,0);
        if((*pte)&PTE_A)
        {
           abits+=(1<<i);
           *pte &=(~PTE_A);
        }
        va+=PGSIZE;
    }

      if(copyout(myproc()->pagetable,uvmBuf,(char *)&abits,sizeof(abits))<0)
      {
        return -1;
      }
  // lab pgtbl: your code here.
  
  return 0;
}
```

代码本身也比较简单，就不做概述，当时犯错的一个点是在用copyout时的最后一个参数的单位使byte而不是bit，因此我们应该用”abits“的大小作为Len。同时也反思到应该对指针的使用该更多的熟练。