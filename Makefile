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
# before it; src/test/integrity/architecture_test.dart is what enforces that.
PKGS := core domain application infra data presentation

# Everything a PKG= parameter accepts, plus `arch` for the graph test. The
# apps are addressed as `desktop`/`mobile`, matching their folders.
APPS := desktop mobile
ALL_PKGS := $(PKGS) $(APPS)

# On by default: every test target reports each package's line coverage
# alongside its pass/fail line, with no separate run needed. Override with
# COVERAGE=0 (e.g. `make flutter-test COVERAGE=0`) when the instrumentation
# overhead isn't worth it, such as iterating on a single failing test.
COVERAGE ?= 1
RUNNER   := dart run tool/run_tests.dart $(if $(filter 1,$(COVERAGE)),--coverage)

# Project Flutter version. Single source of truth: `src/.fvmrc` (also read by
# FVM, by the GitHub Actions workflows and by VS Code). It lives inside src/
# because that is the actual Flutter/Dart project root — FVM pins a version
# per project, and the repository root is not one. To switch versions, edit
# `src/.fvmrc` only.
FLUTTER_VERSION := $(shell sed -n 's/.*"flutter"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' $(SRC)/.fvmrc 2>/dev/null)

# Desktop device for `make run`. Override: make run DEVICE=windows
DEVICE ?= macos

.DEFAULT_GOAL := help
.PHONY: help setup clean format analyze verify flutter-test flutter-test-arch \
        flutter-test-packages flutter-test-app flutter-test-only flutter-test-diff \
        coverage coverage-gate runner runner-hard runner-watch fvm run run-flags flags \
        build build-linux build-macos build-windows

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
	@for a in $(APPS); do (cd $(SRC)/apps/$$a && flutter clean); done
	cd $(SRC) && flutter pub get

fvm: ## Pin the Flutter version declared in src/.fvmrc for this workspace
	@test -n "$(FLUTTER_VERSION)" || { echo "Could not read the Flutter version from $(SRC)/.fvmrc"; exit 1; }
	dart pub global activate fvm
	cd $(SRC) && fvm use $(FLUTTER_VERSION)

##############################
### *** Quality *** ###
##############################

format: ## Format Dart code, failing if anything changes
	dart format --set-exit-if-changed $(SRC) tool

analyze: ## Static analysis across every package at once
	cd $(SRC) && flutter analyze

verify: format analyze flutter-test coverage-gate ## Everything CI runs, in one command

##############################
### *** Tests *** ###
##############################

# Every test target runs through tool/run_tests.dart: a live progress line per
# package — files completed / total, running pass/fail counts, elapsed time
# ticking — driven by package:test's own `--reporter=json` stream, with every
# failure printed the instant it happens rather than scrolled past waiting
# for the run to end. Seven packages run back to back with no sense of
# progress otherwise, and JSON events are what a shell script cannot parse
# without dragging in `jq` — the tool needs nothing beyond the Dart SDK.
#
# Two optional parameters, both read by the runner:
#
#   PKG        one package or several, by folder name; `desktop`/`mobile` are
#              the apps
#                make flutter-test PKG=domain
#                make flutter-test PKG="domain data"
#   TEST_ARGS  passed straight through to dart/flutter test
#                make flutter-test PKG=domain TEST_ARGS="-n parses --reporter expanded"
#
# Without PKG, everything runs: the architecture assertions, then each
# package in dependency order, then the apps.

flutter-test: ## Run every test, live (PKG=<name> restricts)
ifdef PKG
	@$(MAKE) --no-print-directory flutter-test-only
else
	@$(RUNNER) arch $(PKGS) $(APPS)
endif

flutter-test-arch: ## Assert the layer graph matches what the pubspecs declare
	@$(RUNNER) arch

# Also the framework-independence proof: these run under `dart test`, with no
# Flutter binding available. A layer that quietly grew a Flutter dependency
# fails here rather than at review time.
flutter-test-packages: ## Pure Dart tests, package by package
	@$(RUNNER) $(PKGS)

flutter-test-app: ## Flutter tests for the apps (desktop, mobile)
	@$(RUNNER) $(APPS)

