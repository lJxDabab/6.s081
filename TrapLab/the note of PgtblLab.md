

# TrapsLab

## RISC-V assembly

**It will be important to understand a bit of RISC-V assembly（汇编代码）, which you were exposed to in 6.1910 (6.004)（这里编者默认你学习了6.004）. There is a file `user/call.c` in your xv6 repo. ==make fs.img== compiles it and also produces a readable assembly version of the program in `user/call.asm`.**

### **Read the code in call.asm for the functions `g`, `f`, and `main`. The instruction manual for RISC-V is on the [reference page](https://pdos.csail.mit.edu/6.828/2022/reference.html). Here are some questions that you should answer (store the answers in a file answers-traps.txt):**

```assembly
int g(int x) {
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
  return x+3;
}
   6:	250d                	addiw	a0,a0,3
   8:	6422                	ld	s0,8(sp)
   a:	0141                	addi	sp,sp,16
   c:	8082                	ret

000000000000000e <f>:

int f(int x) {
   e:	1141                	addi	sp,sp,-16
  10:	e422                	sd	s0,8(sp)
  12:	0800                	addi	s0,sp,16
  return g(x);
}
  14:	250d                	addiw	a0,a0,3
  16:	6422                	ld	s0,8(sp)
  18:	0141                	addi	sp,sp,16
  1a:	8082                	ret

000000000000001c <main>:

void main(void) {
  1c:	1141                	addi	sp,sp,-16
  1e:	e406                	sd	ra,8(sp)
  20:	e022                	sd	s0,0(sp)
  22:	0800                	addi	s0,sp,16
  printf("%d %d\n", f(8)+1, 13);
  24:	4635                	li	a2,13
  26:	45b1                	li	a1,12
  28:	00001517          	auipc	a0,0x1
  2c:	84850513          	addi	a0,a0,-1976 # 870 <malloc+0xf2>
  30:	00000097          	auipc	ra,0x0
  34:	62a080e7          	jalr	1578(ra) # 65a <printf>
  exit(0);
  38:	4501                	li	a0,0
  3a:	00000097          	auipc	ra,0x0
  3e:	298080e7          	jalr	664(ra) # 2d2 <exit>

0000000000000042 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  42:	1141                	addi	sp,sp,-16
  44:	e406                	sd	ra,8(sp)
  46:	e022                	sd	s0,0(sp)
  48:	0800                	addi	s0,sp,16
  extern int main();
  main();
  4a:	00000097          	auipc	ra,0x0
  4e:	fd2080e7          	jalr	-46(ra) # 1c <main>
  exit(0);
  52:	4501                	li	a0,0
  54:	00000097          	auipc	ra,0x0
  58:	27e080e7          	jalr	638(ra) # 2d2 <exit>
```

**这里要提一下，上面的汇编是采用RISC-V的指令集，而该指令集的指令编者默认你在6.004中学过，因此我们需要单独去参照6.004课程里的表和查资料，下面给出网址。**

[6004_isa_reference.pdf (mit.edu)](https://6191.mit.edu/_static/fall22/resources/references/6004_isa_reference.pdf)

**这里提一下这份资料以外的知识点，及auipc命令，它的作用是将第二个参数左移12位(32位中的高20位)，再加上pc的值，将这个加法和，写入第一个参数中（这里规定第一个参数是寄存器），而这里的auipc命令第二个参数取0，作用为直接将pc的值写入到对应的寄存器中。**

Q:Which registers contain arguments to functions? For example, which register holds 13 in main's call to printf?
A:a2.

Q:Where is the call to function f in the assembly code for main? Where is the call to g? 
(Hint: the compiler may inline functions.)
A:f is inlined in main and g is inlined in f.（被内联到函数中，这个知识点笔者不太见过，需要记一下）

Q:At what address is the function printf located?
A:0x65a（这里可以通过jalr命令做判断，可以看到这里跳转的值为1578+ra，即，1578+30,换算为16进制即为0x65a,当然你也可以直接看它汇编给出的值）

Q:What value is in the register ra just after the jalr to printf in main?
A:ra=pc+4 ,so it is 0x34+4=0x38    （这里是jalr命令的作用，会让ra的值等于pc+4）


Q:Run the following code.

	unsigned int i = 0x00646c72;
	printf("H%x Wo%s", 57616, &i);

A:What is the output? :)
He110 wor1d

