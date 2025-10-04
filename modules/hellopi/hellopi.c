// SPDX-License-Identifier: GPL-2.0
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/miscdevice.h>
#include <linux/fs.h>
#include <linux/uaccess.h>
#include <linux/device.h>

#define HELLOPI_MAX 128

static char greeting[HELLOPI_MAX] = "hello from kernel";
module_param_string(greeting, greeting, sizeof(greeting), 0644);
MODULE_PARM_DESC(greeting, "String returned by /dev/hellopi and exposed in sysfs");

static ssize_t hellopi_read(struct file *f, char __user *buf, size_t len, loff_t *ppos)
{
	char kbuf[HELLOPI_MAX + 2];
	size_t n;

	if (*ppos > 0)
		return 0; /* EOF after first read */

	n = scnprintf(kbuf, sizeof(kbuf), "%s\n", greeting);
	if (n > len)
		n = len;
	if (copy_to_user(buf, kbuf, n))
		return -EFAULT;
	*ppos = n;
	return n;
}

static ssize_t hellopi_write(struct file *f, const char __user *buf, size_t len, loff_t *ppos)
{
	char kbuf[HELLOPI_MAX];
	size_t n = min(len, (size_t)(HELLOPI_MAX - 1));
	if (copy_from_user(kbuf, buf, n))
		return -EFAULT;
	kbuf[n] = '\0';
	if (n && kbuf[n - 1] == '\n')
		kbuf[n - 1] = '\0';
	strscpy(greeting, kbuf, sizeof(greeting));
	pr_info("hellopi: greeting set to '%s'\n", greeting);
	return len;
}

static const struct file_operations hellopi_fops = {
	.owner = THIS_MODULE,
	.read  = hellopi_read,
	.write = hellopi_write,
	.llseek = no_llseek,
};

static struct miscdevice hellopi_dev = {
	.minor = MISC_DYNAMIC_MINOR,
	.name  = "hellopi",
	.fops  = &hellopi_fops,
	.mode  = 0666, /* demo: world rw */
};

/* sysfs attribute mirroring the greeting */
static ssize_t greeting_show(struct device *dev, struct device_attribute *attr, char *buf)
{
	return sysfs_emit(buf, "%s\n", greeting);
}

static ssize_t greeting_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
{
	size_t n = min(count, (size_t)(HELLOPI_MAX - 1));
	char tmp[HELLOPI_MAX];
	memcpy(tmp, buf, n);
	tmp[n] = '\0';
	if (n && tmp[n - 1] == '\n')
		tmp[n - 1] = '\0';
	strscpy(greeting, tmp, sizeof(greeting));
	pr_info("hellopi: greeting set via sysfs to '%s'\n", greeting);
	return count;
}

static DEVICE_ATTR_RW(greeting);

static int __init hellopi_init(void)
{
	int ret = misc_register(&hellopi_dev);
	if (ret) {
		pr_err("hellopi: misc_register failed: %d\n", ret);
		return ret;
	}
	ret = device_create_file(hellopi_dev.this_device, &dev_attr_greeting);
	if (ret) {
		pr_err("hellopi: device_create_file failed: %d\n", ret);
		misc_deregister(&hellopi_dev);
		return ret;
	}
	pr_info("hellopi: loaded (device /dev/hellopi)\n");
	return 0;
}

static void __exit hellopi_exit(void)
{
	device_remove_file(hellopi_dev.this_device, &dev_attr_greeting);
	misc_deregister(&hellopi_dev);
	pr_info("hellopi: unloaded\n");
}

module_init(hellopi_init);
module_exit(hellopi_exit);

MODULE_AUTHOR("Versanode");
MODULE_DESCRIPTION("Tiny misc device example with DKMS");
MODULE_LICENSE("GPL");
