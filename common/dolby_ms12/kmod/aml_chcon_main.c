/*
 * Copyright (C) 2017 Amlogic Corporation.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <linux/init.h>   /* module_init, module_exit */
#include <linux/module.h> /* version info, MODULE_LICENSE, MODULE_AUTHOR, printk() */
#include <linux/xattr.h>  /* vfs_setxattr(), XATTR_NAME_SELINUX   */
#include <linux/fs.h>     /* filp_open(), filp_close(),           */
                          /* file_dentry(), alloc_chrdev_region() */
                          /* unregister_chrdev_region()           */
#ifndef AML_SECURE_LIB
#error AML_SECURE_LIB not defined
// e.g. /odm/lib/ms12/libdolbyms12.so
#endif

#ifndef AML_SECURE_CON
#error AML_SECURE_CON not defined
// e.g. u:object_r:dolby_lib_file:s0
#endif

// #define DEBUG
#ifdef DEBUG
#define AML_CHCON_DBG(x...) printk(KERN_DEBUG x)
#else
#define AML_CHCON_DBG(x...)
#endif

static struct work_struct aml_work;

static void aml_chcon(struct work_struct *work)
{
#ifdef CONFIG_SECURITY
    struct file *f;
    struct dentry *entry;
    if (!IS_ERR(f = filp_open(AML_SECURE_LIB,  O_RDONLY | O_PATH, 0))) {
        if (!IS_ERR(entry = file_dentry(f))) {
            vfs_setxattr(entry, XATTR_NAME_SELINUX, AML_SECURE_CON , sizeof(AML_SECURE_CON), 0);
        }
        filp_close(f, NULL);
    }
#endif
    return;
}

static int __init aml_chcon_module_init(void)
{
    AML_CHCON_DBG("%s\n", __FUNCTION__);

    INIT_WORK(&aml_work, aml_chcon);
    schedule_work(&aml_work);

    return 0;
}

static void __exit aml_chcon_module_exit(void)
{
    AML_CHCON_DBG("%s", __FUNCTION__);
    cancel_work_sync(&aml_work);
}

module_init(aml_chcon_module_init);
module_exit(aml_chcon_module_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Amlogic .");