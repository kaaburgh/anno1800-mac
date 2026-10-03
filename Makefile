.PHONY: doctor inspect capture compare

doctor:
	bash scripts/doctor.sh

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
