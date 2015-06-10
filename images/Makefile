.PHONY: help
help:
	$(info )
	$(info This makefile will help you build docker images for Grimoire platform)
	$(info components based on the bitergia baseimages.)
	$(info )
	$(info Available options:)
	$(info )
	$(info - all:			Build all available images)
	$(info - vizgrimoire:			Build vizgrimoire image)
	$(info )
	@echo ""

.PHONY: vizgrimoire
vizgrimoire: $@
	docker build -t bitergia/$@ $@/

.PHONY: all
all: vizgrimoire

.PHONY: clean clean_vizgrimoire
clean: clean_scout

clean_vizgrimoire:
	-@docker rmi bitergia/vizgrimoire