Q:The output depends on that fact that the RISC-V is little-endian. If the 
RISC-V were instead big-endian what would you set i to in order to
 yield the same output? Would you need to change 57616 to a different value?
A:I'll set 0x00726c64.No,as a string it changes but not as a num.

（小端法储存会让字节倒置）

Q:In the following code, what is going to be printed after 'y='? 
(note: the answer is not a specific value.) Why does this happen?
A:the value of a2.because no argument value is transmitted to a2 while 
it is the default register to pass the 2 th argument.（这里是可以查看编译后的汇编代码，可以看到y的值确实是a2）

## Backtrace 

For debugging it is often useful to have a backtrace: a list of the function calls on the stack above the point at which the error occurred. To help with backtraces, the compiler generates machine code that maintains a stack frame on the stack corresponding to each function in the current call chain. Each stack frame consists of the return address and a "frame pointer" to the caller's stack frame. Register s0 contains a pointer to the current stack frame (it actually points to the the address of the saved return address on the stack plus 8). Your backtrace should use the frame pointers to walk up the stack and print the saved return address in each stack frame.

**对于调试，有一个回溯（backtrace）通常是有用的,即在/错误发生点上方/的堆栈上/调用一个函数列表。为了帮助处理回溯，编译器生成机器代码，在堆栈上维护与当前调用链中的每个函数对应的堆栈帧。每个堆栈帧由函数的返回地址和一个指向调用者的堆栈帧的“帧指针”组成。寄存器s0包含一个指向当前堆栈帧的指针（它实际上指向堆栈上保存的返回地址+8）。你的回溯应该使用帧指针达到堆栈，并在每个堆栈帧中打印保存的返回地址。**

Implement a `backtrace()` function in `kernel/printf.c`. Insert a call to this function in `sys_sleep`, and then run bttest, which calls `sys_sleep`. Your output should be a list of return addresses with this form (but the numbers will likely be different):

```
    backtrace:
    0x0000000080002cda
    0x0000000080002bb6
    0x0000000080002898
  
```

After `bttest` exit qemu. In a terminal window: run `addr2line -e kernel/kernel` (or `riscv64-unknown-elf-addr2line -e kernel/kernel`) and cut-and-paste the addresses from your backtrace, like this:

```
    $ addr2line -e kernel/kernel
    0x0000000080002de2
    0x0000000080002f4a
    0x0000000080002bfc
    Ctrl-D
  
```

You should see something like this:

```
    kernel/sysproc.c:74
    kernel/syscall.c:224
    kernel/trap.c:85
  
```

Some hints:

- Add the prototype for your `backtrace()` to `kernel/defs.h` so that you can invoke `backtrace` in `sys_sleep`.

- The GCC compiler stores the frame pointer of the currently executing function in the register s0. Add the following function to kernel/riscv.h :

  ```
  static inline uint64
  r_fp()
  {
    uint64 x;
    asm volatile("mv %0, s0" : "=r" (x) );
    return x;
  }
  ```

  and call this function in backtrace to read the current frame pointer. r_fp() uses in-line assembly to read s0.

- These [lecture notes](https://pdos.csail.mit.edu/6.1810/2022/lec/l-riscv.txt) have a picture of the layout of stack frames. Note that the return address lives at a fixed offset (-8) from the frame pointer of a stackframe, and that the saved frame pointer lives at fixed offset (-16) from the frame pointer.（我觉得可看可不看）

- Your `backtrace()` will need a way to recognize that it has seen the last stack frame, and should stop. A useful fact is that the memory allocated for each kernel stack consists of a single page-aligned page, so that all the stack frames for a given stack are on the same page. You can use `PGROUNDDOWN(fp)` (see `kernel/riscv.h`) to identify the page that a frame pointer refers to.

Once your backtrace is working, call it from `panic` in `kernel/printf.c` so that you see the kernel's backtrace when it panics.

整个过程其实比较清晰，就是在当前栈帧中找到当前栈帧中的返回地址，并且通过找到调用者的函数并循环这个过程。然后题目也告诉你在何时终止：因为这些栈帧是在同一个虚拟页里，所以只要地址跑出这个页的地址就算截止了。（这里想起一个点，就在整个虚拟页的pte往往相同，因为它们指向同一个物理页，因此也只是在最后12位的偏移量不同而已）

我们可以看看这一章用的比较多的内联汇编代码

```c
static inline uint64
r_fp()
{
  uint64 x;
  asm volatile("mv %0, s0" : "=r" (x) );
  return x;
}
```

，其实也比较简单，就是去取s0寄存器的值。后面有很多这样的函数，以read/write_......这样的格式。

```c
void
backtrace(void) {
    printf("backtrace:\n");

uint64 fp = r_fp();

while (1) {
    printf("%p\n", *((uint64 *)(fp - 8)));
    uint64 prefp = *((uint64 *)(fp - 16));
    
if (PGROUNDDOWN(fp) != PGROUNDDOWN(prefp)) {
    break;
}
fp = prefp;
}
}
```

代码也比较简单，返回地址与caller的栈帧地址也都告诉你了，就只提一个点，这个弘，PGROUNDDOWN，可以看一下它的值：

```c
# define PGROUNDDOWN(a) (((a)) & ~(PGSIZE-1))
```

这里的 ~(PGSIZE-1))取出来为将二进制中，页的单位1后面的位全至0后面全至1，即：

