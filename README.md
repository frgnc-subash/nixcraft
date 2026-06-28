# nixcraft

My personal NixOS + home-manager flake configuration.

## Usage

```bash
git add -A
sudo nixos-rebuild switch --flake ~/nixcraft
```

Stage new files before rebuilding — flakes only see what Git tracks.
