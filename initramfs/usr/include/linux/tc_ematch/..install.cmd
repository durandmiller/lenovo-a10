cmd_/home/durand/projects/public/lenovo-a10/initramfs/usr//include/linux/tc_ematch/.install := perl scripts/headers_install.pl /home/durand/projects/public/lenovo-a10/kernels/linux-3.0.36/include/linux/tc_ematch /home/durand/projects/public/lenovo-a10/initramfs/usr//include/linux/tc_ematch arm tc_em_cmp.h tc_em_meta.h tc_em_nbyte.h tc_em_text.h; perl scripts/headers_install.pl /home/durand/projects/public/lenovo-a10/kernels/linux-3.0.36/include/linux/tc_ematch /home/durand/projects/public/lenovo-a10/initramfs/usr//include/linux/tc_ematch arm ; for F in ; do echo "\#include <asm-generic/$$F>" > /home/durand/projects/public/lenovo-a10/initramfs/usr//include/linux/tc_ematch/$$F; done; touch /home/durand/projects/public/lenovo-a10/initramfs/usr//include/linux/tc_ematch/.install