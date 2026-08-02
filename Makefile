####################################################################
###  *** Makefile for TOM ***                                    ###
### Run `make help` to list every target with a description.     ###
### Targets are the single source of truth: CI calls them too,   ###
### so a local run and a pipeline run cannot drift apart.        ###
####################################################################

CORE := packages/tom_core
APP  := apps/tom_desktop

# Project Flutter version. Single source of truth: `.fvmrc` (also read by FVM,
# by the GitHub Actions workflows and by VS Code). To switch versions, edit
# `.fvmrc` only.
FLUTTER_VERSION := $(shell sed -n 's/.*"flutter"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' .fvmrc 2>/dev/null)

# Desktop device for `make run`. Override: make run DEVICE=windows
DEVICE ?= macos

.DEFAULT_GOAL := help
.PHONY: help setup clean format analyze test test-core test-app test-changed \
        test-changed-html test-last coverage runner runner-hard runner-last \
        runner-watch fvm run run-flags flags build build-linux build-macos \
        build-windows verify

##############################
### *** Help *** ###
##############################

help: ## List all targets
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-24s\033[0m %s\n", $$1, $$2}'

##############################
### *** Environment *** ###
##############################

setup: ## Resolve the whole workspace (one get at the root)
	dart pub get

clean: ## Clean build artifacts and re-resolve
	cd $(APP) && flutter clean
	dart pub get

fvm: ## Configure the Flutter version declared in .fvmrc
	@test -n "$(FLUTTER_VERSION)" || { echo "Could not read the Flutter version from .fvmrc"; exit 1; }
	dart pub global activate fvm
	fvm use $(FLUTTER_VERSION)
	fvm global $(FLUTTER_VERSION)
	dart pub global deactivate fvm
	dart pub global activate fvm

##############################
### *** Quality *** ###
##############################

format: ## Format Dart code, failing if anything changes
	dart format --set-exit-if-changed .

analyze: ## Static analysis on both packages
	cd $(CORE) && dart analyze
	cd $(APP) && flutter analyze

verify: format analyze test ## Everything CI runs, in one command

##############################
### *** Tests *** ###
##############################

test: test-core test-app ## Run every test in the workspace

test-core: ## Pure Dart tests — also the framework-independence proof (no Flutter binding)
	cd $(CORE) && dart test

test-app: ## Flutter tests for the desktop app
	cd $(APP) && flutter test

# Run only the tests matching lib files changed against a base ref. The default
# base is `main`, diffed from the merge base, so it covers the whole branch plus
# uncommitted work. Pass BASE=HEAD for only what is still uncommitted.
# Usage: make test-changed [BASE=main|HEAD|<ref>] [COVERAGE=0]
BASE ?= main
COVERAGE ?= 1
test-changed: ## Test only what this branch changed, with coverage for those files
	@dart run tool/run_changed_tests.dart $(if $(filter 1,$(COVERAGE)),--coverage) $(BASE)

test-changed-html: test-changed ## Same as test-changed, then open the narrowed coverage report
	@test -s coverage/changed_files.txt || { echo "No changed files with coverage."; exit 1; }
	@lcov --extract coverage/lcov.info $$(cat coverage/changed_files.txt) \
		--output-file coverage/changed.info --ignore-errors empty,unused >/dev/null
	@genhtml coverage/changed.info --output-directory coverage/html/changed
	@open coverage/html/changed/index.html

test-last: ## Run the most recently modified test files
	@LAST_FILES=$$(find $(CORE)/test $(APP)/test -name "*.dart" -type f -exec ls -t {} + 2>/dev/null | head -n 20); \
	if [ -n "$$LAST_FILES" ]; then \
		echo "Running the most recently modified tests:"; \
		echo "$$LAST_FILES" | tr ' ' '\n'; \
		cd $(APP) && flutter test --no-color=false -r expanded $$LAST_FILES; \
	else \
		echo "No .dart test files found."; \
	fi

coverage: ## Full coverage report for the app, opened in the browser
	cd $(APP) && flutter test --coverage
	genhtml $(APP)/coverage/lcov.info --output-directory $(APP)/coverage/html
	open $(APP)/coverage/html/index.html

##############################
### *** Codegen *** ###
##############################

runner: ## Run build_runner in both packages
	cd $(CORE) && dart run build_runner build --delete-conflicting-outputs
	cd $(APP) && dart run build_runner build --delete-conflicting-outputs

runner-hard: ## Delete generated files, then regenerate from scratch
	find . -name "*.freezed.dart" -delete
	find . -name "*.g.dart" -delete
	$(MAKE) runner

runner-last: ## Regenerate only for directories touched in the last 5 minutes
	@CHANGED_DIRS=$$(find $(CORE)/lib $(APP)/lib -name "*.dart" -type f -mmin -5 \
		! -name "*.g.dart" \
		! -name "*.freezed.dart" | xargs -n1 dirname | sort -u); \
	if [ -n "$$CHANGED_DIRS" ]; then \
		echo "Running build_runner for:"; \
		echo "$$CHANGED_DIRS" | tr ' ' '\n'; \
		BUILD_FILTERS=$$(echo "$$CHANGED_DIRS" | xargs -n1 -I{} echo --build-filter={}/** | tr '\n' ' '); \
		dart run build_runner build $$BUILD_FILTERS --delete-conflicting-outputs; \
	else \
		echo "Nothing modified in the last 5 minutes. Skipping build_runner."; \
	fi

runner-watch: ## Regenerate continuously while you work
	cd $(APP) && dart run build_runner watch --delete-conflicting-outputs

##############################
### *** Run *** ###
##############################

run: ## Run the app (override with DEVICE=windows|linux|macos)
	cd $(APP) && flutter run -d $(DEVICE)

# Enable experimental features locally. Flags are build-time only; see
# docs/patterns/feature-flags.md. Usage:
#   make run-flags FLAGS="FEATURE_DIFF_V1=true FEATURE_WIKILINKS=true"
run-flags: ## Run with feature flags enabled (FLAGS="NAME=true ...")
	@test -n "$(FLAGS)" || { echo 'Usage: make run-flags FLAGS="FEATURE_DIFF_V1=true"'; exit 1; }
	cd $(APP) && flutter run -d $(DEVICE) \
		$$(for f in $(FLAGS); do printf -- "--dart-define=%s " $$f; done)

flags: ## List the feature flags declared in the app
	@grep -n "fromEnvironment" $(APP)/lib/core/features.dart 2>/dev/null \
		|| echo "No flags declared yet (expected in $(APP)/lib/core/features.dart)."

##############################
### *** Build *** ###
##############################

# These produce the community build: a verification that the public repo
# compiles on its own. The distributed artifact is the official build, produced
# from the private repo — see docs/decisions/012-*.md.

build: ## Compile check for the current platform (artifact is not distributed)
	cd $(APP) && flutter build $(DEVICE) --release

build-linux: ## Compile check for Linux
	cd $(APP) && flutter build linux --release

build-macos: ## Compile check for macOS
	cd $(APP) && flutter build macos --release

build-windows: ## Compile check for Windows
	cd $(APP) && flutter build windows --release
