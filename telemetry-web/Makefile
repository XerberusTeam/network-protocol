.DEFAULT_GOAL=help

# Show this help.
help:
	@awk '/^#/{c=substr($$0,3);next}c&&/^[[:alpha:]][[:print:]]+:/{print substr($$1,1,index($$1,":")),c}1{c=0}' $(MAKEFILE_LIST) | column -s: -t

docker-build:
	./scripts/build.sh

docker-publish:
	./scripts/publish.sh
