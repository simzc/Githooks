## git hooks config container-manager-types

Set container manger types to use (see `enable-containerized-hooks`).

### Synopsis

Set container manager types to use where the first valid one is taken and used.
If unset `docker` is used.

```
git hooks config container-manager-types [flags]
```

### Options

```
      --print    Print the setting.
      --set      Set the setting.
      --reset    Reset the setting.
      --local    Use the local Git configuration (default).
      --global   Use the global Git configuration.
  -h, --help     help for container-manager-types
```

### SEE ALSO

- [git hooks config](git_hooks_config.md) - Manages various Githooks
  configuration.

###### Auto generated by spf13/cobra
