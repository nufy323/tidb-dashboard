DASHBOARD_PKG := github.com/pingcap/tidb-dashboard

BUILD_TAGS ?=

LDFLAGS ?=

FEATURE_VERSION ?= 6.2.0

WITHOUT_NGM ?= false

E2E_SPEC ?=

ifeq ($(UI),1)
	BUILD_TAGS += ui_server
endif

LDFLAGS += -X "$(DASHBOARD_PKG)/pkg/utils/version.InternalVersion=$(shell grep -v '^\#' ./release-version)"
LDFLAGS += -X "$(DASHBOARD_PKG)/pkg/utils/version.Standalone=Yes"
LDFLAGS += -X "$(DASHBOARD_PKG)/pkg/utils/version.PDVersion=N/A"
LDFLAGS += -X "$(DASHBOARD_PKG)/pkg/utils/version.BuildTime=$(shell date -u '+%Y-%m-%d %I:%M:%S')"
LDFLAGS += -X "$(DASHBOARD_PKG)/pkg/utils/version.BuildGitHash=$(shell git rev-parse HEAD)"

TIDB_VERSION ?= latest

default: server

.PHONY: clean
clean:
	rm -rf ./coverage

.PHONY: install_tools
install_tools:
	scripts/install_go_tools.sh

.PHONY: lint
lint:
	scripts/lint.sh

.PHONY: test
test: clean unit_test integration_test

.PHONY: unit_test
unit_test:
	@mkdir -p ./coverage
	GO111MODULE=on go test -v -cover -coverprofile=coverage/unit_test.txt ./pkg/... ./util/...

.PHONY: integration_test
integration_test:
	@mkdir -p ./coverage
	@TIDB_VERSION=${TIDB_VERSION} tests/run.sh

.PHONY: e2e_test
e2e_test:
	@if $(WITHOUT_NGM); then\
		make e2e_without_ngm_test;\
	else\
		make e2e_compat_features_test;\
		make e2e_common_features_test;\
	fi

.PHONY: e2e_compat_features_test
e2e_compat_features_test:
	cd ui &&\
	pnpm i &&\
	cd packages/tidb-dashboard-for-op &&\
	pnpm run:e2e-test:compat-features --env FEATURE_VERSION=$(FEATURE_VERSION) TIDB_VERSION=$(TIDB_VERSION)

.PHONY: e2e_common_features_test
e2e_common_features_test:
	cd ui &&\
	pnpm i &&\
	cd packages/tidb-dashboard-for-op &&\
	pnpm run:e2e-test:common-features --env TIDB_VERSION=$(TIDB_VERSION)

.PHONY: e2e_without_ngm_test
e2e_without_ngm_test:
	cd ui &&\
	pnpm i &&\
	cd packages/tidb-dashboard-for-op &&\
	pnpm run:e2e-test:without-ngm --env TIDB_VERSION=$(TIDB_VERSION) WITHOUT_NGM=$(WITHOUT_NGM)

.PHONY: e2e_test_specify
e2e_test_specify:
	cd ui &&\
	pnpm i &&\
	cd packages/tidb-dashboard-for-op &&\
	pnpm run:e2e-test:specify --env TIDB_VERSION=$(TIDB_VERSION) -- --spec $(E2E_SPEC)

.PHONY: dev
dev: lint default

.PHONY: ui_deps
ui_deps: install_tools
	cd ui &&\
	pnpm i

.PHONY: ui
ui: ui_deps
	cd ui &&\
	pnpm build

.PHONY: go_generate
go_generate: export PATH := $(shell pwd)/bin:$(PATH)
go_generate:
	scripts/generate_swagger_spec.sh
	go generate -x ./...

.PHONY: server
server: install_tools go_generate
ifeq ($(UI),1)
	scripts/embed_ui_assets.sh
endif
	go build -o bin/tidb-dashboard -ldflags '$(LDFLAGS)' -tags "${BUILD_TAGS}" cmd/tidb-dashboard/main.go

.PHONY: run
run:
	bin/tidb-dashboard --debug --experimental --feature-version "$(FEATURE_VERSION)" --host 0.0.0.0
