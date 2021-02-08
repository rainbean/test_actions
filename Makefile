.DEFAULT_GOAL = run

run:
ifeq ($(OS), Windows_NT)
	@pwsh -noprofile -command "scripts\icon.ps1"
	@go run -tags gui -ldflags "-H windowsgui" .
else
	@go run -tags cli . $(filter-out $@,$(MAKECMDGOALS))
endif

build:
ifeq ($(OS), Windows_NT)
	@pwsh -noprofile -command "scripts\build.ps1"
else
	@scripts/build.sh
endif

test:
	go test ./...