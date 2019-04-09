#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/version.h>
#include <linux/kmod.h>
#include <linux/input.h>
#include <linux/mtd/mtd.h>
#include <linux/slab.h>
#include <linux/string.h>

#define DRV_NAME "mtd_locked"

int mtd_locked(void)
{
	struct mtd_info *mtd;
	int x;
	bool keep_going = true;
	char *mtd_name = NULL;
	char *delim = ":";
	char *token = NULL;
	char *p = NULL;

	mtd_name = (char *)kmalloc(GFP_KERNEL, strlen(CONFIG_KMOD_MTD_LOCKED_MTD_NAME) + 1);
	if(mtd_name == NULL)
		return -1;
	memset(mtd_name, 0, strlen(CONFIG_KMOD_MTD_LOCKED_MTD_NAME) + 1);
	strcpy(mtd_name, CONFIG_KMOD_MTD_LOCKED_MTD_NAME);
	p = mtd_name;

	while (1) {
		token = strsep(&p, delim);
		if(token == NULL)
			break;
		keep_going = true;
		for (x = 0; keep_going; x++) {
			mtd = get_mtd_device(NULL, x);
			if (!IS_ERR(mtd)) {
				if (!strcmp(mtd->name, token)) {
					printk("mtd: %s locked\n", mtd->name);
					mtd->flags &= ~(MTD_WRITEABLE);
					put_mtd_device(mtd);
					break;
				}
			} else {
				keep_going = false;
			}
		}
	}
	kfree(mtd_name);
	return 0;
}

static int __init mtd_lock_init(void)
{
	if(mtd_locked() == -1)
		return -ENOMEM;
	printk(DRV_NAME " init\n");

	return 0;
}

static void __exit mtd_lock_exit(void)
{
	printk(DRV_NAME " exit\n");
}

module_init(mtd_lock_init);
module_exit(mtd_lock_exit);

MODULE_DESCRIPTION(DRV_NAME);
MODULE_AUTHOR("__MSTC__, Smith");
MODULE_LICENSE("GPL");

