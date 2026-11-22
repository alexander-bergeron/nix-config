# Upgrade lifecycle

This repo is a Nix flake. Desired state lives in the `.nix` files. Exact input revisions live in `flake.lock`. The machine changes only after a rebuild and switch. Editing a file, updating the lock, and switching are three separate steps.

Two package sources are in play:

- **Nix packages**, from the locked `nixpkgs` input (`nixos-26.05`) and, for a few apps, the locked `nixpkgs-unstable` input.
- **Homebrew casks**, declared in `users/apb/darwin.nix` and installed through nix-darwin plus nix-homebrew. Tap contents come from the locked `homebrew-core` and `homebrew-cask` inputs.

`home-manager`, `nix-darwin`, and `nixos-wsl` follow the root `nixpkgs` input, so they evaluate against the same nixpkgs revision as the rest of the flake. Their own repository revisions are still separate lock entries.

## Where a change goes

| Kind of change | File | Lock update |
| --- | --- | --- |
| Add, remove, or retarget a Nix app | `users/apb/home-manager/default.nix` | Only if that input's revision must move |
| App or shell settings (git, zsh, tmux, starship, ghostty, opencode, alacritty, neovim) | `users/apb/home-manager/programs/*.nix` | No |
| Add, remove, or mark a Homebrew cask | `users/apb/darwin.nix` (`homebrew.casks`) | `homebrew-cask` (and `homebrew-core` if a formula is involved) when the locked tap does not contain the name yet |
| Homebrew taps, brew cleanup, brew upgrade-on-switch | `users/apb/darwin.nix` and `lib/mksystem.nix` | `homebrew-core`, `homebrew-cask`, `nix-homebrew` |
| Roll package versions forward on the current 26.05 branch | `flake.lock` only | `nixpkgs`, and `nixpkgs-unstable` for apps on `pkgs-unstable` |
| Move the whole system to a new NixOS / nix-darwin / home-manager release | `flake.nix` inputs, then `flake.lock` | All three release inputs together |
| Nix the package manager (the `nix` binary) | Outside the flake | No |

Nix only sees files that git is tracking. `git add` a new `.nix` file before building.

Commit `flake.lock` in the same change as any `flake.nix` or package-list edit that caused it. The lockfile is the pin. A switch on another machine uses the committed lock, so the same revisions are built there.

## Apply the result

Run the switch that matches the machine. Do this after the file edit and, when a section below calls for it, after the lock update.

macOS (`darwinConfigurations.macbook-pro-m1`):

```bash
sudo NIXPKGS_ALLOW_BROKEN=1 darwin-rebuild switch \
  --flake ~/workspaces/github.com/alexander-bergeron/nix-config#macbook-pro-m1 \
  --show-trace --impure
```

The Makefile target is the same switch when `NIXNAME` is set (its default is the VMware guest, `vm-aarch64`):

```bash
make NIXNAME=macbook-pro-m1 switch
```

`make NIXNAME=macbook-pro-m1 check` builds and runs `darwin-rebuild check` before a switch.

NixOS VM, from the host after the guest is up. `NIXNAME` is `vm-aarch64`, `vm-aarch64-prl`, `vm-aarch64-utm`, `vm-aarch64-vb`, `vm-intel`, or `wsl`:

```bash
make NIXADDR=$VM_IP NIXUSER=$USER NIXNAME=vm-aarch64 vm/copy
make NIXADDR=$VM_IP NIXUSER=$USER NIXNAME=vm-aarch64 vm/switch
```

`vm/switch` runs:

```bash
sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch \
  --flake "/nix-config#vm-aarch64" --show-trace
```

Homebrew activation runs only on the Darwin switch. `users/apb/darwin.nix` sets `homebrew.onActivation.autoUpdate`, `upgrade`, and `cleanup = "zap"`. A Darwin switch updates Homebrew, upgrades casks, and removes casks that are no longer in the list.

## 1. Edit one file and leave versions where they are

