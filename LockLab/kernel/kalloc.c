// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

void freerange(void *pa_start, void *pa_end);

extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

struct run {
  struct run *next;
};

struct {
  struct spinlock lock;
  struct run *freelist;
} kmem[NCPU];

void
kinit()
{
  for(int i=0;i<NCPU;i++)
  {
  initlock(&kmem[i].lock, "kmem");
  }
  freerange(end, (void*)PHYSTOP);
}

void
freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char*)PGROUNDUP((uint64)pa_start);
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    kfree(p);
}

// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
  struct run *r;
  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);

  r = (struct run*)pa;

  push_off();
  int cpunum=cpuid();
  pop_off();
  acquire(&kmem[cpunum].lock);
  r->next = kmem[cpunum].freelist;
  kmem[cpunum].freelist = r;
  release(&kmem[cpunum].lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
  struct run *r;
  push_off();
  int cpunum=cpuid();
  pop_off();
  int pre=cpunum;
  acquire(&kmem[cpunum].lock);
  r = kmem[cpunum].freelist;
  if(r)
  {
    kmem[cpunum].freelist = r->next;
    release(&kmem[cpunum].lock);
  }
  else{
    release(&kmem[cpunum].lock);
    while((cpunum+1)%NCPU!=pre)
    {
      cpunum=(1+cpunum)%NCPU;
      acquire(&kmem[cpunum].lock);
      r=kmem[cpunum].freelist;
      if(r)
      {
        kmem[cpunum].freelist = r->next;
        release(&kmem[cpunum].lock);
        break;
      }
       release(&kmem[cpunum].lock);
    }
  }

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
  return (void*)r;
}
