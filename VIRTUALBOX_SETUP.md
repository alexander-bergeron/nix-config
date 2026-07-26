# VirtualBox Setup Guide

## VM Configuration Requirements

### Recommended Settings
- **System**: aarch64 (Apple Silicon support)
- **CPU**: 4+ cores
- **RAM**: 4-8GB minimum
- **Storage Controller**: SATA with AHCI (recommended) or NVMe
- **Storage Size**: 150GB+
- **Video Memory**: 128MB
- **3D Acceleration**: Can enable but may cause issues
- **Network**: NAT (default) or Bridged

## Creating the VM

1. Download NixOS aarch64 ISO from https://nixos.org/download
2. Create new VM with settings above
3. Attach ISO and boot
4. At NixOS boot prompt, drop to root shell
5. Change root password: `passwd` (set to "root" for consistency)
6. Find VM IP: `ifconfig` (look for first interface)

## Bootstrap Steps

From your host machine:

### Step 1: Prepare filesystem

Choose the appropriate command based on your storage controller:

**For SATA/AHCI storage controller:**
```bash
export NIXADDR=<vm-ip-address>
export NIXNAME=vm-aarch64-vb

make NIXADDR=$NIXADDR NIXNAME=$NIXNAME vm/bootstrap0-vb-sata
```

**For NVMe storage controller:**
```bash
export NIXADDR=<vm-ip-address>
export NIXNAME=vm-aarch64-vb

make NIXADDR=$NIXADDR NIXNAME=$NIXNAME vm/bootstrap0-vb-nvme
```

The VM will reboot after this completes.

### Step 2: Deploy NixOS configuration

Log in with root/root, then:

```bash
make NIXADDR=$NIXADDR NIXNAME=$NIXNAME vm/bootstrap
```

The VM will reboot again when complete.

## Troubleshooting

### Storage Device Not Found
If you configured a different storage controller:
1. Inside the VM, determine the correct device: `lsblk` or `dmesg | grep ata`
2. Edit `machines/hardware/vm-aarch64-vb.nix` to add/remove kernel modules as needed
3. Or run `nixos-generate-config` inside the VM and update the hardware config accordingly

### Network Not Working
1. Check if DHCP is enabled: `ip addr show`
2. If interface exists but no IP: Check VirtualBox VM network settings
3. Edit `machines/vm-aarch64-vb.nix` and uncomment `networking.interfaces.eth0.useDHCP = true`
4. Run `make NIXADDR=$NIXADDR NIXNAME=$NIXNAME vm/bootstrap` again to apply changes

### Resolution Issues
VirtualBox guest additions should handle resolution automatically. If not:
1. Ensure `virtualisation.virtualbox.guest.enable = true` is set in the config
2. Verify VirtualBox additions are installed: Check system packages
3. Try enabling VMSVGA video controller in VirtualBox settings instead of VBoxSVGA

### Performance Issues
- Ensure CPU cores and RAM allocation are adequate for your workload
- Enable 3D acceleration if your host supports it
- Consider enabling VirtualBox guest additions for better integration

## Differences from Other Hypervisors

### vs. VMware Fusion
- VirtualBox guest additions are simpler but less integrated
- No automatic shared folders (must use NFS/SAMBA)
- Device naming may differ depending on storage controller

### vs. UTM
- VirtualBox is proprietary; UTM uses QEMU
- Completely different guest tools and drivers
- Different performance characteristics

### vs. Parallels
- VirtualBox is free/open-source; Parallels is commercial
- Different guest integration features
- Different display/input handling

## Usage Notes

After initial setup, you can update the configuration with:

```bash
make NIXADDR=$NIXADDR NIXNAME=$NIXNAME vm/bootstrap
```

This will deploy any changes from `machines/vm-aarch64-vb.nix` to the VM.

For day-to-day VM usage without updating configuration, you can SSH directly:

```bash
ssh apb@$NIXADDR
```
