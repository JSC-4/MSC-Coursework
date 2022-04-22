#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int main(int argc, char **argv)
{
    
    char *app_name = argv[0];
    char *dev_name = "/dev/hcsr04";
    
    int fd = -1;
    char c = 1;
    int d[8];
    
    /* Open the dev/hcsr04 module in read/write mode and check if it was unsuccessful */
    fd = open(dev_name, O_RDWR);
    if (fd == -1)
    {
        printf("Error opening file");
        exit(-1);
    }
   
    /* Store the argument from the command line into a variable, and convert it into a interger*/
    char *a = argv[1];
    int iter = atoi(a);
  
    /* Based on the input recieved, iterate the write/read process and print the pulse, distance and timesamp */
    for (int i = 0; i < iter; i++)
    {
        write( fd, &c, 1 );
    	read( fd, &d, sizeof(d));
    	printf("Pulse: %d(ms), Distance: %dcm, Timestamp: %d/%d/%d %d:%d:%d\n", d[0], d[1], d[2], d[3], d[4], d[5], d[6], d[7]);
        sleep(1);   // Used to do one iteration per second
    }

    /* Close the file descriptor and check if it was unsuccessful */
    if (close(fd) == -1)
    {
        printf("Error closing file descriptor");
        exit(-1);
    }

    return 0;
}