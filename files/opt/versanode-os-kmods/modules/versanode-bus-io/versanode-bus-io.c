// SPDX-License-Identifier: GPL-2.0
/*
 * versanode-bus-io: dummy misc device for future VersaNode I/O bus
 * Creates /dev/versanode-bus-io and logs open/close/ioctl calls.
 */
#include <linux/init.h>
#include <linux/module.h>
#include <linux/miscdevice.h>
#include <linux/fs.h>
#include <linux/uaccess.h>

#define DRV_NAME "versanode-bus-io"

static int vn_open(struct inode *inode, struct file *file)
{
    pr_info(DRV_NAME ": open\n");
    return 0;
}

static int vn_release(struct inode *inode, struct file *file)
{
    pr_info(DRV_NAME ": release\n");
    return 0;
}

static long vn_unlocked_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
{
    pr_info(DRV_NAME ": ioctl cmd=0x%x arg=0x%lx (noop)\n", cmd, arg);
    return 0;
}

static const struct file_operations vn_fops = {
    .owner          = THIS_MODULE,
    .open           = vn_open,
    .release        = vn_release,
    .unlocked_ioctl = vn_unlocked_ioctl,
#ifdef CONFIG_COMPAT
    .compat_ioctl   = vn_unlocked_ioctl,
#endif
};

static struct miscdevice vn_miscdev = {
    .minor = MISC_DYNAMIC_MINOR,
    .name  = DRV_NAME,
    .fops  = &vn_fops,
    .mode  = 0660,
};

static int __init vn_init(void)
{
    int ret = misc_register(&vn_miscdev);
    if (ret) {
        pr_err(DRV_NAME ": misc_register failed: %d\n", ret);
        return ret;
    }
    pr_info(DRV_NAME ": loaded, /dev/%s ready\n", DRV_NAME);
    return 0;
}

static void __exit vn_exit(void)
{
    misc_deregister(&vn_miscdev);
    pr_info(DRV_NAME ": unloaded\n");
}

module_init(vn_init);
module_exit(vn_exit);

MODULE_AUTHOR("Versa-Node");
MODULE_DESCRIPTION("VersaNode dummy bus I/O device");
MODULE_LICENSE("GPL");
MODULE_VERSION("0.1.0");
