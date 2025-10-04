// SPDX-License-Identifier: GPL-2.0
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/proc_fs.h>
#include <linux/seq_file.h>
#include <linux/jiffies.h>

#define PROC_NAME "versatime"

static int versatime_show(struct seq_file *m, void *v)
{
	seq_printf(m, "jiffies=%lu\n", jiffies);
	seq_printf(m, "HZ=%d\n", HZ);
	return 0;
}

static int versatime_open(struct inode *inode, struct file *file)
{
	return single_open(file, versatime_show, NULL);
}

static const struct proc_ops versatime_fops = {
	.proc_open    = versatime_open,
	.proc_read    = seq_read,
	.proc_lseek   = seq_lseek,
	.proc_release = single_release,
};

static int __init versatime_init(void)
{
	if (!proc_create(PROC_NAME, 0444, NULL, &versatime_fops)) {
		pr_err("versatime: failed to create /proc/%s\n", PROC_NAME);
		return -ENOMEM;
	}
	pr_info("versatime: loaded (/proc/%s)\n", PROC_NAME);
	return 0;
}

static void __exit versatime_exit(void)
{
	remove_proc_entry(PROC_NAME, NULL);
	pr_info("versatime: unloaded\n");
}

module_init(versatime_init);
module_exit(versatime_exit);

MODULE_AUTHOR("Versanode");
MODULE_DESCRIPTION("Procfs time/jiffies demo");
MODULE_LICENSE("GPL");
