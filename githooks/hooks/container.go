package hooks

import (
	"github.com/gabyx/githooks/githooks/container"
	"github.com/gabyx/githooks/githooks/git"
)

// NewContainerManager creates a container manager from Git settings if
// enabled or returns nil.
func NewContainerManager(
	gitx *git.Context,
	containerized bool,
	readMounts []container.ReadBindMount) (containerMgr container.IManager, err error) {
	if containerized ||
		IsContainerizedHooksEnabled(gitx, true) {

		manager := gitx.GetConfig(GitCKContainerManager, git.Traverse)
		containerMgr, err = container.NewManager(manager)
	}

	return
}
