#include <linux/module.h>
#include <linux/init.h>
#include <linux/kernel.h>

#include <linux/types.h>
#include <linux/kdev_t.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/uaccess.h>
#include <asm/uaccess.h>

#include <linux/gpio.h>

#include <linux/interrupt.h>

#include <asm/delay.h>
#include <linux/delay.h>

#include <linux/time.h>
#include <linux/ktime.h>
#include <linux/timekeeping.h>

/* Define the GPIO pins used for the sensor */
#define GPIO_OUT 20 // GPIO20
#define GPIO_IN 21  // GPIO21

/* Size of space to allocate for arrays */
#define SIZE    70

/* Create a struct to hold information about the device i.e. major/minor number, and properties */
static dev_t hcsr04_dev;
struct cdev hcsr04_cdev;

/* This flag will stop multiple processes trying to use the module */
static int hcsr04_lock = 0;

/* Create a kernel object */
static struct kobject *hcsr04_kobject;

/* Variables used to calculate the duration */
static ktime_t rising, falling;

/* Struct used to access the kernel time*/
struct timespec tv;
struct tm ts;

/* Date to hold the last eight readings */
int data[8];

/* Create five string arrays*/
char *str_array[5];

/* Function to shift the string arrays */
void shift(void)
{
    strcpy(str_array[4],str_array[3]);
    strcpy(str_array[3],str_array[2]);
    strcpy(str_array[2],str_array[1]);
    strcpy(str_array[1],str_array[0]);
}

/* When the module is open, lock other processes trying to access it */
int hcsr04_open(struct inode *inode, struct file *file)
{
    int ret = 0;

    if (hcsr04_lock > 0)
        ret = -EBUSY;
    else
        hcsr04_lock++;

    return (ret);
}

/* Free the module for another process to use */
int hcsr04_close(struct inode *inode, struct file *file)
{
    hcsr04_lock = 0;

    return (0);
}


/* Read the data to the userspace. Count is the size of the return data requested by the user space.
   In this case requesting eight bytes would return the most recent reading */
ssize_t hcsr04_read(struct file *filp, char __user *buf, size_t count, loff_t *f_pos)
{
    int ret;

    ret = copy_to_user(buf, &data, count);

    return count;
}

ssize_t hcsr04_write(struct file *filp, const char *buffer, size_t length, loff_t *offset)
{
    /* Trigger the sensor and read how long the pulse duration is */
    gpio_set_value(GPIO_OUT, 0);
    gpio_set_value(GPIO_OUT, 1);
    udelay(10);
    gpio_set_value(GPIO_OUT, 0);

    while (gpio_get_value(GPIO_IN) == 0)
        ;
    rising = ktime_get();

    while (gpio_get_value(GPIO_IN) == 1)
        ;
    falling = ktime_get();

    /* Calculate the kernel time*/
    getnstimeofday(&tv);
    time64_to_tm(tv.tv_sec, 0, &ts);

    /* Shift the strings */
    shift();

   /* Write the most recent data to the array*/
    data[0] = ktime_to_us(ktime_sub(falling, rising));
    data[1] = data[0] / 58;
    data[2] = ts.tm_mday;
    data[3] = ts.tm_mon + 1;
    data[4] = ts.tm_year - 100;
    data[5] = ts.tm_hour;
    data[6] = ts.tm_min;
    data[7] = ts.tm_sec;

    /* Turn the data into a string */
    sprintf(str_array[0], "Pulse: %d(ms), Distance: %dcm, Timestamp: %d/%d/%d %d:%d:%d\n", data[0], data[1], data[2], 
                                                                                           data[3], data[4], data[5], 
                                                                                           data[6], data[7]);

    return (1);
}

/* Create a struct for the VFS operations */
struct file_operations hcsr04_fops = {
    .owner = THIS_MODULE,
    .read = hcsr04_read,
    .write = hcsr04_write,
    .open = hcsr04_open,
    .release = hcsr04_close,
};


/* Return the last reading to this file */
static ssize_t hcsr04_show_1(struct kobject *kobj, struct kobj_attribute *attr, char *buf)
{
    return sprintf(buf, "Pulse: %d(ms), Distance: %dcm, Timestamp: %d/%d/%d %d:%d:%d\n", data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7]);
}

static ssize_t hcsr04_store_1(struct kobject *kobj, struct kobj_attribute *attr, const char *buf, size_t count)
{

    return 1;
}

/* Return the last five readings to this file */
static ssize_t hcsr04_show_2(struct kobject *kobj, struct kobj_attribute *attr, char *buf)
{
    return sprintf(buf, "%s%s%s%s%s", str_array[4],str_array[3],str_array[2],str_array[1],str_array[0]);
}

static ssize_t hcsr04_store_2(struct kobject *kobj, struct kobj_attribute *attr, const char *buf, size_t count)
{

    return 1;
}

/* Create two attributes, for both files */
static struct kobj_attribute hcsr04_attribute1 = __ATTR(hcsr04_last_reading, 0660, hcsr04_show_1, hcsr04_store_1);
static struct kobj_attribute hcsr04_attribute2 = __ATTR(hcsr04_last_five_readings, 0660, hcsr04_show_2, hcsr04_store_2);

static int __init hcsr04_module_init(void)
{
    int i;
    char buffer[64];

    /* Create a new character device in the Linux kernel */
    alloc_chrdev_region(&hcsr04_dev, 0, 1, "hcsr04_dev");
    printk(KERN_INFO "%s\n", format_dev_t(buffer, hcsr04_dev));
    cdev_init(&hcsr04_cdev, &hcsr04_fops);
    hcsr04_cdev.owner = THIS_MODULE;
    cdev_add(&hcsr04_cdev, hcsr04_dev, 1);

    /* Reserve the GPIO pins used for the sensor */
    gpio_request(GPIO_OUT, "hcsr04_dev");
    gpio_request(GPIO_IN, "hcsr04_dev");
    gpio_direction_output(GPIO_OUT, 0);
    gpio_direction_input(GPIO_IN);

    /* Create a kernel object, and two files to either read the last value sent or the last five values */
    hcsr04_kobject = kobject_create_and_add("hcsr04", kernel_kobj);
    sysfs_create_file(hcsr04_kobject, &hcsr04_attribute1.attr);
    sysfs_create_file(hcsr04_kobject, &hcsr04_attribute2.attr);

    /* Allocte memory for string arrays */
    for (i = 0; i < 5; i++)
    {
        str_array[i] = (char*)kmalloc_array(SIZE, sizeof(char), GFP_KERNEL);
    }
    return 0;
}

/* Close the module, and clean up the resources used */
static void __exit hcsr04_module_cleanup(void)
{
    gpio_free(GPIO_OUT);
    gpio_free(GPIO_IN);

    hcsr04_lock = 0;
    cdev_del(&hcsr04_cdev);
    unregister_chrdev_region(hcsr04_dev, 1);
    kobject_put(hcsr04_kobject);

    int i;

    /* Free allocated memory */
    for (i = 0; i < 5; i++)
    {
        kfree(str_array[i]);
    }
}

module_init(hcsr04_module_init);
module_exit(hcsr04_module_cleanup);

MODULE_AUTHOR("Jerome Samuels-Clarke");
MODULE_LICENSE("GPL");
