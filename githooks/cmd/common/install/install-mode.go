package install

import (
	"github.com/gabyx/githooks/githooks/git"
	"github.com/gabyx/githooks/githooks/hooks"
)

type InstallModeType int
type installModeType struct {
	None        InstallModeType
	Manual      InstallModeType
	Centralized InstallModeType
}

// InstallModeTypeV enumerates all types of install modes.
// Manual is the default install mode.
var InstallModeTypeV = &installModeType{None: 0, Manual: 0, Centralized: 1} // nolint: mnd

// GetInstallMode returns the current set install mode of Githooks.
// Return `none`-value if not installed.
func GetInstallMode(gitx *git.Context) (haveInstall bool, mode InstallModeType) {
	installMode := gitx.GetConfig(hooks.GitCKInstallMode, git.GlobalScope)
	haveInstall = true

	switch installMode {
	default:
		haveInstall = false
		mode = InstallModeTypeV.None
	case "manual":
		mode = InstallModeTypeV.Manual
	case "centralized":
		mode = InstallModeTypeV.Centralized
	}

	return
}

// GetInstallModeName returns a string for the install mode.
func getInstallModeName(installMode InstallModeType) string {
	switch installMode {
	case InstallModeTypeV.Manual:
		return "manual"
	case InstallModeTypeV.Centralized:
		return "centralized"
	default:
		return "none"
	}
}

// Name gets the name of the install mode.
func (i *InstallModeType) Name() string {
	return getInstallModeName(*i)
}

// MapInstallerArgsToInstallMode maps installer arguments to install modes.
func MapInstallerArgsToInstallMode(useGlobalCoreHooksPath bool) InstallModeType {
	switch {
	case useGlobalCoreHooksPath:
		return InstallModeTypeV.Centralized
	default:
		return InstallModeTypeV.Manual
	}
}
