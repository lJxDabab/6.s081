#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
extern char trampoline[], uservec[], userret[];
uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  exit(n);
  return 0; // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return wait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int n;

  argint(0, &n);
  addr = myproc()->sz;
  if (growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if (n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while (ticks - ticks0 < n)
  {
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  // backtrace();
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}
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