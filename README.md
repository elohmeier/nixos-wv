# nixos-wv

To apply the configuration:

1. build the configuration using `nix-shell -p nixFlakes -p gitMinimal --run 'nix build github:elohmeier/nixos-wv#nixosConfigurations.hetznervm.config.system.build.toplevel --extra-experimental-features nix-command --extra-experimental-features flakes'`
2. switch to the configuration using `result/bin/switch-to-configuration switch`

If the build fails with an error indicating `lack of free disk space` increase the tmpfs size using `mount -o remount,size=2G,nr_inodes=0 /run/user/0`.
