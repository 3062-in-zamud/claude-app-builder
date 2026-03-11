.PHONY: test lint

test:
	bats tests/

lint:
	python3 scripts/audit-plugin-consistency.py
