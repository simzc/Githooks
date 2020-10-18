package hooks

import (
	"io/ioutil"
	"path/filepath"
	"regexp"
	cm "rycus86/githooks/common"
	"rycus86/githooks/git"
	strs "rycus86/githooks/strings"
	"strings"
)

// SharedHook is the data for a shared hook
type SharedHook struct {
	OriginalURL string

	IsCloned bool
	URL      string
	Branch   string

	IsLocal bool

	RootDir string
}

// GetRepoSharedFile gets the shared file with respect to the hooks dir in the repository.
func GetRepoSharedFile(repoHooksDir string) string {
	return filepath.Join(repoHooksDir, ".shared")
}

// SharedConfigName defines the config name used to define local/global
// shared hooks in the local/global Git configuration.
var SharedConfigName string = "githooks.shared"

func getSharedCloneDir(installDir string, entry string) string {
	sha1 := cm.GetSHA1HashString(entry)
	if len(entry) >= 48 {
		return filepath.Join(installDir, "shared", sha1+entry[0:48])
	}
	return filepath.Join(installDir, "shared", sha1+entry)
}

var reURLScheme *regexp.Regexp

func getReURLScheme() *regexp.Regexp {
	if reURLScheme == nil {
		reURLScheme = regexp.MustCompile(`(?m)^[^:/?#]+://`)
	}
	return reURLScheme
}

var reShortSCPSyntax *regexp.Regexp

func getReShortSCPSyntax() *regexp.Regexp {
	if reShortSCPSyntax == nil {
		reShortSCPSyntax = regexp.MustCompile(`(?m)^.+@.+:.+`)
	}
	return reShortSCPSyntax
}

var reFileURLScheme *regexp.Regexp

func getReFileURLScheme() *regexp.Regexp {
	if reFileURLScheme == nil {
		reFileURLScheme = regexp.MustCompile(`(?m)^file://`)
	}
	return reFileURLScheme
}

func isSharedEntryALocalPath(url string) bool {
	return !(getReURLScheme().MatchString(url) || getReShortSCPSyntax().MatchString(url))
}

func isSharedEntryALocalURL(url string) bool {
	return getReFileURLScheme().MatchString(url)
}

func parseSharedEntry(installDir string, entry string) (SharedHook, error) {

	h := SharedHook{IsCloned: true, IsLocal: false, OriginalURL: entry}
	doSplit := true

	if isSharedEntryALocalPath(entry) {

		h.IsLocal = true

		if git.IsBareRepo(entry) {
			doSplit = false
		} else {
			// We have a local path to a non-bare repo
			h.IsCloned = false
			h.RootDir = entry
		}

	} else if isSharedEntryALocalURL(entry) {
		h.IsLocal = true
	}

	if h.IsCloned {
		// Here we now have a supported Git URL or
		// a local bare-repo `<localpath>`

		// Split "...@(.*)"
		if doSplit && strings.ContainsAny(entry, "@") {
			lastIdx := strings.LastIndexAny(entry, "@")
			if lastIdx > 0 {
				h.URL = entry[:lastIdx]
				h.Branch = entry[lastIdx:]
			}
		} else {
			h.URL = entry
		}

		// Define the shared clone folder
		h.RootDir = getSharedCloneDir(installDir, entry)
	}

	return h, nil
}

func parseData(installDir string, data string) (hooks []SharedHook, err error) {
	for _, line := range strs.SplitLines(data) {
		line = strings.TrimSpace(line)
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		hook, e := parseSharedEntry(installDir, line)
		err = cm.CombineErrors(err, e)

		if e == nil {
			hooks = append(hooks, hook)
		}
	}
	return
}

// LoadRepoSharedHooks gets all shared hooks that reside inside `${repoHooksDir}/.shared`
// No checks are made to the filesystem if paths are existing in `SharedHook`.
func LoadRepoSharedHooks(installDir string, repoHooksDir string) (hooks []SharedHook, err error) {
	file := GetRepoSharedFile(repoHooksDir)
	exists, err := cm.IsPathExisting(file)

	if exists {
		data, e := ioutil.ReadFile(file)
		err = cm.CombineErrors(err, e)
		hooks, e = parseData(installDir, string(data))
		err = cm.CombineErrors(err, e)
	}

	return
}

// LoadConfigSharedHooks gets all shared hooks that are specified in
// the local/global Git configuration.
// No checks are made to the filesystem if paths are existing in `SharedHook`.
func LoadConfigSharedHooks(installDir string, ctx *git.Context, scope git.ConfigScope) (hooks []SharedHook, err error) {
	data := ctx.GetConfigAllU(SharedConfigName, scope)
	if data != "" {
		hooks, err = parseData(installDir, data)
	}
	return
}
