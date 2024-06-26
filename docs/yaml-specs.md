# YAML Specification

## Ignore File `.ignore.yaml`

### Version 1

```yaml
patterns:
  - "my-super-shared-hooks/**/.sh"
  - "!my-super-shared-hooks/pre-commit/*.sh"
  - "**/*.md"
  - "pre/-commit/*.py"

paths:
  - "commit-msg/*check*"
  - "hooks/pre-commit.replaced.githook"

version: 1
```

## Shared Hooks Configuration `.shared.yaml`

### Version 1

```yaml
urls:
  - "ssh://github.com/shared/hooks-go.git@mybranch"
  - "git@github.com:shared/hooks-maven.git"
  - "git://github.com/shared/hooks-python.git"
  - "file:///local/path/to/bare-repo.git@mybranch"

version: 1
```

## Environment Variables Configuration `.env.yaml`

### Version 1

```yaml
envs:
  mystuff:
    # All these variables are exported
    # for shared hook namespace `mystuff`.
    - "MYSTUFF_CHECK_DEAD_CODE=1"
    - "MYSTUFF_STAGE_ON_FORMAT=1"

  sharedA:
    # All these variables are exported
    # for shared hook namespace `sharedA`.
    - "SHAREDA_ABC=1"
    - "SHAREDA_TWEET=1"
```

## Hook Run Configuration `<hookName>.yaml`

Variable `hookName` refers to one of the supported [Git hooks](/README.md).

### Version 1

```yaml
cmd: "/var/etc/lib/crazy/command"
args: # optional
  - "--do-it"
  - "--faster"
  - "--all"
  - "${env:GPG_PUBLIC_KEY}"
  - "--test ${git-l:my-local-git-config-var}"
version: 1 # optional
```

### Version 2

- Added environment variables `env`.

```yaml
cmd: "/var/etc/lib/crazy/command"
args: # optional
  - "--do-it"
  - "${env:GPG_PUBLIC_KEY}"
  - "--test ${git-l:my-local-git-config-var}"
env: # optional
  - USE_CUSTOM=1
version: 2 # optional
```

### Version 3

- Added image field `image`.

```yaml
cmd: "/var/etc/lib/crazy/command"
args: # optional
  - "--do-it"
  - "${env:GPG_PUBLIC_KEY}"
  - "--test ${git-l:my-local-git-config-var}"
env: # optional
  - USE_CUSTOM=1
image: # optional
  reference: mycontainerimage:1.2.0
version: 3 # optional
```

## Container Run Configuration

The file can be set for the Githooks runner or `git hooks exec` invocation with
the env. variable `GITHOOKS_CONTAINER_RUN_CONFIG_FILE` which is the path to a
YAML file which modifies the mounts:

### Version 1

```yaml
version: 1

# Tell Githooks where the workspace will be in the nested container.
# (optional, default `/mnt/workspace`)
workspace-path-dest: /tmp/ci-job-1/build/repo
# Tell Githooks where the shared repository checkouts are in the nested container.
# (optional, default: `/mnt/shared`)
shared-path-dest: /tmp/ci-job-1/githooks-install/.githooks/shared

# Do not auto-mount the workspace (bind mount), do it yourself with args.
# (optional, default: true)
auto-mount-workspace: false
# Do not auto-mount the shared (bind mount), do it yourself with args.
# (optional, default: true)
auto-mount-shared: false

# Additional arguments to `docker run` or `podman run`.
args: ["-v", "gh-test-tmp:/tmp"]
```