<img src="C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221106204637577.png" alt="image-20221106204637577" style="zoom:67%;" />

这样能得到该页的页顶位置。



## Alarm

**在本练习中，您将向xv6添加一个特性，该特性会在进程使用CPU时间时定期提醒进程（即时钟周期）。这可能对于想要限制它们占用多少CPU时间的绑定进程很有用，或者对于想要计算但也想要采取一些周期性操作的进程很有用。更一般地说，您将实现一种用户级中断/故障处理程序的原始形式；例如，您可以使用类似的方法来处理应用程序中的页面错误。”**

You should add a new `sigalarm(interval, handler)` system call. If an application calls `sigalarm(n, fn)`, then after every `n` "ticks" of CPU time that the program consumes, the kernel should cause application function `fn` to be called. When `fn` returns, the application should resume（复原，恢复） where it left off. A tick is a fairly arbitrary（专制的） unit of time in xv6, determined by how often a hardware timer generates interrupts. If an application calls `sigalarm(0, 0)`, the kernel should stop generating periodic alarm calls.

You'll find a file `user/alarmtest.c` in your xv6 repository. Add it to the Makefile. It won't compile correctly until you've added `sigalarm` and `sigreturn` system calls (see below).

题目中考虑到题目难度是一个test，一个test做了梯度区分的，也方便我们一点一点完成，但这里就直接描述整体构造了。

这里还想提一嘴，函数指针的写法：void (*handler)()，完成该题目时做好去看看RICS-V资料的内容，复习一下sepc.scause等寄存器的作用，才能更好理解其内联汇编函数。

首先是系统调用sigalarm函数：

```c
uint64
sys_sigalarm(void)
{
  struct proc *p;
  uint64 exp;
  p = myproc();
  argint(0, &(p->interval));
  argaddr(1, &exp);
  p->handler = (void (*)())exp;
  return 0;
}
```

我们将函数传进来的参数都放在进程的pcb里，这里仅仅做了如是处理。

重头在trap.c的usertrap函数中：

