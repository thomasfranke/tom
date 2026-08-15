####################################################################
###  *** Makefile for TOM ***                                    ###
### Run `make help` to list every target with a description.     ###
### Targets are a convenience, not a requirement: each one       ###
### wraps a short command the docs name directly, so nothing     ###
### here is needed to build, test or contribute.                 ###
###                                                              ###
### The Dart workspace lives in src/ so that the repository root ###
### stays readable — docs, licence and community files first.    ###
### Every target below hides that: run them from the root.       ###
####################################################################

SRC  := src
APP  := $(SRC)/apps/desktop

# The pure Dart layers, in dependency order. Each may depend only on the ones
# before it; src/test/architecture_test.dart is what enforces that.
PKGS := core domain application infra data presentation

# Project Flutter version. Single source of truth: `.fvmrc` (also read by FVM,
# by the GitHub Actions workflows and by VS Code). To switch versions, edit
# `.fvmrc` only.
FLUTTER_VERSION := $(shell sed -n 's/.*"flutter"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' .fvmrc 2>/dev/null)

# Desktop device for `make run`. Override: make run DEVICE=windows
DEVICE ?= macos

.DEFAULT_GOAL := help
.PHONY: help setup clean format analyze test test-arch test-packages test-app \
        coverage runner runner-hard runner-watch fvm run run-flags flags \
        build build-linux build-macos build-windows verify

##############################
### *** Help *** ###
##############################

help: ## List all targets
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-24s\033[0m %s\n", $$1, $$2}'

##############################
### *** Environment *** ###
##############################

setup: ## Resolve the whole workspace (one get for every package)
	cd $(SRC) && flutter pub get

clean: ## Clean build artifacts and re-resolve
	cd $(APP) && flutter clean
	cd $(SRC) && flutter pub get

fvm: ## Configure the Flutter version declared in .fvmrc
	@test -n "$(FLUTTER_VERSION)" || { echo "Could not read the Flutter version from .fvmrc"; exit 1; }
	dart pub global activate fvm
	fvm use $(FLUTTER_VERSION)
	fvm global $(FLUTTER_VERSION)

##############################
### *** Quality *** ###
##############################

format: ## Format Dart code, failing if anything changes
	dart format --set-exit-if-changed $(SRC)

analyze: ## Static analysis across every package at once
	cd $(SRC) && flutter analyze

verify: format analyze test ## Everything CI runs, in one command

##############################
### *** Tests *** ###
##############################

test: test-arch test-packages test-app ## Run every test in the workspace

test-arch: ## Assert the layer graph matches what the pubspecs declare
	cd $(SRC) && dart test test/architecture_test.dart

# Also the framework-independence proof: these run under `dart test`, with no
# Flutter binding available. A layer that quietly grew a Flutter dependency
# fails here rather than at review time.
test-packages: ## Pure Dart tests, package by package
	@for p in $(PKGS); do \
		if ls $(SRC)/packages/$$p/test/*.dart >/dev/null 2>&1; then \
			echo "── tom_$$p"; \
			(cd $(SRC)/packages/$$p && dart test) || exit 1; \
		else \
			echo "── tom_$$p (no tests yet)"; \
		fi; \
	done

test-app: ## Flutter tests for the desktop app
	@if ls $(APP)/test/*.dart >/dev/null 2>&1; then \
		cd $(APP) && flutter test; \
	else \
		echo "── tom_desktop (no tests yet)"; \
	fi

coverage: ## Coverage report for the app, opened in the browser
	cd $(APP) && flutter test --coverage
	genhtml $(APP)/coverage/lcov.info --output-directory $(APP)/coverage/html
	open $(APP)/coverage/html/index.html

##############################
### *** Codegen *** ###
##############################

runner: ## Run build_runner wherever a package declares it
	@for d in $(addprefix $(SRC)/packages/,$(PKGS)) $(APP); do \
		if grep -q "build_runner" $$d/pubspec.yaml 2>/dev/null; then \
			echo "── $$d"; \
			(cd $$d && dart run build_runner build --delete-conflicting-outputs) || exit 1; \
		fi; \
	done

runner-hard: ## Delete generated files, then regenerate from scratch
	find $(SRC) -name "*.freezed.dart" -delete
	find $(SRC) -name "*.g.dart" -delete
	$(MAKE) runner

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
# compiles on its own. The distributed artifact is the official build, which is
# not produced here — see docs/repository-settings.md.

build: ## Compile check for the current platform (artifact is not distributed)
	cd $(APP) && flutter build $(DEVICE) --release

build-linux: ## Compile check for Linux
	cd $(APP) && flutter build linux --release

build-macos: ## Compile check for macOS
	cd $(APP) && flutter build macos --release

build-windows: ## Compile check for Windows
	cd $(APP) && flutter build windows --release
