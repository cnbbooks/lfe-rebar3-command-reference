PROJ = slate
VERSION = 2.7.0
BASE_DOCKER_VERSION = ruby2.6
DOCKER_ORG = lfex
DOCKER_TAG_PREFIX = $(DOCKER_ORG)/$(PROJ)
FULL_VERSION = $(VERSION)-$(BASE_DOCKER_VERSION)
DOCKER_TAG = $(DOCKER_TAG_PREFIX):$(FULL_VERSION)
DOCKER_LATEST = $(DOCKER_TAG_PREFIX):latest
CONTAINER_NAME = lfe-rebar3-docs
PUBLISH_DIR = site

image:
	docker build . -t $(DOCKER_TAG)
	docker tag $(DOCKER_TAG) $(DOCKER_LATEST)

publish-image:
	docker push $(DOCKER_TAG)
	docker push $(DOCKER_LATEST)

run:
	docker run -d --rm --name $(CONTAINER_NAME) \
		-p 4567:4567 \
		-v `pwd`/site/current:/srv/slate/build \
		-v `pwd`/source:/srv/slate/source $(DOCKER_TAG)

stop:
	docker stop $(CONTAINER_NAME)

regen:
	docker exec -it $(CONTAINER_NAME) /bin/bash -c "bundle exec middleman build"

book/README.md:
	echo '# Content for `rebar3_lfe` Command Reference' > book/README.md
	echo 'Published at [lfe-rebar3.github.io](https://lfe-rebar3.github.io/)' >> book/README.md
	git add book/README.md

publish: book/README.md
	-@cd $(PUBLISH_DIR) && \
	git add images/* && \
	git commit -am "Regenerated documentation site." > /dev/null && \
	git push origin master
	-@git add $(PUBLISH_DIR) && \
	git commit -am "Updated submodule for recently published site content." && \
	git submodule update && \
	git push origin site-builder

regen-pub: regen publish
