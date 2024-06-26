## git hooks shared root

Get the root directory of shared repository in the current repository.

### Synopsis

Returns root directories of shared repository in the current repository by its
namespace name (e.g. `ns:my-namespace`). Exit-code `1` is returned only if any
shared repositories have not been found. The returned directories may not yet
exist and will be empty in that case. Run `git hooks shared update` for them to
exist.

```
git hooks shared root <namespace>...
```

### Options

```
  -h, --help   help for root
```

### SEE ALSO

- [git hooks shared](git_hooks_shared.md) - Manages the shared hook
  repositories.

###### Auto generated by spf13/cobra
