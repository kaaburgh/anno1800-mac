.PHONY: check doctor bootstrap inspect capture compare

check:
	@set -e; for f in scripts/*.sh; do bash -n "$$f"; done
	python3 -m py_compile scripts/*.py

doctor:
	bash scripts/doctor.sh

bootstrap:
	@test -n "$(WRAPPER)" || (echo "Set WRAPPER=/path/to/Anno1800.app" >&2; exit 2)
	bash scripts/bootstrap-sikarugir-wrapper.sh --wrapper "$(WRAPPER)" $(if $(ENGINE),--engine "$(ENGINE)",) $(if $(TEMPLATE),--template "$(TEMPLATE)",)

inspect:
	@test -n "$(WRAPPER)" || (echo "Set WRAPPER=/path/to/Anno1800.app" >&2; exit 2)
	bash scripts/inspect-wrapper.sh "$(WRAPPER)"

capture:
	@test -n "$(WRAPPER)" || (echo "Set WRAPPER=/path/to/Anno1800.app" >&2; exit 2)
	@test -n "$(LABEL)" || (echo "Set LABEL=..." >&2; exit 2)
	bash scripts/capture-baseline.sh --wrapper "$(WRAPPER)" --label "$(LABEL)" $(if $(NOTE),--note "$(NOTE)",)

compare:
	@test -n "$(LEFT)" || (echo "Set LEFT=artifacts/..." >&2; exit 2)
	@test -n "$(RIGHT)" || (echo "Set RIGHT=artifacts/..." >&2; exit 2)
	python3 scripts/compare-captures.py "$(LEFT)" "$(RIGHT)"
