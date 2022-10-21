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
}

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
//----------------imcomplete version-------------------------------------------
// char *ftname(char *path, int fd, char *cmdwd);
// int location(char *path);
// void test(int i);
// char* fmtname(char *path);
// int main(int argc, char *argv[])
// {
//   char buf[512];
//   int fd;
//   if (argc < 2)
//   {
//     printf("./\n");
//   }
//   else if (argc == 2)
//   {
//     printf("Warning 2 params are needed:%s\n", location("."));
//   }
//   else
//   {
//     strcpy(buf, argv[1]);
//     fd = location(buf);
//     // printf("%s\n", buf);
//     ftname(buf, fd, argv[2]);
//   }
//   // test(1);
//   exit(0);
// }
// char *ftname(char *path, int fd, char *cmdwd)
// {
//   char buf[512];
//   char *p;
//   struct stat st;
//   struct stat std;
//   struct dirent de;
//   // Find first character after last slash.
//   // test(2);
//   if (fstat(fd, &st) < 0/*stat(buf, &st) < 0*/)
//   {
//     fprintf(2, "ls: cannot stat %s\n", path);
//     close(fd);
//     return " ";
//   }
//   // printf("st.type:%d\n", st.type);
//   switch (st.type)
//   {
//   case T_FILE:
//     for (p = path + strlen(path); p >= path && *p != '/'; p--)
//       ;
//     p++;
//     // printf("this is p:%s\n", p);
//     // Return blank-padded name.
//     memmove(buf, p, strlen(p));
//     // test(4);
//     if (strcmp(buf, cmdwd) == 0)
//     {
//       printf("%s%s\n", path, cmdwd);
//     }
//     break;

//   case T_DIR:
//     if (strlen(buf) + 1 + DIRSIZ + 1 > sizeof(buf))
//     {
//       fprintf(2, "find: path too long\n");
//       close(fd);
//       exit(1);
//     }
//     strcpy(buf, path);
//     p = buf + strlen(buf);
//     *p++ = '/';
//     // printf("buf1:%s\n", buf);
//     while (read(fd, &de, sizeof(de)) == sizeof(de))
//     {
//       // printf("%s\n",de.name);
//       if ((strcmp(de.name, ".") == 0) || (strcmp(de.name, "..") == 0))
//       {
//         continue;
//       }
//       // printf("de.inum/de.name:%d %s\n", de.inum, de.name);
//       if (de.inum == 0)
//         continue;
//       memmove(p, de.name, DIRSIZ);
//       // printf("buf:%s\n", buf);
//       p[DIRSIZ] = 0;
//       // close(fd);
//       // fd = open(buf, 0);
//       // ftname(buf, fd, cmdwd);
//       stat(buf, &std);
//       switch (std.type)
//       {
//       case T_FILE:
//         if (strcmp(de.name, cmdwd) == 0)
//         {
//           printf("%s\n", buf);
//         }
//         break;
//       case T_DIR:
//       close(fd);
//       fd=open(buf,0);
//         ftname(buf, fd, cmdwd);
//         break;
//          case T_DEVICE:
//             if (strcmp(de.name, cmdwd) == 0) {
//                 printf("%s\n", buf);
//             }
//             break;
//       }
//     }

//     break;
//     case T_DEVICE:
//             if (strcmp(fmtname(buf), cmdwd) == 0) {
//                 printf("%s\n", fmtname(buf));
//             }
//             break;
//   }
//   return "NULL";
// }
// int location(char *path)
// {
//   int fd;
//   // struct dirent de;
//   struct stat st;
//   if ((fd = open(path, 0)) < 0)
//   {
//     fprintf(2, "ls: cannot open %s\n", path);
//     return -1;
//   }
//   if (fstat(fd, &st) < 0)
//   {
//     fprintf(2, "ls: cannot stat %s\n", path);
//     close(fd);
//     return -1;
//   }

//   switch (st.type)
//   {
//   case T_FILE:
//     printf("Warning: First param is a file");
//     close(fd);
//     return -1;
//     break;

//   case T_DIR:
//     // printf("path/fd:%s,%d\n", path, fd);
//     return fd;
//     break;
//   }
//   return -1;
// }
// void test(int i)
// {
//   printf("this is test %d\n", i);
// }
// char* fmtname(char *path)
// {
//   static char buf[DIRSIZ+1];
//   char *p;

//   // Find first character after last slash.
//   for(p=path+strlen(path); p >= path && *p != '/'; p--)
//     ;
//   p++;

//   // Return blank-padded name.
//   if(strlen(p) >= DIRSIZ)
//     return p;
//   memmove(buf, p, strlen(p));
//   memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
//   return buf;
// }