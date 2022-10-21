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