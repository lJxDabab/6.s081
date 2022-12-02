# Lab: mmap ([hard](https://pdos.csail.mit.edu/6.828/2022/labs/guidance.html))

mmap和munmap系统调用允许UNIX程序对其地址空间进行详细的控制。它们可以用于在进程之间共享内存，将**文件**映射到进程地址空间，并作为用户级页面错误方案的一部分，如讲义中讨论的垃圾收集算法。在这个实验中，您将添加mmap和munmap到xv6，重点关注内存映射的文件。

`mmap` can be called in many ways, **but this lab** requires only a subset of its features relevant to memory-mapping a file. You can assume that `addr` will always be zero, meaning that the kernel should decide the virtual address at which to map the file. `mmap` returns that address, or 0xffffffffffffffff if it fails. `length` is the number of bytes to map; it might not be the same as the file's length. `prot` indicates whether the memory should be mapped readable, writeable, and/or executable; you can assume that `prot` is `PROT_READ` or `PROT_WRITE` or both. `flags` will be either `MAP_SHARED`, meaning that modifications to the mapped memory should be written back to the file, or `MAP_PRIVATE`, meaning that they should not. You don't have to implement any other bits in `flags`. `fd` is the open file descriptor of the file to map. You can assume `offset` is zero (it's the starting point in the file at which to map).

```
void *mmap(void *addr, size_t length, int prot, int flags,
           int fd, off_t offset);
```

mmap`可以通过多种方式被调用，但是在这个实验只需要与内存映射文件相关的特性的一个子集。您可以假设`addr`将总是为零，这意味着内核应该决定映射文件的虚拟地址。`mmap`返回该地址，如果它失败，则返回0x ffffffffffffffff。`length`是要映射的字节数；它可能与文件的长度不相同。`prot`指示内存是否应映射为可读、可写和/或可执行的；您可以假设`prot`是`PROT_READ`或`PROT_WRITE`，或两者都有。`标志`将是`MAP_SHARED`，这意味着对映射内存的修改应该被写入文件，或者`MAP_PRIVATE`，这意味着它们不应该。您不必在`flags`中实现任何其他位。`fd`是要映射的文件的打开文件描述符。您可以假设`offset`为零（这是文件中要映射的起点）。

`munmap(addr, length)` should remove mmap mappings in the indicated address range. If the process has modified the memory and has it mapped `MAP_SHARED`, the modifications should first be written to the file. An `munmap` call might cover only a portion of an mmap-ed region, but you can assume that it will either unmap at the start, or at the end, or the whole region (but not punch a hole in the middle of a region).

munmap（addr，length）应该删除指定地址范围内的mmap映射。如果进程已经修改了内存并将其映射为MAP_SHARED，则应该首先将修改写入文件。一个munmap调用可能只覆盖一个mmap所在区域的一部分，但是您可以假设它（munmap）会在开始或结束时取消映射，或者在整个区域内取消映射（但不会在一个区域的中间打一个洞）。

You should implement enough `mmap` and `munmap` functionality to make the `mmaptest` test program work. If `mmaptest` doesn't use a `mmap` feature, you don't need to implement that feature.

**Here are some hints**:

- Start by adding `_mmaptest` to `UPROGS`, and `mmap` and `munmap` system calls, in order to get `user/mmaptest.c` to compile. For now, just return errors from `mmap` and `munmap`. We defined `PROT_READ` etc for you in `kernel/fcntl.h`. Run `mmaptest`, which will fail at the first mmap call.
- Fill in the page table lazily, in response to page faults. That is, `mmap` should not allocate physical memory or read the file. Instead, do that in page fault handling code in (or called by) `usertrap`, as in the lazy page allocation lab. The reason to be lazy is to ensure that `mmap` of a large file is fast, and that `mmap` of a file larger than physical memory is possible.
- Keep track of what `mmap` has mapped for each process. Define a structure corresponding to the VMA (virtual memory area) described in Lecture 15, recording the address, length, permissions, file, etc. for a virtual memory range created by `mmap`. Since the xv6 kernel doesn't have a memory allocator in the kernel, it's OK to declare a fixed-size array of VMAs and allocate from that array as needed. A size of 16 should be sufficient.
- Implement `mmap`: find an unused region in the process's address space in which to map the file, and add a VMA to the process's table of mapped regions. The VMA should contain a pointer to a `struct file` for the file being mapped; `mmap` should increase the file's reference count so that the structure doesn't disappear when the file is closed (hint: see `filedup`). Run `mmaptest`: the first `mmap` should succeed, but the first access to the mmap-ed memory will cause a page fault and kill `mmaptest`.
- Add code to cause a page-fault in a mmap-ed region to allocate a page of physical memory, read 4096 bytes of the relevant file into that page, and map it into the user address space. Read the file with `readi`, which takes an offset argument at which to read in the file (but you will have to lock/unlock the inode passed to `readi`). Don't forget to set the permissions correctly on the page. Run `mmaptest`; it should get to the first `munmap`.
- Implement `munmap`: find the VMA for the address range and unmap the specified pages (hint: use `uvmunmap`). If `munmap` removes all pages of a previous `mmap`, it should decrement the reference count of the corresponding `struct file`. If an unmapped page has been modified and the file is mapped `MAP_SHARED`, write the page back to the file. Look at `filewrite` for inspiration.
- Ideally your implementation would only write back `MAP_SHARED` pages that the program actually modified. The dirty bit (`D`) in the RISC-V PTE indicates whether a page has been written. However, `mmaptest` does not check that non-dirty pages are not written back; thus you can get away with writing pages back without looking at `D` bits.
- Modify `exit` to unmap the process's mapped regions as if `munmap` had been called. Run `mmaptest`; `mmap_test` should pass, but probably not `fork_test`.
- Modify `fork` to ensure that the child has the same mapped regions as the parent. Don't forget to increment the reference count for a VMA's `struct file`. In the page fault handler of the child, it is OK to allocate a new physical page instead of sharing a page with the parent. The latter would be cooler, but it would require more implementation work. Run `mmaptest`; it should pass both `mmap_test` and `fork_test`.

该实验即实现文件在缓存中的映射，其中蕴含了对往期Lab知识的身影，同样，精巧的设计和低错误才能比较顺利完成这个实验，因此建议好好复习一下代码逻辑与设计。我们先来看看第一个比较重要的sys_mmap()函数:

## **mmap():**

我们实现的sys_munmap函数与sys_mmap函数都是系统调用，因此都需要对系统调用进行一系列配置（这些就不讲了，很多次了，可以参照往期的实验）。

在缓存中的映射，对于进程来说，它们的映射表现为虚拟地址对物理地址的映射，且它们的虚拟地址都是独立的。在题目中，作者有建议到，策划一个VMA(virtual memory address)来对这些地址进行管理，进行推理一下，可以理解到VMA是对每个进程虚拟地址的管理，因此它要被放入在PCB里面：

```c
struct VMarea{
  uint64 addr;		//分配的虚拟地址起始地址
  int length;		//分配的长度
  struct file* f;	//所指向的，打开的文件
  int pos;			//在文件中提取信息的偏移量
  int valid;		//数组的该单位是否被采用
  int flag;			//该映射是否需要被写回到硬盘(SHARED)还是不用写回(PRIVATE)
  int prot;			//对于映射到的物理内存，其PTE是可写的(PROT_WRITE)，可读的(PROT_READ)，还是可执行的(PROT_EXEC)
};

enum procstate { UNUSED, USED, SLEEPING, RUNNABLE, RUNNING, ZOMBIE };
#define VMAXSZ 16
// Per-process state
struct proc {
  struct spinlock lock;

 ......
  struct proc *parent;         // Parent process
  struct VMarea pf[VMAXSZ];
......
};
```

因为我们一个进程可能映射多个文件，因此它是以数组的形式呈现的，题目建议我们其大小可以固定，我们这里取16。

下面我们来看看sys_mmap：

```c
uint64
sys_mmap(void)
{
  uint64 addr,tranpoffset=0;
  int port,flag,fd,offset,i,len;
  argaddr(0,&addr);
  argint(1,(int*)&len);//why here (int*)
  argint(2,&port);
  argint(3,&flag);
  argint(4,&fd);
  argint(5,&offset);
  struct proc *p=myproc();
  if(!addr)
  {
      for(i=0,tranpoffset=(uint64)p->trapframe;i<VMAXSZ;i++)
      {
        if(!p->pf[i].valid)
        {
          break;
        }
        tranpoffset-=p->pf[i].length;				//首先我们先逐一寻找闲置的数组单位(valid==0)
      }
      if(i==VMAXSZ)
      {
        return 0xffffffffffffffff ;					//如果没有闲置的数组单位了，我们返回失败(unsigned 0xffffffffffffffff==signed -1)
      }
      p->pf[i].valid=1;
      p->pf[i].prot=port;
      p->pf[i].flag=flag;
      p->pf[i].length=PGROUNDUP(len);				//如果有，我们就将该VMA块填入信息
      p->pf[i].addr=tranpoffset-len;
      p->pf[i].f=p->ofile[fd];
      if((!p->pf[i].f->writable)&&(port&PROT_WRITE)&&(flag&MAP_SHARED))  //只读的文件是不可以进行写操作的，这里如果要进行写操作，我们就返回失败
    {
      p->pf[i].pos=0;
       p->pf[i].valid=0;
      return 0xffffffffffffffff;
    }
      filedup(p->pf[i].f);							//进程对文件的引用加一
      return (uint64)p->pf[i].addr;					//返回地址
  }
  return 0xffffffffffffffff;
}
```

我们这里采取lazy allocate的方法，我们在mmap的时候只分配其虚拟地址，而在真正读取它的时候，我们才从页错误里面进行文件的读入缓存与对文件的缓存进行读写。

## **usertrap():**

接下来我们来看看usertrap()函数，其作为主要进行文件读写的函数。

```c
void
usertrap(void)
{
  ......
  }else if(r_scause()==15||r_scause()==13)		//这里我把读页错误和写页错误涵盖到一起了，虽然写页错误好像在test中没有必要囊括
  {
    int flag=0,i;
    uint64 pa,va;
    struct inode *ip;
   if((pa=(uint64)kalloc())==0)				//页错误是每一页都要报错，因此每次我们都只分配一页的内存
   {
    exit(-1);
   }
  memset((void*)pa,0,PGSIZE);
  va=r_stval();							//va是报错的虚拟地址，也就是我们要分配的页的起始地址
  for(i=0;i<VMAXSZ-1;i++)
      {
        if(p->pf[i].addr<=va&&p->pf[i].addr+p->pf[i].length>va)		//这里进行筛查我们是在哪个VMA块的文件进行映射的
        {
          break;
        }
      }
      if(i==VMAXSZ-1)
      {
        kfree((void*)pa);
        exit(-1) ;
      }
    if(p->pf[i].prot&PROT_READ)
    {
        flag|=PTE_R;
    }
    if(p->pf[i].prot&PROT_WRITE)
    {
        flag|=PTE_W;
    }
    if(p->pf[i].prot&PROT_EXEC)					//这里在映射之前，我们需要决定pte的标志位是多少，通过,传递进来的port位进行筛选
    {
      flag|=PTE_X;  
    }
    p->pf[i].pos=va-p->pf[i].addr;
  if(mappages(p->pagetable, va, PGSIZE, (uint64)pa, PTE_U|flag)!=0)			//这里进行映射
  {
      kfree((void*)pa);
  }
  ip=p->pf[i].f->ip;
  ilock(ip);
  readi(ip,1,va,p->pf[i].pos,PGSIZE);		//readi是一个需要调用者对ip上锁后才能使用的函数，因此我们得先上锁。这里得提一下pos,其作为偏移量，决定了  										//对文件的哪个页进行读写，其可以通过va-p->pf[i].addr来得到,这里要注意的惯性思维是，我们读取的可能是该 										//文件中间的某一个页,而并非只是开头
  iunlock(ip);
  } else if((which_dev = devintr()) != 0){
   ......

  usertrapret();
}
```

随后是我们的sys_munmap函数，其会使用到MAP_SHARED这类的宏，用于区别解除映射后我们是否要把改动的内容写回到原来的文件里，在VMA中其为flag。

## munmap():

```c
uint64
sys_munmap(void)
{
  uint64 addr;
  uint len;
  int ret=0,i;
  pte_t *pte;
  len=ret;
  argaddr(0,&addr);
  argint(1,(int*)&len);
  struct proc *p=myproc();
   for(i=0;i<VMAXSZ-1;i++)
      {
        if(p->pf[i].addr<=addr&&p->pf[i].addr+p->pf[i].length >addr)		//同样的是对该块的寻找
        {	
          break;
        }
      }
      if(i==VMAXSZ-1)
      {
        return -1 ;
      }
  if(addr+len>p->pf[i].addr+p->pf[i].length||addr<p->pf[i].addr)
  {
    return -1;
  }
  pte=walk(p->pagetable,addr,0);				//这里对其pte的寻找与后续v位的检查，都是为了防止该VMA中部分页被释放了，而重复释放的问  														//题(重复释放uvmunmap会报错)
  if(p->pf[i].flag==MAP_PRIVATE)					//作为私人页，不需要写回原文件，只要解除映射，释放空间就好了
  { 
    if(*pte&PTE_V)
      uvmunmap(p->pagetable,addr,len/PGSIZE,0);
  }
  else if(p->pf[i].flag==MAP_SHARED)			//作为共享页，我们得写回到文件中(filewrite),然后再解除映射
  {
     if(*pte&PTE_V)
     {
       filewrite(p->pf[i].f,addr,len);
      uvmunmap(p->pagetable,addr,len/PGSIZE,0);
     }
  }
    p->pf[i].addr=addr+len;				//释放之后，我们VMA的管理的内存值就会有所变化，这里进行改变。很巧妙的是，不管你是先释放高地址，再释放低地  										//址还是从低到高释放地址，或者乱序释放，这种写法都是正确的
    p->pf[i].length-=len;
    if(p->pf[i].length==0)			//如果该VMA管理的缓存空间长度为0，那么就释放该VMA该块的valid置0
    {
      p->pf[i].pos=0;
       p->pf[i].valid=0;
           fileclose(p->pf[i].f);		//同时解除了该进程对该文件的一次引用，因此得让file->ref--
    }
return 0;
}
```

随后根据题目要求，我们在exit()函数中也要实现类似munmap()的功能（一些正常或异常退出，得把有VMA管理的块给释放掉，SHARED还可能有写回文件的操作）

## exit():

```c
void
exit(int status)
{
  struct proc *p = myproc();
  pte_t *pte;
  if(p == initproc)
    panic("init exiting");
 for(int i=0;i<16;i++)
 {
  if(p->pf[i].valid)
  {
    if(p->pf[i].flag==MAP_SHARED)
    filewrite(p->pf[i].f,p->pf[i].addr,p->pf[i].length);		
  for(int j=0;j<p->pf[i].length/PGSIZE;j++)			//这里唯一和munmap的区别是，要对VMA数组的所有单元(如果有引用缓存)都要进行释放
  {
   pte=walk(p->pagetable,p->pf[i].addr+j*PGSIZE,0);
    if(*pte&PTE_V)
    {
      uvmunmap(p->pagetable,p->pf[i].addr+j*PGSIZE,1,0);
    }
  }
  fileclose(p->pf[i].f);
  p->pf[i].pos=0;
  p->pf[i].valid=0;
  }
 }
  // Close all open files.
  for(int fd = 0; fd < NOFILE; fd++){
   ......

  // Jump into the scheduler, never to return.
  sched();
  panic("zombie exit");
}
```

在生成子进程的时候，我们也要继承父进程的VMA，因此我们在fork中也要进行改动:

## fork:

```c
int
fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();

  // Allocate process.
 ......
  // copy saved user registers.
  *(np->trapframe) = *(p->trapframe);

  // Cause fork to return 0 in the child.
  np->trapframe->a0 = 0;

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    if(p->ofile[i])
      np->ofile[i] = filedup(p->ofile[i]);
  np->cwd = idup(p->cwd);
  for(int j=0;j<16;j++)
  {
    if(p->pf[j].valid)
    {
    np->pf[j]=p->pf[j];				//here the code,本来pf[j]不为指针，这里直接结构体赋值就好
    np->pf[j].pos=0;
    filedup(np->pf[j].f);			//生成子进程后，对文件的引用也增加了，因此调用filedup
    }
  }  
 ......

  return pid;
}
```

![u=4091023553,3565446631&fm=253&fmt=auto&app=138&f=JPEG.webp](C:\Users\LJX\Desktop\u=4091023553,3565446631&fm=253&fmt=auto&app=138&f=JPEG.webp.jpg)