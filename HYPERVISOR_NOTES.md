# Hypervisor Configuration Status

This document provides an overview of hypervisor support and configuration status in this nix-config.

## Hypervisor Status Summary

| Hypervisor | Architecture | Status | Notes |
|-----------|--------------|--------|-------|
| VMware Fusion | aarch64 | ✅ Fully Working | Primary/tested platform |
| VMware Fusion | x86_64 | ⚠️ Untested | Configuration exists but not tested |
| VirtualBox | aarch64 | 🔨 In Development | New configuration, testing in progress |
| VirtualBox | x86_64 | ❓ Not Configured | Could be added in future |
| Parallels | aarch64 | ⚠️ Untested | Configuration exists but not tested |
| UTM | aarch64 | ⚠️ Untested | Configuration restored, needs testing |
| WSL | x86_64 | ⚠️ Untested | Minimal configuration, untested |

## Configuration Files by Hypervisor

### VMware Fusion (Working)

**Files:**
- `machines/vm-aarch64.nix` - Configuration
- `machines/hardware/vm-aarch64.nix` - Hardware profile
- `modules/vmware-guest.nix` - Custom VMware guest module
- `Makefile` - `vm/bootstrap0` target

**Registration:**
- `flake.nix` - `nixosConfigurations.vm-aarch64`

**Bootstrap:**
```bash
make NIXADDR=<ip> NIXNAME=vm-aarch64 vm/bootstrap0
make NIXADDR=<ip> NIXNAME=vm-aarch64 vm/bootstrap
```

**Notes:**
- Uses `/dev/nvme0n1` for storage (VMware Fusion aarch64 default)
- Custom vmware-guest module provides clipboard/drag-drop support
- Fully integrated and regularly tested

---

### VirtualBox (In Development)

**Files:**
- `machines/vm-aarch64-vb.nix` - Configuration
- `machines/hardware/vm-aarch64-vb.nix` - Hardware profile
- `Makefile` - `vm/bootstrap0-vb-sata` and `vm/bootstrap0-vb-nvme` targets

**Registration:**
- `flake.nix` - `nixosConfigurations.vm-aarch64-vb`

**Bootstrap:**
```bash
# For SATA/AHCI storage:
make NIXADDR=<ip> NIXNAME=vm-aarch64-vb vm/bootstrap0-vb-sata
make NIXADDR=<ip> NIXNAME=vm-aarch64-vb vm/bootstrap

# For NVMe storage:
make NIXADDR=<ip> NIXNAME=vm-aarch64-vb vm/bootstrap0-vb-nvme
make NIXADDR=<ip> NIXNAME=vm-aarch64-vb vm/bootstrap
```

**Notes:**
- New configuration - testing needed
- Supports both SATA and NVMe storage controllers
- Uses built-in NixOS VirtualBox guest additions
- See `VIRTUALBOX_SETUP.md` for detailed setup guide

---

### Parallels (Untested)

**Files:**
- `machines/vm-aarch64-prl.nix` - Configuration
- `machines/hardware/vm-aarch64-prl.nix` - Hardware profile
- `modules/parallels-guest.nix` - Custom Parallels guest module

**Registration:**
- `flake.nix` - `nixosConfigurations.vm-aarch64-prl`

**Notes:**
- Uses QEMU guest profile (Parallels is QEMU-based)
- Custom parallels-guest module provides integration
- No bootstrap targets in Makefile (untested)
- Network interface: `enp0s5`

---

### UTM (QEMU-based - Untested)

**Files:**
- `machines/vm-aarch64-utm.nix` - Configuration
- `machines/hardware/vm-aarch64-utm.nix` - Hardware profile

**Registration:**
- `flake.nix` - `nixosConfigurations.vm-aarch64-utm`

**Notes:**
- Configuration restored to original QEMU intent
- Previously hijacked for VirtualBox testing (now fixed)
- Uses QEMU guest profile for kernel modules
- Optional SPICE agent support for display integration
- Bootstrap target exists: `vm/bootstrap0-utm`
- Network interface (if needed): typically `enp0s10`
- **Status**: Recently restored, needs testing

---

### WSL (Windows Subsystem for Linux)

