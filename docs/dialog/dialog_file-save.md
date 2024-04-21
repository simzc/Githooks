## dialog file-save

Shows a file save dialog.

### Synopsis

Shows a file save dialog similar to `zenity`.

# Exit Codes:

- `0` : User pressed `Ok`. The output contains the selected paths separated by
  `--separator`. All paths use forward slashes on any platform.
- `1` : User pressed `Cancel` or closed the dialog.
- `5` : The dialog was closed due to timeout.

```
dialog file-save
```

### Options

```
      --timeout uint               Timeout for the dialog
      --title string               Dialog title.
      --width uint                 Dialog width.
      --height uint                Dialog height.
      --window-icon DialogIcon     Window icon.
                                   One of [`info`, `warning`, `error`, `question`] (only Windows/Unix)
      --root string                Default root path of the file dialog. (default ".")
      --filename string            Default filename in the dialog.
      --file-filter []FileFilter   Sets a filename filter (`<name> | <pattern> <pattern> ...`). (default &[])
      --show-hidden                Show hidden files.
      --directory                  Activate directory-only selection.
      --confirm-overwrite          Confirm if the chosen path already exists.
                                   Cannot be disabled on macOS.
      --confirm-create             Confirm if the chosen path does not exist (only Windows)
  -h, --help                       help for file-save
```

### Options inherited from parent commands

```
      --json   Report the result as a JSON object on stdout.
               Exit code:
               	- `0` for success, and
               	- '> 0' if creating the dialog failed.
```

### SEE ALSO

- [dialog](dialog.md) - Githooks dialog application similar to `zenity`.

###### Auto generated by spf13/cobra