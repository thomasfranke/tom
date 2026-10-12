####################################################################
### *** Makefile for TOM ***                                     ###
### A thin face over `cli`, the CLI in tool/. Run `make help`.   ###
### Every target is one line through the CLI; the logic lives    ###
### there, so it also works where `make` does not (Windows).     ###
####################################################################

SRC  := src
APP  := $(SRC)/apps/desktop

# The pure Dart layers, in dependency order. Each may depend only on the ones
# before it; src/test/integrity/architecture_test.dart enforces that.
PKGS := core domain application infra data presentation
APPS := desktop mobile

# The CLI every target below delegates to. Nothing in tool/ calls back into
# `make` — that direction is the whole point.
CLI := dart run tool/cli.dart

# Coverage rides along with every test run by default. COVERAGE=0 skips the
# instrumentation when iterating on one failing test.
COVERAGE ?= 1

# Desktop device for `make run` and `make build`.
DEVICE ?= macos

# Make would read `make cli test` as two goals, so the subcommand travels in
# a variable: make cli ARGS="test core domain"
ARGS ?=

.DEFAULT_GOAL := help
.PHONY: help cli setup clean doctor updates format analyze verify flutter-test \
        flutter-test-arch \
        flutter-test-packages flutter-test-app flutter-test-diff \
        flutter-test-last flutter-test-cli \
        coverage coverage-last coverage-diff coverage-gate runner runner-hard runner-watch fvm run \
        build build-linux build-macos build-windows release

##############################
### *** Help *** ###
##############################

help: ## List all targets
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-24s\033[0m %s\n", $$1, $$2}'

cli: ## Open the navigable CLI (ARGS="test core" to run a command directly)
	@dart run tool/cli.dart $(ARGS)

##############################
### *** Environment *** ###
##############################

setup: ## Resolve the whole workspace (one get for every package)
	@$(CLI) setup

clean: ## Clean build artifacts and re-resolve (PKG=<name> for one package)
	@$(CLI) clean $(PKG)

fvm: ## Pin the Flutter version declared in src/.fvmrc for this workspace
	@$(CLI) fvm

doctor: ## Check this machine has what the repository needs to build
	@$(CLI) doctor

# Reports only. Moving the pin moves it for CI too, so it stays a decision —
# runUpdates in tool/src/commands/updates.dart.
updates: ## Compare the pinned Flutter and Dart against the latest stable
	@$(CLI) updates

##############################
### *** Quality *** ###
##############################

format: ## Format Dart code, failing if anything changes
	@$(CLI) format

analyze: ## Static analysis across every package at once
	@$(CLI) analyze

# Not a list of prerequisites: the order, and stopping at the first failure,
# are the command's own business — runVerify in tool/src/commands/quality.dart.
verify: ## Everything CI runs, in one command
	@$(CLI) verify

##############################
### *** Tests *** ###
##############################

# Without PKG or KIND, everything runs: the architecture assertions, then the
# packages in dependency order, then the apps. PKG="domain data" also works.
flutter-test: ## Run every test, live (PKG=<name> restricts, KIND=unit|integration|e2e narrows)
	@$(CLI) test $(KIND) $(PKG)

flutter-test-arch: ## Assert the layer graph matches what the pubspecs declare
	@$(CLI) test arch

# The CLI's tests live on the workspace side because tool/ has no pubspec —
# src/test/cli/cli_test.dart says why.
flutter-test-cli: ## Test the CLI itself
	@$(CLI) test cli

# Also the framework-independence proof: no Flutter binding is available here,
# so a layer that quietly grew a Flutter dependency fails rather than ships.
flutter-test-packages: ## Pure Dart tests, package by package
	@$(CLI) test $(PKGS)

flutter-test-app: ## Flutter tests for the apps (desktop, mobile)
	@$(CLI) test $(APPS)

# Maps changed files to test files by name alone — a changed lib/foo.dart runs
# foo_test.dart. BASE=HEAD narrows it to uncommitted work.
flutter-test-diff: ## Test only what this branch's diff maps to (BASE=main)
	@$(CLI) test diff $(if $(BASE),--base=$(BASE))

# Same mapping, different question: what the filesystem says you touched last,
# not what git says differs from a commit.
flutter-test-last: ## Test what the 10 most recently edited files map to (N=<count>)
	@$(CLI) test last $(if $(N),--count=$(N))

coverage: ## Coverage report, opened in the browser (PKG=<name> for one package)
	@$(CLI) coverage $(PKG)

# The point is the suite that does not run: the test the file you just edited
# maps to, and the coverage of that file. Printed here, not rendered — the
# answer is three lines long.
coverage-last: ## Coverage of the file edited most recently, in the terminal (N=<count>)
	@$(CLI) coverage last $(if $(N),--count=$(N))

coverage-diff: ## Coverage of what this branch changed, in the terminal (BASE=main)
	@$(CLI) coverage diff $(if $(BASE),--base=$(BASE))

# A package with no lib/src yet, or with code but no unit tests yet, is skipped
# rather than counted against: the gate is about tests falling behind code.
# Unit tests alone are counted unless KIND=all, which reports the whole test/.
coverage-gate: ## Fail if any package is under the unit-test coverage bar (THRESHOLD=90, KIND=unit|all)
	@$(CLI) coverage-gate $(if $(THRESHOLD),--threshold=$(THRESHOLD)) $(if $(KIND),--kind=$(KIND))

##############################
### *** Codegen *** ###
##############################

# Only packages this branch changed actually run; the rest are reported as
# skipped, with the reason. PKG=<name> narrows it further.
runner: ## Run build_runner on packages changed in this branch (BASE=main)
	@$(CLI) codegen normal $(PKG)

runner-hard: ## Delete generated files, then regenerate every package from scratch
	@$(CLI) codegen hard $(PKG)

runner-watch: ## Regenerate continuously while you work
	cd $(APP) && dart run build_runner watch --delete-conflicting-outputs

# `codegen-gate` is a pipeline concern, so CI calls `cli codegen-gate`
# directly. Locally it arrives as one of the steps of `make verify`.

##############################
### *** Run *** ###
##############################

run: ## Run the app (override with DEVICE=windows|linux|macos)
	@$(CLI) run $(DEVICE)

# `run-flags` and `flags` were removed: nothing declares a build-time flag yet.
# Bring them back with the first one — CONTRIBUTING.md, "Feature flags".

##############################
### *** Build *** ###
##############################

# The community build: proof the public repo compiles on its own. The
# distributed artifact is built elsewhere — docs/technical/process/repository-settings/README.md.

build: ## Compile check for the current platform (artifact is not distributed)
	@$(CLI) build $(DEVICE)

build-linux: ## Compile check for Linux
	@$(CLI) build linux

build-macos: ## Compile check for macOS
	@$(CLI) build macos

build-windows: ## Compile check for Windows
	@$(CLI) build windows

##############################
### *** Release *** ###
##############################

release: ## Bump the version (BUMP=major|minor|patch), write the changelog, commit and tag locally
	@$(CLI) release $(BUMP)