**Files:**
- `machines/wsl.nix` - Configuration

**Registration:**
- `flake.nix` - `nixosConfigurations.wsl`

**Notes:**
- Minimal configuration
- Uses `nixos-wsl` flake input
- No bootstrap targets (WSL has its own setup process)
- Untested in this configuration

---

### VMware Fusion on Intel

**Files:**
- `machines/vm-intel.nix` - Configuration
- `machines/hardware/vm-intel.nix` - Hardware profile

**Registration:**
- `flake.nix` - `nixosConfigurations.vm-intel`

**Notes:**
- x86_64 architecture
- Uses `/dev/sda` for storage (Intel VMware Fusion default)
- Untested in current nix-config
- Includes shared folder support

---

## Hypervisor Technology Overview

| Hypervisor | Base Technology | Guest Tools | Clipboard | Shared Folders | Resolution Scaling |
|-----------|-----------------|-------------|-----------|-----------------|-------------------|
| VMware Fusion | Proprietary | open-vm-tools | ✅ Yes | ✅ Yes (vmhgfs) | ✅ Excellent |
| VirtualBox | Proprietary | vboxguest | ✅ Yes | ⚠️ Limited | ✅ Good |
| Parallels | QEMU (wrapper) | prl-tools | ✅ Yes | ✅ Yes (prl_fs) | ✅ Good |
| UTM | QEMU | SPICE agent | ⚠️ Via SPICE | ⚠️ Via NFS | ✅ Via SPICE |
| WSL | Native Windows | WSL integration | ✅ Yes | ✅ Yes (auto) | ✅ Native |

## Shared Module Architecture

All VM configurations inherit common settings through this chain:

```
vm-aarch64-vb (or other VM)
    ↓
vm-shared.nix
    ↓
    ├── modules/common-nix-configuration.nix
    ├── modules/common-fonts.nix
    └── modules/common-nixpkgs-config.nix
```

This ensures:
- Consistent nix flakes configuration across all platforms
- Unified font management
- Consistent nixpkgs settings (allowUnfree, etc.)

Hypervisor-specific settings stay in individual machine configs.

## Bootstrap Targets in Makefile

```makefile
# VMware Fusion (aarch64)
make NIXADDR=<ip> NIXNAME=vm-aarch64 vm/bootstrap0

# VirtualBox SATA
make NIXADDR=<ip> NIXNAME=vm-aarch64-vb vm/bootstrap0-vb-sata

# VirtualBox NVMe
make NIXADDR=<ip> NIXNAME=vm-aarch64-vb vm/bootstrap0-vb-nvme

# UTM (QEMU)
make NIXADDR=<ip> NIXNAME=vm-aarch64-utm vm/bootstrap0-utm

# Any VM (finalize after bootstrap0)
make NIXADDR=<ip> NIXNAME=<config-name> vm/bootstrap
```

## Storage Device Mapping

Different hypervisors use different device names:

| Hypervisor | aarch64 Device | x86_64 Device |
|-----------|----------------|---------------|
| VMware Fusion | `/dev/nvme0n1` | `/dev/sda` |
| VirtualBox (SATA) | `/dev/sda` | `/dev/sda` |
| VirtualBox (NVMe) | `/dev/nvme0n1` | `/dev/nvme0n1` |
| Parallels | Auto (qemu-guest) | Auto (qemu-guest) |
| UTM | `/dev/vda` | `/dev/vda` |

## Adding Support for New Hypervisors

To add a new hypervisor:

1. Create `machines/vm-<name>.nix` with hypervisor-specific config
2. Create `machines/hardware/vm-<name>.nix` with kernel module config
3. Create custom module in `modules/` if needed (e.g., for guest tools)
4. Register in `flake.nix` under `nixosConfigurations`
5. Add bootstrap target(s) to `Makefile` if applicable
6. Add entry to this document

## Future Work

- [ ] Test Parallels configuration
- [ ] Test UTM configuration  
- [ ] Test VMware Fusion on Intel
- [ ] Add x86_64 VirtualBox configuration
- [ ] Test WSL configuration
- [ ] Consider hardware auto-detection for device names
