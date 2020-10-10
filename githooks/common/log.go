package common

import (
	"log"
	"os"
	"runtime/debug"
	strs "rycus86/githooks/strings"
	"strings"

	"github.com/gookit/color"
	"github.com/mattn/go-isatty"
)

const (
	githooksSuffix = "Githooks:"
	debugSuffix    = "🛠  " + githooksSuffix + " "
	debugIndent    = "   "
	infoSuffix     = "ℹℹ " + githooksSuffix + " "
	infoIndent     = "   "
	warnSuffix     = "⚠  " + githooksSuffix + " "
	warnIndent     = "   "
	errorSuffix    = warnSuffix + " "
	errorIndent    = "   "

	promptSuffix = "❓ " + githooksSuffix + " "
	promptIndent = "   "
)

// ILogContext defines the log interace
type ILogContext interface {
	// Log functions
	LogDebug(lines ...string)
	LogDebugF(format string, args ...interface{})
	LogInfo(lines ...string)
	LogInfoF(format string, args ...interface{})
	LogWarn(lines ...string)
	LogWarnF(format string, args ...interface{})
	LogError(lines ...string)
	LogErrorF(format string, args ...interface{})
	LogErrorWithStacktrace(lines ...string)
	LogErrorWithStacktraceF(format string, args ...interface{})
	LogFatal(lines ...string)
	LogFatalF(format string, args ...interface{})

	LogPromptStartF(format string, args ...interface{})
	LogPromptEnd()

	// Assert helper functions
	AssertWarn(condition bool, lines ...string)
	AssertWarnF(condition bool, format string, args ...interface{})
	WarnIf(condition bool, lines ...string)
	WarnIfF(condition bool, format string, args ...interface{})
	FatalIf(condition bool, lines ...string)
	FatalIfF(condition bool, format string, args ...interface{})
	AssertNoErrorWarn(err error, lines ...string) bool
	AssertNoErrorWarnF(err error, format string, args ...interface{}) bool
	AssertNoErrorFatal(err error, lines ...string)
	AssertNoErrorFatalF(err error, format string, args ...interface{})
}

// LogContext defines the data for a log context
type LogContext struct {
	debug *log.Logger
	info  *log.Logger
	warn  *log.Logger
	error *log.Logger

	isColorSupported bool

	renderInfo   func(string) string
	renderError  func(string) string
	renderPrompt func(string) string
}

// CreateLogContext creates a log context
func CreateLogContext() (ILogContext, error) {
	var debug *log.Logger
	if DebugLog {
		debug = log.New(os.Stderr, "", 0)
	}

	info := log.New(os.Stdout, "", 0)
	warn := log.New(os.Stderr, "", 0)
	error := log.New(os.Stderr, "", 0)

	if info == nil || warn == nil || error == nil {
		return nil, Error("Failed to initialized info,warn,error logs")
	}

	hasColors := isatty.IsTerminal(os.Stdout.Fd()) && color.IsSupportColor()

	var renderInfo func(string) string
	var renderError func(string) string
	var renderPrompt func(string) string

	if hasColors {
		renderInfo = func(s string) string { return color.FgLightBlue.Render(s) }
		renderError = func(s string) string { return color.FgRed.Render(s) }
		renderPrompt = func(s string) string { return color.FgGreen.Render(s) }

	} else {
		renderInfo = func(s string) string { return s }
		renderError = func(s string) string { return s }
		renderPrompt = func(s string) string { return s }
	}

	return &LogContext{debug, info, warn, error, hasColors, renderInfo, renderError, renderPrompt}, nil
}

// LogDebug logs a debug message.
func (c *LogContext) LogDebug(lines ...string) {
	if DebugLog {
		c.debug.Printf(c.renderInfo(FormatMessage(debugSuffix, debugIndent, lines...)))
	}
}

// LogDebugF logs a debug message.
func (c *LogContext) LogDebugF(format string, args ...interface{}) {
	if DebugLog {
		c.debug.Printf(c.renderInfo(FormatMessageF(debugSuffix, debugIndent, format, args...)))
	}
}

// LogInfo logs a info message.
func (c *LogContext) LogInfo(lines ...string) {
	c.info.Printf(c.renderInfo(FormatMessage(infoSuffix, infoIndent, lines...)))
}

// LogInfoF logs a info message.
func (c *LogContext) LogInfoF(format string, args ...interface{}) {
	c.info.Printf(c.renderInfo(FormatMessageF(infoSuffix, infoIndent, format, args...)))
}

// LogWarn logs a warning message.
func (c *LogContext) LogWarn(lines ...string) {
	c.warn.Printf(c.renderError(FormatMessage(warnSuffix, warnIndent, lines...)))
}

// LogWarnF logs a warning message.
func (c *LogContext) LogWarnF(format string, args ...interface{}) {
	c.warn.Printf(c.renderError(FormatMessageF(warnSuffix, warnIndent, format, args...)))
}

// LogError logs an error.
func (c *LogContext) LogError(lines ...string) {
	c.error.Printf(c.renderError(FormatMessage(errorSuffix, errorIndent, lines...)))
}

// LogErrorF logs an error.
func (c *LogContext) LogErrorF(format string, args ...interface{}) {
	c.error.Printf(c.renderError(FormatMessageF(errorSuffix, errorIndent, format, args...)))
}

// LogPromptStartF outputs a prompt to `stdin`.
func (c *LogContext) LogPromptStartF(format string, args ...interface{}) {
	c.info.Printf(c.renderPrompt(FormatMessageF(promptSuffix, promptIndent, format, args...)))
}

// LogPromptEnd outputs the end statement after prompt input to `stdin`.
func (c *LogContext) LogPromptEnd() {
	c.info.Printf("\n")
}

// LogErrorWithStacktrace logs and error with the stack trace.
func (c *LogContext) LogErrorWithStacktrace(lines ...string) {
	stackLines := strs.SplitLines(string(debug.Stack()))
	l := append(lines, "", "Stacktrace:", "-----------")
	c.LogError(append(l, stackLines...)...)
}

// LogErrorWithStacktraceF logs and error with the stack trace.
func (c *LogContext) LogErrorWithStacktraceF(format string, args ...interface{}) {
	c.LogErrorWithStacktrace(strs.Fmt(format, args...))
}

// LogFatal logs an error and calls panic with a GithooksFailure.
func (c *LogContext) LogFatal(lines ...string) {
	m := FormatMessage(errorSuffix, errorIndent, lines...)
	c.error.Printf(c.renderError(m))
	panic(GithooksFailure{m})
}

// LogFatalF logs an error and calls panic with a GithooksFailure.
func (c *LogContext) LogFatalF(format string, args ...interface{}) {
	m := FormatMessageF(errorSuffix, errorIndent, format, args...)
	c.error.Printf(c.renderError(m))
	panic(GithooksFailure{m})
}

// FormatMessage formats  several lines with a suffix and indent.
func FormatMessage(suffix string, indent string, lines ...string) string {
	return suffix + strings.Join(lines, "\n"+indent)
}

// FormatMessageF formats  several lines with a suffix and indent.
func FormatMessageF(suffix string, indent string, format string, args ...interface{}) string {
	s := suffix + strs.Fmt(format, args...)
	return strings.ReplaceAll(s, "\n", "\n"+indent)
}
