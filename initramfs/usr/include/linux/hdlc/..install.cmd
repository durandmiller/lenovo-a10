cmd_/home/durand/projects/public/lenovo-a10/initramfs/usr//include/linux/hdlc/.install := perl scripts/headers_install.pl /home/durand/projects/public/lenovo-a10/kernels/linux-3.0.36/include/linux/hdlc /home/durand/projects/public/lenovo-a10/initramfs/usr//include/linux/hdlc arm ioctl.h; perl scripts/headers_install.pl /home/durand/projects/public/lenovo-a10/kernels/linux-3.0.36/include/linux/hdlc /home/durand/projects/public/lenovo-a10/initramfs/usr//include/linux/hdlc arm ; for F in ; do echo "\#include <asm-generic/$$F>" > /home/durand/projects/public/lenovo-a10/initramfs/usr//include/linux/hdlc/$$F; done; touch /home/durand/projects/public/lenovo-a10/initramfs/usr//include/linux/hdlc/.install