####################################################################
### *** Makefile for TOM ***                                     ###
### A thin face over `tom`, the CLI in tool/. Run `make help`.   ###
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
TOM := dart run tool/tom.dart

# Coverage rides along with every test run by default. COVERAGE=0 skips the
# instrumentation when iterating on one failing test.
COVERAGE ?= 1

# Desktop device for `make run` and `make build`.
DEVICE ?= macos

# Make would read `make tom test` as two goals, so the subcommand travels in
# a variable: make tom ARGS="test core domain"
ARGS ?=

.DEFAULT_GOAL := help
.PHONY: help tom setup clean doctor updates format analyze verify flutter-test \
        flutter-test-arch \
        flutter-test-packages flutter-test-app flutter-test-diff \
        flutter-test-last flutter-test-cli \
        coverage coverage-last coverage-diff coverage-gate runner runner-hard runner-watch fvm run \
        build build-linux build-macos build-windows

##############################
### *** Help *** ###
##############################

help: ## List all targets
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-24s\033[0m %s\n", $$1, $$2}'

tom: ## Open the navigable CLI (ARGS="test core" to run a command directly)
	@dart run tool/tom.dart $(ARGS)

##############################
### *** Environment *** ###
##############################

setup: ## Resolve the whole workspace (one get for every package)
	@$(TOM) setup

clean: ## Clean build artifacts and re-resolve (PKG=<name> for one package)
	@$(TOM) clean $(PKG)

fvm: ## Pin the Flutter version declared in src/.fvmrc for this workspace
	@$(TOM) fvm

doctor: ## Check this machine has what the repository needs to build
	@$(TOM) doctor

# Reports only. Moving the pin moves it for CI too, so it stays a decision —
# runUpdates in tool/src/commands/updates.dart.
updates: ## Compare the pinned Flutter and Dart against the latest stable
	@$(TOM) updates

##############################
### *** Quality *** ###
##############################

format: ## Format Dart code, failing if anything changes
	@$(TOM) format

analyze: ## Static analysis across every package at once
	@$(TOM) analyze

# Not a list of prerequisites: the order, and stopping at the first failure,
# are the command's own business — runVerify in tool/src/commands/quality.dart.
verify: ## Everything CI runs, in one command
	@$(TOM) verify

##############################
### *** Tests *** ###
##############################

# Without PKG or KIND, everything runs: the architecture assertions, then the
# packages in dependency order, then the apps. PKG="domain data" also works.
flutter-test: ## Run every test, live (PKG=<name> restricts, KIND=unit|integration|e2e narrows)
	@$(TOM) test $(KIND) $(PKG)

flutter-test-arch: ## Assert the layer graph matches what the pubspecs declare
	@$(TOM) test arch

# The CLI's tests live on the workspace side because tool/ has no pubspec —
# src/test/cli/cli_test.dart says why.
flutter-test-cli: ## Test the tom CLI itself
	@$(TOM) test cli

# Also the framework-independence proof: no Flutter binding is available here,
# so a layer that quietly grew a Flutter dependency fails rather than ships.
flutter-test-packages: ## Pure Dart tests, package by package
	@$(TOM) test $(PKGS)

flutter-test-app: ## Flutter tests for the apps (desktop, mobile)
	@$(TOM) test $(APPS)

# Maps changed files to test files by name alone — a changed lib/foo.dart runs
# foo_test.dart. BASE=HEAD narrows it to uncommitted work.
flutter-test-diff: ## Test only what this branch's diff maps to (BASE=main)
	@$(TOM) test diff $(if $(BASE),--base=$(BASE))

# Same mapping, different question: what the filesystem says you touched last,
# not what git says differs from a commit.
flutter-test-last: ## Test what the 10 most recently edited files map to (N=<count>)
	@$(TOM) test last $(if $(N),--count=$(N))

coverage: ## Coverage report, opened in the browser (PKG=<name> for one package)
	@$(TOM) coverage $(PKG)

# The point is the suite that does not run: the test the file you just edited
# maps to, and the coverage of that file. Printed here, not rendered — the
# answer is three lines long.
coverage-last: ## Coverage of the file edited most recently, in the terminal (N=<count>)
	@$(TOM) coverage last $(if $(N),--count=$(N))

coverage-diff: ## Coverage of what this branch changed, in the terminal (BASE=main)
	@$(TOM) coverage diff $(if $(BASE),--base=$(BASE))

# A package with no lib/src yet, or with code but no tests yet, is skipped
# rather than counted against: the gate is about tests falling behind code.
coverage-gate: ## Fail if any implemented package is under the coverage threshold (THRESHOLD=95)
	@$(TOM) coverage-gate $(if $(THRESHOLD),--threshold=$(THRESHOLD))

##############################
### *** Codegen *** ###
##############################

# Only packages this branch changed actually run; the rest are reported as
# skipped, with the reason. PKG=<name> narrows it further.
runner: ## Run build_runner on packages changed in this branch (BASE=main)
	@$(TOM) codegen normal $(PKG)

runner-hard: ## Delete generated files, then regenerate every package from scratch
	@$(TOM) codegen hard $(PKG)

runner-watch: ## Regenerate continuously while you work
	cd $(APP) && dart run build_runner watch --delete-conflicting-outputs

# `codegen-gate` is a pipeline concern, so CI calls `tom codegen-gate`
# directly. Locally it arrives as one of the steps of `make verify`.

##############################
### *** Run *** ###
##############################

run: ## Run the app (override with DEVICE=windows|linux|macos)
	@$(TOM) run $(DEVICE)

# `run-flags` and `flags` were removed: nothing declares a build-time flag yet.
# Bring them back with the first one — CONTRIBUTING.md, "Feature flags".

##############################
### *** Build *** ###
##############################

# The community build: proof the public repo compiles on its own. The
# distributed artifact is built elsewhere — docs/technical/process/repository-settings.md.

build: ## Compile check for the current platform (artifact is not distributed)
	@$(TOM) build $(DEVICE)

build-linux: ## Compile check for Linux
	@$(TOM) build linux

build-macos: ## Compile check for macOS
	@$(TOM) build macos

build-windows: ## Compile check for Windows
	@$(TOM) build windows
