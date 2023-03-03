HUB ?= quay.io/yuaxu
CONTAINER_CLI ?= podman

BUILD_IMAGE = maistra_builder
BUILD_IMAGE_VERSIONS = $(BUILD_IMAGE)_v2

${BUILD_IMAGE}: $(BUILD_IMAGE_VERSIONS)

# Build a specific maistra image. Example of usage: make maistra_builder_v2
${BUILD_IMAGE}_%:
	$(CONTAINER_CLI) build -t ${HUB}/${BUILD_IMAGE}:$* \
				 -f builder/$@.Dockerfile builder