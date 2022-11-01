#include "types.h"
#include "riscv.h"
#include "param.h"
#include "defs.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  exit(n);
  return 0;  // not reached
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
  if(growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;


  argint(0, &n);
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}


#ifdef LAB_PGTBL
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
#endif

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
