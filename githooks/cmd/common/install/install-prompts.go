package install

import (
	"strings"
	"time"

	cm "github.com/gabyx/githooks/githooks/common"
	"github.com/gabyx/githooks/githooks/git"
	"github.com/gabyx/githooks/githooks/hooks"
	"github.com/gabyx/githooks/githooks/prompt"
	strs "github.com/gabyx/githooks/githooks/strings"

	"github.com/mitchellh/go-homedir"
)

var existingInfo = []string{
	"Installing Githooks into existing repositories under:\n'%s'.",
	"Uninstalling Githooks from existing repositories under:\n'%s'."}

var existingPrompt = []string{
	"Do you want to install Githooks into\nexisting repositories?",
	"Do you want to uninstall Githooks from\nexisting repositories?"}

var existingWarn = []string{
	"Existing repositories won't get Githooks run-wrappers.",
	"Existing repositories won't have Githooks uninstalled.",
}

// PromptExistingRepos shows user prompts about installing/uninstalling
// into existing repositories.
func PromptExistingRepos(
	log cm.ILogContext,
	gitx *git.Context,
	nonInteractive bool,
	dryRun bool,
	uninstall bool,
	promptx prompt.IContext,
	callback func(string)) {

	// Message index.
	idx := 0
	if uninstall {
		idx = 1
	}

	homeDir, err := homedir.Dir()
	cm.AssertNoErrorPanic(err, "Could not get home directory.")

	searchDir := gitx.GetConfig(hooks.GitCKPreviousSearchDir, git.GlobalScope)
	hasSearchDir := strs.IsNotEmpty(searchDir)

	if nonInteractive {
		if hasSearchDir {
			log.InfoF(existingInfo[idx], searchDir)
		} else {
			// Non-interactive set and no pre start dir set -> abort
			return
		}
	} else {

		var questionPrompt []string
		if hasSearchDir {
			questionPrompt = []string{"(Yes/no)", "Y/n"}
		} else {
			searchDir = homeDir
			questionPrompt = []string{"(yes/No)", "y/N"}
		}

		answer, err := promptx.ShowOptions(
			existingPrompt[idx],
			questionPrompt[0],
			questionPrompt[1],
			"Yes", "No")
		log.AssertNoError(err, "Could not show prompt.")

		if answer == "n" {
			return
		}

		searchDir, err = promptx.ShowEntry(
			"Where do you want to start the search?",
			searchDir,
			prompt.CreateValidatorIsDirectory(homeDir))
		log.AssertNoError(err, "Could not show prompt.")
	}

	searchDir = cm.ReplaceTildeWith(searchDir, homeDir)

	if !cm.IsDirectory(searchDir) {
		log.WarnF("Search directory\n'%s'\nis not a directory.\n" + existingWarn[idx])

		return
	}

	if !dryRun {
		err = gitx.SetConfig(hooks.GitCKPreviousSearchDir, searchDir, git.GlobalScope)
		log.AssertNoError(err, "Could not set git config 'githooks.previousSearchDir'")
	}

	log.InfoF("Searching for Git directories in '%s'...", searchDir)

	settings := cm.CreateDefaultProgressSettings(
		"Searching ...", "Still searching ...")
	taskIn := GitDirsSearchTask{Dir: searchDir}

	resultTask, err := cm.RunTaskWithProgress(&taskIn, log, 300*time.Second, settings) //nolint: mnd
	if err != nil {
		log.AssertNoErrorF(err, "Could not find Git directories in '%s'.", searchDir)
		return //nolint: nlreturn
	}

	taskOut := resultTask.(*GitDirsSearchTask)
	cm.DebugAssert(taskOut != nil, "Wrong output.")

	if len(taskOut.Matches) == 0 { //nolint: staticcheck
		log.InfoF("No Git directories found in '%s'.", searchDir)
		return //nolint: nlreturn
	}

	for _, gitDir := range taskOut.Matches {
		callback(gitDir)
	}
}

var registeredPrompt = []string{
	"Do you want to install Githooks\nin all of them?",
	"Do you want to uninstall Githooks\nin all of them?",
}

// PromptRegisteredRepos shows user prompts about installing/uninstalling
// into registered repositories.
func PromptRegisteredRepos(
	log cm.ILogContext,
	dirs []string,
	nonInteractive bool,
	uninstall bool,
	promptx prompt.IContext,
	callback func(string)) {

	// Message index.
	idx := 0
	if uninstall {
		idx = 1
	}

	if !nonInteractive && len(dirs) != 0 {

		answer, err := promptx.ShowOptions(
			"The following remaining registered repositories\n"+
				"contain Githooks installation:\n"+
				strings.Join(
					strs.Map(dirs,
						func(s string) string {
							return strs.Fmt(" • '%s'", s)
						}), "\n")+
				"\n"+registeredPrompt[idx],
			"(Yes, no)", "Y/n", "Yes", "No")
		log.AssertNoError(err, "Could not show prompt.")

		if answer == "n" {
			return
		}
	}

	for _, gitDir := range dirs {
		callback(gitDir)
	}
}
