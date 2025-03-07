# nix-config

My development machine configuration using a combination of nix, nix-darwin, and nixos.

Credit to Mitchell Hashimoto for doing the leg work and sharing his [config](https://github.com/mitchellh/nixos-config). Before starting I recommend checking out his repo and watch his setup video. As Mitchell has mentioned in his video dont attempt to clone this down and blindly run expecting to work. This is specifically configured to work for my user `apb`.

If you would like to use this as a starting point for creating your own configuration I would recommend starting with the scaffolding of the configuration and adapting to your needs.

If you really want to YOLO it for your machine, a starting point would be to go in and replace all the cases where the user is set to `apb` and replace with your user but this is not recommend.

**Files need to be tracked in git to work with nix. If setting up your own configuration make sure to add files.**

## Background

I recently switched to using nix and nix-darwin to manage my dev machine. I personally very much enjoy the declarative nature of nix and nix-darwin and maintaining all my configurations in a single place. I started this journey by transitioning to neovim last year and using kickstart to manage my configuration. Nix felt like it was the next step in my journey in attempting to capture my entire machine configuration in a single reproducible location. I tend to re-image my machine once every six months or so and this allows me to rebuild my exact configuration on the new instance of the machine and then simply copy back over a backup of my files.

I will preface that I am not an expert in nix or nix-darwin, nor have I dont a true deep dive into all the functionality it has to offer. I have learned by compiling various examples across videos, blog posts, and example configurations to find what works best for me. 

## Known Issues

1. UTM is currently not working.

2. WSL and Parallels are untested.

3. Intel configurations are untested.

## Resetting macOS

* Note these are from memory and I have had some inconsistent behavior when performing these steps multiple times.

1. Navigate to settings and select `Transfer or Reset` followed by `Erase All Content and Settings`.

2. Once complete you should be brought to a recovery screen and asked to connect to a network to register your mac. Do this then in the top left click the apple logo and click `Erase Mac`. As the machine restarts press `shift-option-command-R` to enter the recovery mode - click on disk utility and erase the main hard drive.

3. Click reinstall macOS that ships with your machine.

4. Once complete setup your machine and create your account.

5. Update your machine to the latest version of macOS.

## macOS (darwin) Quickstart - fresh machine

1. Install [`nix`](https://nixos.org/) package manager.

```bash
sh <(curl -L https://nixos.org/nix/install)
```
**Optionally use determinate systems**

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

2. Initialize [`nix-darwin`](https://github.com/LnL7/nix-darwin).

* Nix Darwin allows you to use nix flakes to configure your darwin based machine. For more detail follow the instructions in the nix-darwin README.md.

<details>
<summary>Getting started from scratch</summary>
<p></p>

```bash
mkdir -p ~/.config/nix-dar
cd ~/.config/nix-darwin
nix flake init -t nix-darwin --extra-experimental-features "nix-command flakes"
```
Optionally, update the configuration name from `simple` to your machine name.

Make sure to change `nixpkgs.hostPlatform` to `aarch64-darwin` if you are using Apple Silicon.

</details>

<details>
<summary>Using Existing Configuration</summary>
<p></p>

1. Clone down existing configuration or copy from a backup, in this example we have done this here `~/.dotfiles/nix-config`.

2. Run the switch command for the new configuration, in this example `macbook-pro-m1`.

```bash
nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/.dotfiles/nixos-config#macbook-pro-m1 --show-trace
```

If you're using this configuration with the user `apb` this process will prompt you to change some settings for security and privacy to allow certain apps to have certain access. After running this you'll need to run an additional time after everything is initialized with the following command. Optionally use `--recreate-lock-file` to upgrade packages, you will get a warning `'--recreate-lock-file' is deprecated and will be removed in a future version; use 'nix flake update' instead.` so thats an option too.

```bash
darwin-rebuild switch --flake ~/.dotfiles/nix-config#macbook-pro-m1 --show-trace
```

Once all the installs are complete and settings adjusted you'll want to restart your machine for some of the system settings to be applied.

</details>

### Misc.

1. Cleanup permissions from FAT format. Do this for anything copied over (with caution if these dont match what you expect).

```bash
find /path/to/directory -type d -exec chmod 755 {} \;

find /path/to/directory -type f -exec chmod 644 {} \;
```

## NixOS Setup in VMWare Fusion

<details>
<summary>Mitchell's instructions</summary>
<br>

[Github Repo](https://raw.githubusercontent.com/mitchellh/nixos-config/refs/heads/main/README.md)

Video: https://www.youtube.com/watch?v=ubDMLoWz76U

**Note:** This setup guide will cover VMware Fusion because that is the
hypervisor I use day to day. The configurations in this repository also
work with UTM (see `vm-aarch64-utm`) and Parallels (see `vm-aarch64-prl`) but
I'm not using that full time so they may break from time to time. I've also
successfully set up this environment on Windows with VMware Workstation and
Hyper-V.

You can download the NixOS ISO from the
[official NixOS download page](https://nixos.org/download.html#nixos-iso).
There are ISOs for both `x86_64` and `aarch64` at the time of writing this.

Create a VMware Fusion VM with the following settings. My configurations
are made for VMware Fusion exclusively currently and you will have issues
on other virtualization solutions without minor changes.

  * ISO: NixOS 23.05 or later.
  * Disk: SATA 150 GB+
  * CPU/Memory: I give at least half my cores and half my RAM, as much as you can.
  * Graphics: Full acceleration, full resolution, maximum graphics RAM.
  * Network: Shared with my Mac.
  * Remove sound card, remove video camera, remove printer.
  * Profile: Disable almost all keybindings
  * Boot Mode: UEFI

Boot the VM, and using the graphical console, change the root password to "root":

```
$ sudo su
$ passwd
# change to root
```

At this point, verify `/dev/sda` exists. This is the expected block device
where the Makefile will install the OS. If you setup your VM to use SATA,
this should exist. If `/dev/nvme` or `/dev/vda` exists instead, you didn't
configure the disk properly. Note, these other block device types work fine,
but you'll have to modify the `bootstrap0` Makefile task to use the proper
block device paths.

Also at this point, I recommend making a snapshot in case anything goes wrong.
I usually call this snapshot "prebootstrap0". This is entirely optional,
but it'll make it super easy to go back and retry if things go wrong.

Run `ifconfig` and get the IP address of the first device. It is probably
`192.168.58.XXX`, but it can be anything. In a terminal with this repository
set this to the `NIXADDR` env var:

```
$ export NIXADDR=<VM ip address>
```

The Makefile assumes an Intel processor by default. If you are using an
ARM-based processor (M1, etc.), you must change `NIXNAME` so that the ARM-based
configuration is used:

```
$ export NIXNAME=vm-aarch64
```

**Other Hypervisors:** If you are using Parallels, use `vm-aarch64-prl`.
If you are using UTM, use `vm-aarch64-utm`. Note that the environments aren't
_exactly_ equivalent between hypervisors but they're very close and they
all work.

Perform the initial bootstrap. This will install NixOS on the VM disk image
but will not setup any other configurations yet. This prepares the VM for
any NixOS customization:

```
$ make vm/bootstrap0
```

After the VM reboots, run the full bootstrap, this will finalize the
NixOS customization using this configuration:

```
$ make vm/bootstrap
```

You should have a graphical functioning dev VM.

At this point, I never use Mac terminals ever again. I clone this repository
in my VM and I use the other Make tasks such as `make test`, `make switch`, etc.
to make changes my VM.

</details>

* Mitchell's video covers these steps very well, this is just for a quick reference.

1. Install VMWare Fusion on your host machine.

2. Download the nixos minimal image from the nix website.

3. Create a new VM using the nixos image. Configure to your needs.

4. Start the VM - run the installer - switch to `root` user and reset the password with `passwd`.

5. Use `ifconfig` to get the ip address of your VM.

6. On your host machine use the `Makefile` to initialize the machine. `vm/bootstrap0` builds a base instance. Wait for the instance to reboot.

```bash
# adjust NIXNAME as needed for your use case (if using intel based or utm etc.)
# replace below with your ip and username
make NIXADDR=$YOUR_VM_IP NIXUSER=$YOUR_USERNAME NIXNAME=vm-aarch64 vm/bootstrap0
```

7. Use the `Makefile` to install your configuration to the VM. `vm/bootstrap` will take care of this.

```bash
# adjust NIXNAME as needed for your use case (if using intel based or utm etc.)
make NIXADDR=$YOUR_VM_IP NIXUSER=$YOUR_USERNAME NIXNAME=vm-aarch64 vm/bootstrap
```

8. This will take some time to install. Once complete the VM should reboot.

9. Login to the VM - initial password is `root`. Reset the password to something more secure.

10. Repeat `vm/bootstrap` if you need to update the VM with the latest changes to your configuration.

### VM Post Setup Tweaks

1. Run the following to improve scaling when in full screen mode (green button on macOS).

```bash
# add 125% to display settings - https://www.linuxuprising.com/2019/04/how-to-enable-hidpi-fractional-scaling.html
# will need to determine how to bake this into the config
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
```