```c
void
usertrap(void)
{
  int which_dev = 0;
  if((r_sstatus() & SSTATUS_SPP) != 0)
    panic("usertrap: not from user mode");

  // send interrupts and exceptions to kerneltrap(),
  // since we're now in the kernel.
  w_stvec((uint64)kernelvec);

  struct proc *p = myproc();
  
  // save user program counter.
  p->trapframe->epc = r_sepc();
  
  if(r_scause() == 8){
    // system call

    if(killed(p))
      exit(-1);

    // sepc points to the ecall instruction,
    // but we want to return to the next instruction.
    p->trapframe->epc += 4;

    // an interrupt will change sepc, scause, and sstatus,
    // so enable only now that we're done with those registers.
    intr_on();

    syscall();
  } else if((which_dev = devintr()) != 0){
      //here are the codes I write
    if(which_dev==2)
    {
    acquire(&tickslock);
    p->time++;
    if(p->time==p->interval)
    {
      if(!p->turn)
            {
            p->contentRem.epc = p->trapframe->epc;
            p->contentRem.ra = p->trapframe->ra;
            p->contentRem.sp = p->trapframe->sp;
            p->contentRem.gp = p->trapframe->gp;
            p->contentRem.tp = p->trapframe->tp;
            p->contentRem.s0 = p->trapframe->s0;
            p->contentRem.s1 = p->trapframe->s1;
            p->contentRem.a0 = p->trapframe->a0;
            p->contentRem.a1 = p->trapframe->a1;
            p->contentRem.a2 = p->trapframe->a2;
            p->contentRem.a3 = p->trapframe->a3;
            p->contentRem.a4 = p->trapframe->a4;
            p->contentRem.a5 = p->trapframe->a5;
            p->contentRem.a6 = p->trapframe->a6;
            p->contentRem.a7 = p->trapframe->a7;
            p->contentRem.s2 = p->trapframe->s2;
            p->contentRem.s3 = p->trapframe->s3;
            p->contentRem.s4 = p->trapframe->s4;
            p->contentRem.s5 = p->trapframe->s5;
            p->contentRem.s6 = p->trapframe->s6;
            p->contentRem.s7 = p->trapframe->s7;
            p->contentRem.s8 = p->trapframe->s8;
            p->contentRem.s9 = p->trapframe->s9;
            p->contentRem.s10 = p->trapframe->s10;
            p->contentRem.s11 = p->trapframe->s11;
            p->trapframe->epc=(uint64)p->handler;
              p->turn=1;
            }
            p->time=0;
    }
     
     release(&tickslock);
     
    }
  } else {
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    setkilled(p);
  }

  if(killed(p))
    exit(-1);

  // give up the CPU if this is a timer interrupt.
  if(which_dev == 2)
  {
    yield();
  }
  usertrapret();
}
```

这里研究代码我们可以得知，当which_dev==2时，为时钟终端，因此我们在对应的条件判断中写入代码。对每n ticks才调用该函数的代码分析就不做描述了，更多去讲思路。因为我们最后要返回到调用函数时的位置，因此我们需要对寄存器的值进行保存，因此我们便利地在进程的pcb中保存这些值，不知道有哪些是必要的，因此就多写了点。随后我们会进入usertrapret函数，函数作用如其名，会陷入用户态。

下面是usertraprset函数，该函数的实现比较复杂，有空可以去看看课本上的对应章节，其对该函数的实现提供了理论基础，我们只需要知道对p->trapframe-epc的值放入函数的地址，会在usertrapset()函数中陷入用户态，即，上下文返回我们之前时钟中断前的代码流。

```c
void
usertrapret(void)
{
  struct proc *p = myproc();

  // we're about to switch the destination of traps from
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
  p->trapframe->kernel_trap = (uint64)usertrap;
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()

  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
  x |= SSTATUS_SPIE; // enable interrupts in user mode
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
  ((void (*)(uint64))trampoline_userret)(satp);
}

```

而我们恢复用户态寄存器的函数，写在sigreturn函数中：

```c
uint64 sys_sigreturn()
{
  struct proc *p = myproc();
  p->trapframe->epc = p->contentRem.epc;
  p->trapframe->ra = p->contentRem.ra;
  p->trapframe->sp = p->contentRem.sp;
  p->trapframe->gp = p->contentRem.gp;
  p->trapframe->tp = p->contentRem.tp;
  p->trapframe->s0 = p->contentRem.s0;
  p->trapframe->s1 = p->contentRem.s1;
  p->trapframe->a0 = p->contentRem.a0;
  p->trapframe->a1 = p->contentRem.a1;
  p->trapframe->a2 = p->contentRem.a2;
  p->trapframe->a3 = p->contentRem.a3;
  p->trapframe->a4 = p->contentRem.a4;
  p->trapframe->a5 = p->contentRem.a5;
  p->trapframe->a6 = p->contentRem.a6;
  p->trapframe->a7 = p->contentRem.a7;
  p->trapframe->s2 = p->contentRem.s2;
  p->trapframe->s3 = p->contentRem.s3;
  p->trapframe->s4 = p->contentRem.s4;
  p->trapframe->s5 = p->contentRem.s5;
  p->trapframe->s6 = p->contentRem.s6;
  p->trapframe->s7 = p->contentRem.s7;
  p->trapframe->s8 = p->contentRem.s8;
  p->trapframe->s9 = p->contentRem.s9;
  p->trapframe->s10 = p->contentRem.s10;
  p->trapframe->s11 = p->contentRem.s11;
    p->turn=0;
   usertrapret();

  return -1;
}
```

代码本身也比较简单，就是对寄存器的复原。