flutter-test-only: ## Internal: the PKG branch of `flutter-test`
	@for p in $(PKG); do \
		case " $(ALL_PKGS) " in \
			*" $$p "*) ;; \
			*) echo "Unknown package '$$p'. Available: $(ALL_PKGS)"; exit 1 ;; \
		esac; \
	done
	@$(RUNNER) $(PKG)

# What changed against BASE (default: main — override for a narrower diff,
# e.g. BASE=HEAD for only uncommitted work) decides which TEST FILES run, by
# filename convention alone: a changed lib/foo.dart runs foo_test.dart,
# wherever it lives under that package's test/; a changed test file runs
# directly. No import graph, no package-wide fallback — touching tom_core
# does not rerun every package that depends on it, only the tests whose name
# says they cover what changed. `make flutter-test` is what proves the whole
# workspace is green before a PR; this is what proves the part you touched is.
# See tool/run_changed_tests.dart.
flutter-test-diff: ## Test only what this branch's diff maps to (BASE=main)
	@dart run tool/run_changed_tests.dart \
		$(if $(filter 1,$(COVERAGE)),--coverage) $${BASE:-main}

coverage: ## Coverage report, opened in the browser (PKG=<name> for one package)
	@for p in $(if $(PKG),$(PKG),desktop); do \
		if [ "$$p" = desktop ] || [ "$$p" = mobile ]; then \
			(cd $(SRC)/apps/$$p && flutter test --coverage) || exit 1; \
			d=$(SRC)/apps/$$p; \
		else \
			(cd $(SRC)/packages/$$p && dart test --coverage=coverage \
				&& dart run coverage:format_coverage --lcov --in=coverage \
					--out=coverage/lcov.info --report-on=lib \
					"--ignore-files=**.freezed.dart,**.g.dart") || exit 1; \
			d=$(SRC)/packages/$$p; \
		fi; \
		genhtml $$d/coverage/lcov.info --output-directory $$d/coverage/html; \
		open $$d/coverage/html/index.html; \
	done

# Gates on line coverage rather than opening a report: a package with both
# real lib/src code and tests falling under the threshold is the point. A
# package with nothing under lib/src yet (application, data, presentation
# today), or with code but no tests yet, is skipped rather than counted
# against — see tool/coverage_gate.dart.
coverage-gate: ## Fail if any implemented package is under the coverage threshold (THRESHOLD=95)
	@dart run tool/coverage_gate.dart $(if $(THRESHOLD),--threshold=$(THRESHOLD))

##############################
### *** Codegen *** ###
##############################

# A live dashboard, one row per package, showing which one build_runner is
# currently on and which stage its log is at — same idea as flutter-test's
# runner (tool/run_tests.dart), adapted to build_runner's plain-text log
# instead of a JSON event stream. Only packages with changes against BASE
# (default: main) actually run; the rest show as skipped, with the reason —
# no build_runner declared, or no change in this branch. See
# tool/run_codegen.dart.
runner: ## Run build_runner on packages changed in this branch (BASE=main)
	@dart run tool/run_codegen.dart $(PKGS) $(APPS)

runner-hard: ## Delete generated files, then regenerate every package from scratch
	find $(SRC) -name "*.freezed.dart" -delete
	find $(SRC) -name "*.g.dart" -delete
	@dart run tool/run_codegen.dart --force $(PKGS) $(APPS)

runner-watch: ## Regenerate continuously while you work
	cd $(APP) && dart run build_runner watch --delete-conflicting-outputs

##############################
### *** Run *** ###
##############################

run: ## Run the app (override with DEVICE=windows|linux|macos)
	cd $(APP) && flutter run -d $(DEVICE)

# Enable experimental features locally. Flags are build-time only; see
# the "Feature flags" section of CONTRIBUTING.md. Usage:
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
# not produced here — see docs/process/repository-settings.md.

build: ## Compile check for the current platform (artifact is not distributed)
	cd $(APP) && flutter build $(DEVICE) --release

build-linux: ## Compile check for Linux
	cd $(APP) && flutter build linux --release

build-macos: ## Compile check for macOS
	cd $(APP) && flutter build macos --release

build-windows: ## Compile check for Windows
	cd $(APP) && flutter build windows --release
