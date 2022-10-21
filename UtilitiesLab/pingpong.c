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