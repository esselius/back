# Bäck

## Run process-compose

```shell
nix run .#notebook
```

## Watch for changes and update process-compose

```shell
watchexec -e nix -- nix run .#notebook -- project update
```
