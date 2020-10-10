package common

import (
	"os"
)

// IsPathError returns `true` if the error is a `os.PathError`
func IsPathError(err error) bool {
	return err != nil && err.(*os.PathError) != nil
}

// PathExists checks if a path exists.
func PathExists(path string) (bool, error) {
	_, err := os.Stat(path)
	if os.IsNotExist(err) || IsPathError(err) {
		return false, nil
	}
	return err == nil, err
}

// IsDirectory checks if a path is a existing directory.
func IsDirectory(path string) bool {
	s, err := os.Stat(path)
	return err == nil && s.IsDir()
}

// IsFile checks if a path is a existing file.
func IsFile(path string) bool {
	s, err := os.Stat(path)
	return err == nil && !s.IsDir()
}

// IsExecOwner tells if the file is executbale by Unix 'owner'.
func IsExecOwner(path string) (bool, error) {
	var info os.FileInfo
	var err error
	if info, err = os.Stat(path); err != nil {
		return false, err
	}
	return info.Mode()&0100 != 0, nil
}

// IsExecGroup tells if the file is executbale by Unix 'group'.
func IsExecGroup(path string) (bool, error) {
	var info os.FileInfo
	var err error
	if info, err = os.Stat(path); err != nil {
		return false, err
	}
	return info.Mode()&0010 != 0, nil
}

// IsExecOther tells if the file is executbale by Unix 'other'.
func IsExecOther(path string) (bool, error) {
	var info os.FileInfo
	var err error
	if info, err = os.Stat(path); err != nil {
		return false, err
	}
	return info.Mode()&0001 != 0, nil
}

// IsExecAny tells if the file executable by either the owner, group or by 'other'.
func IsExecAny(path string) (bool, error) {
	var info os.FileInfo
	var err error
	if info, err = os.Stat(path); err != nil {
		return false, err
	}
	return info.Mode()&0111 != 0, nil
}