Use this when the change is configuration: a git setting, a zsh alias, an opencode model entry, a dock entry, a comment, a new cask or package that already exists in the locked inputs.

1. Edit the file from the table above.
2. Leave `flake.lock` untouched. Skip `nix flake update`.
3. Track the file in git if it is new.
4. Switch with the command for that machine.

The running system picks up the new module. Package versions stay on the revisions already in `flake.lock`.

If the build reports that an attribute or cask name does not exist, the locked input is too old for that name, or the name is wrong. Fix the name, or follow the single-app or Homebrew section so only the needed input moves.

## 2. Upgrade one Nix application

An app has no version field in this flake. `pkgs.neovim` is whatever the locked `nixpkgs` revision builds. `pkgs-unstable.neovim` is whatever the locked `nixpkgs-unstable` revision builds. `lib/mksystem.nix` imports `nixpkgs-unstable` and passes it into home-manager as `pkgs-unstable`.

Today `pkgs-unstable` is used for `neovim` and `opencode`. Everything else in `home.packages` comes from stable `pkgs`.

### Newer build of an app that is already on unstable

This rolls every package read from `pkgs-unstable` (`neovim`, `opencode`, and any later addition). Stable `pkgs` stays put.

```bash
nix flake update nixpkgs-unstable
```

Switch, then commit `flake.lock`.

### Newer build of one stable app, rest of 26.05 stays put

Move that one attribute from `pkgs` to `pkgs-unstable` in `users/apb/home-manager/default.nix`:

```nix
pkgs-unstable.go
```

If unstable's lock is already current enough, switch with no lock change. If the version you want landed after the locked unstable revision:

```bash
nix flake update nixpkgs-unstable
```

Switch, then commit the `.nix` edit and `flake.lock`.

### Newer build of a stable app by moving the whole stable set

`nixos-26.05` keeps receiving package bumps. Updating the `nixpkgs` input moves every `pkgs.*` attribute along that branch. `home-manager` and `nix-darwin` follow it, so their nixpkgs view moves with it. Their own source revisions stay until those inputs are named in the update.

```bash
nix flake update nixpkgs
```

Switch, then commit `flake.lock`. Read the build. A stable-branch bump can still change more than the one app you had in mind, because the input is the whole package set.

### One app with a local override

`users/apb/darwin.nix` already does this for `go-migrate-pg` (`overrideAttrs` to set build tags). Use an overlay when the needed change is a build flag or a source override on top of the locked nixpkgs, and the channel inputs should stay where they are. Switch afterward. The lock changes only if the override fetches a new input.

## 3. Homebrew

Cask membership is declarative. Cask versions are the revisions in the locked taps, applied by `darwin-rebuild switch`.

Relevant settings:

- `users/apb/darwin.nix` lists taps and casks. A cask is a string (`"firefox"`) or an attrset (`{ name = "protonvpn"; greedy = true; }`). `greedy = true` tells Homebrew to upgrade that cask on activation even when the app updates itself outside brew. `cleanup = "zap"` uninstalls casks dropped from the list, including their leftover files.
- `lib/mksystem.nix` turns on nix-homebrew for Darwin, points `homebrew/homebrew-core` and `homebrew/homebrew-cask` at the flake inputs, and sets `mutableTaps = true`. With mutable taps, a later `brew update` on the machine can move the on-disk tap past the lock. The reproducible step is still to update the flake inputs and switch. `mutableTaps` is marked temporary in that file.

### Add or remove a cask

1. Edit `homebrew.casks` in `users/apb/darwin.nix`.
2. If the name is already in the locked `homebrew-cask` revision, leave the lock alone.
3. If the build or brew reports an unknown cask, update the tap pin:

```bash
nix flake update homebrew-cask
```

Use `homebrew-core` the same way for a formula that lives in core.

4. Darwin switch. Activation installs the new cask or zaps a removed one.
5. Commit `users/apb/darwin.nix` and `flake.lock` when the lock changed.

### Upgrade installed casks

