# nixos-wv

To apply the configuration use:

```
nixos-rebuild --flake github:elohmeier/nixos-wv#hetznervm switch
```


For the initial configuration (from stock NixOS) use this command:

```
nix-shell -p nixFlakes -p gitMinimal --run 'nixos-rebuild --flake github:elohmeier/nixos-wv#hetznervm switch'
```
