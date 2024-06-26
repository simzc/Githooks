## git hooks ignore remove

Removes pattern or namespace paths from the ignore list.

### Synopsis

Remove patterns or namespace paths from the ignore list.

By default the modifications affect only the user ignore list. To see the path
of the user ignore list, see the output of `git hooks ignore show --user`. To
use the repository's ignore list use `--repository` with optional `--hook-name`.

To see the namespace paths of all hooks in the active repository, see
`<ns-path>` in the output of `git hooks list`.

The glob patterns given by `--patterns <pattern>...` or the namespace paths
given by `--paths <ns-path>...` need to exactly match the entry in the user
ignore list to be successfully removed.

See `git hooks ignore add-pattern --help` for more information about the pattern
syntax and namespace paths.

```
git hooks ignore remove [flags]
```

### Options

```
      --pattern stringArray   Specified glob pattern matching hook namespace paths.
      --path stringArray      Specified path fully matching a hook namespace path.
      --repository            The action affects the repository's main ignore list.
      --hook-name string      The action affects the repository's ignore list
                              in the subfolder `<hook-name>`.
                              (only together with `--repository` flag.)
      --all                   Remove all patterns in the targeted ignore file.
                              (ignoring `--patterns`, `--paths`)
  -h, --help                  help for remove
```

### SEE ALSO

- [git hooks ignore](git_hooks_ignore.md) - Ignores or activates hook in the
  current repository.

###### Auto generated by spf13/cobra
