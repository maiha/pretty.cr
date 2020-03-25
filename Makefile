SHELL=/bin/bash

CRYSTAL ?= crystal

SUPPORT_VERSIONS=0.27.2 0.31.1 0.32.1 0.33.0

VERSION=
CURRENT_VERSION=$(shell git tag -l | sort -V | tail -1 | sed -e 's/^v//')
GUESSED_VERSION=$(shell git tag -l | sort -V | tail -1 | awk 'BEGIN { FS="." } { $$3++; } { printf "%d.%d.%d", $$1, $$2, $$3 }')

.PHONY : test
test: check_version_mismatch spec

.PHONY : spec
spec:
	$(CRYSTAL) spec -v --fail-fast

.PHONY: test_backward_compatibility
test_backward_compatibility:
	@for ver in $(SUPPORT_VERSIONS); do \
	  crenv local $$ver; echo $$ver; crystal spec || exit 1; \
	done
	@make -s commit_backward_compatibility

.PHONY: commit_backward_compatibility
commit_backward_compatibility:
	@sed -i -e 's/^.*supported versions.*$$/* **supported versions** : $(SUPPORT_VERSIONS)/' README.md

.PHONY : check_version_mismatch
check_version_mismatch: shard.yml README.md
	diff -w -c <(grep version: README.md) <(grep ^version: shard.yml)

.PHONY : version
version: README.md
	@if [ "$(VERSION)" = "" ]; then \
	  echo "ERROR: specify VERSION as bellow. (current: $(CURRENT_VERSION))";\
	  echo "  make version VERSION=$(GUESSED_VERSION)";\
	else \
	  sed -i -e 's/^version: .*/version: $(VERSION)/' shard.yml ;\
	  sed -i -e 's/^    version: [0-9]\+\.[0-9]\+\.[0-9]\+/    version: $(VERSION)/' $< ;\
	  echo git commit -a -m "'$(COMMIT_MESSAGE)'" ;\
	  git commit -a -m 'version: $(VERSION)' ;\
	  git tag "v$(VERSION)" ;\
	fi

.PHONY : bump
bump:
	make version VERSION=$(GUESSED_VERSION) -s
