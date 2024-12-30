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

If you're using this configuration with the user `apb` this process will prompt you to change some settings for security and privacy to allow certain apps to have certain access. After running this you'll need to run an additional time after everything is initialized with the following command.

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