Update the tap pins, then switch. The switch runs `brew upgrade` because `onActivation.upgrade` is set.

```bash
nix flake update homebrew-core homebrew-cask
```

That moves every cask and formula definition those taps provide. This repo does not pin a separate version per cask name.

To pick up a newer nix-homebrew or the Homebrew/brew checkout it vendors (`brew-src` in the lock, currently ref `6.0.1`):

```bash
nix flake update nix-homebrew
```

Commit `flake.lock` and switch on Darwin.

## 4. Update the Nix release

Two different upgrades share this name.

### The `nix` binary

On the Mac, `machines/macbook-pro-m1.nix` sets `nix.enable = false`. nix-darwin does not install or upgrade Nix. Determinate Nix does, which matches the installer in the README. Upgrade Nix with that installer (or Determinate's own upgrade path), then keep using the flake as before. `flake.lock` stays the same. The guest VMs install Nix through NixOS, so a guest's Nix package moves when `nixpkgs` moves and the guest is rebuilt.

### The 26.05 inputs (nixpkgs, nix-darwin, home-manager)

`flake.nix` pins the three release branches together:

- `nixpkgs` → `github:nixos/nixpkgs/nixos-26.05`
- `home-manager` → `github:nix-community/home-manager/release-26.05`
- `darwin` → `github:nix-darwin/nix-darwin/nix-darwin-26.05`

`nixpkgs-unstable` stays on `nixpkgs-unstable` across this bump. Homebrew inputs stay on their own repos. Bump those only when you mean to, in the sections above.

Do this on a branch.

1. In `flake.nix`, point all three release URLs at the same new release (`nixos-YY.MM`, `release-YY.MM`, `nix-darwin-YY.MM`). Leave the `follows` lines in place so home-manager, nix-darwin, and nixos-wsl keep sharing the root nixpkgs.
2. Refresh the lock for those inputs:

```bash
nix flake update nixpkgs home-manager darwin
```

`nix flake update` with no arguments also moves `nixpkgs-unstable`, both Homebrew taps, `nix-homebrew`, and `nixos-wsl`. Use the narrower command when the release bump should leave those pins alone.

3. Build before switching:

```bash
nix build ".#darwinConfigurations.macbook-pro-m1.system" --impure
```

On a VM, `nixos-rebuild switch` is the apply step; `make NIXNAME=... check` runs `nixos-rebuild test` for a non-Darwin host.

4. Switch with the machine command in [Apply the result](#apply-the-result). Fix breakages from renamed packages or module options in the `.nix` files, then switch again.
5. Commit `flake.nix`, `flake.lock`, and any module fixes together.

Leave the state versions alone on a release bump. They record the defaults from the install that created the system, and this tree already keeps them behind the channel on purpose:

- `home.stateVersion = "24.05"` in `users/apb/home-manager/default.nix`
- `system.stateVersion = 5` in `machines/macbook-pro-m1.nix`
- `system.stateVersion = "20.09"` in `machines/vm-shared.nix`
- `system.stateVersion = "23.05"` in `machines/wsl.nix`

Home Manager's own comment in that file says the state version can stay while home-manager itself is updated. Change a state version only when that release's notes tell you to, for the stateful setting they name.

## What to commit

| You did | Commit |
| --- | --- |
| Edited a program or package file, lock unchanged | The `.nix` file |
| `nix flake update <input>` | `flake.lock`, plus any `.nix` file that changed to match |
| Release bump | `flake.nix`, `flake.lock`, and module fixes |
| Nix binary upgrade via Determinate | Nothing in this repo |

## Command reference

```bash
# one input
nix flake update nixpkgs
nix flake update nixpkgs-unstable
nix flake update homebrew-cask
nix flake update homebrew-core
nix flake update nix-homebrew

# current release line: nixpkgs + the inputs whose own checkouts should move with it
nix flake update nixpkgs home-manager darwin

# every input in flake.nix
nix flake update
```

Updating an input rewrites that input's `rev` and `narHash` in `flake.lock`. The next switch builds those revisions.
