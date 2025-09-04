kbi hwver
echo "Start OpenWrt mainline U-boot ... hwver: $hwver hostname: $hostname maxcpus: $maxcpus fdt: $fdtfile source: $boot_source:$BOOTED target: $target"
# if printenv bootfromsd; then exit; fi;
setenv loadaddr "0x44000000"
setenv l_interface "usb mmc"
setenv l_dev "3 2 1 0"
setenv l_part "0 1 2 3"
for i in ${l_interface} ; do
	for d in ${l_dev} ; do
		for p in ${l_part} ; do
			echo [i] Scaning ${i} ${d}:${p}
			if test -e ${i} ${d}:${p} uEnv.txt; then
				echo [i] Found uEnv.txt on ${i} ${d}:${p}
				echo [i] Starting from ${i} ${d}:${p}
				part uuid ${i} ${d}:2 puuid
				load ${i} ${d}:${p} ${loadaddr} uEnv.txt
				env import -t ${loadaddr} ${filesize}
				setenv bootargs root=PARTUUID=${puuid} ${APPEND}
				if printenv mac; then
					setenv bootargs ${bootargs} mac=${mac}
				elif printenv eth_mac; then
					setenv bootargs ${bootargs} mac=${eth_mac}
				elif printenv ethaddr; then
					setenv bootargs ${bootargs} mac=${ethaddr}
				fi
				if load ${i} ${d}:${p} ${kernel_addr_r} ${LINUX}; then
					echo [i] load kernel
					if load ${i} ${d}:${p} ${ramdisk_addr_r} ${INITRD}; then
						echo [i] load initrd
						if load ${i} ${d}:${p} ${fdt_addr_r} ${FDT}; then
							echo [i] load dtb
							fdt addr ${fdt_addr_r}
							booti ${kernel_addr_r} ${ramdisk_addr_r} ${fdt_addr_r}
						fi
					fi
				fi
			fi
		done
	done
done
# Recompile with:
# mkimage -C none -A arm -T script -d /boot/boot.cmd /boot/boot.scr
