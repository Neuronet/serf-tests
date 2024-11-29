DEV_IMAGE=python:3.11.10-bullseye
SIDECAR_IMAGE=neuronet3000/serf-sidecar
SIDECAR_IMAGE_TAG=0.1.0
USER_APP_IMAGE=neuronet3000/serf-user-app
USER_APP_IMAGE_TAG=0.1.0


ROOT_DIR := /opt/serf-tests

# Set tty flag in docker only if the Makefile runs within tty.
TTY=$(shell test -t 0 && echo '-t')

.PHONY: docker-shell
docker-shell:
	docker run \
	    --rm -i ${TTY} \
		-w ${ROOT_DIR} \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v `pwd`:${ROOT_DIR} \
		${DEV_IMAGE} \
		/bin/bash
	docker run \
		--rm -it \
		-v `pwd`:$(ROOT_DIR) \
		--workdir $(ROOT_DIR) \
		$(DEV_IMAGE) \
		chown --reference=. -R * .* || true

.PHONY: docker-alpine-shell
docker-alpine-shell:
	docker run \
	    --rm -it  \
		-w ${ROOT_DIR} \
		-v `pwd`:${ROOT_DIR} \
		alpine:3.20.3 \
		/bin/sh

.PHONY: build-sidecar-image
build-sidecar-image:
	docker build -t ${SIDECAR_IMAGE}:${SIDECAR_IMAGE_TAG} -f ./serf-seed/serf-sidecar.Dockerfile ./serf-seed

.PHONY: push-sidecar-image
push-sidecar-image:
	docker push ${SIDECAR_IMAGE}:${SIDECAR_IMAGE_TAG}

.PHONY: build-user-app-image
build-user-app-image:
	docker build -t ${USER_APP_IMAGE}:${USER_APP_IMAGE_TAG} -f ./user_app/Dockerfile ./user_app

.PHONY: push-user-app-image
push-user-app-image:
	docker push ${USER_APP_IMAGE}:${USER_APP_IMAGE_TAG}

.PHONY: deploy-serf-seed
deploy-serf-seed:
	kubectl create -f ./k8s/serf-seed/service.yaml
	kubectl create -f ./k8s/serf-seed/serf-seed-config-map.yaml
	kubectl create -f ./k8s/serf-seed/deployment.yaml

.PHONY: wipe-serf-seed
wipe-serf-seed:
	kubectl delete -f ./k8s/serf-seed/service.yaml
	kubectl delete -f ./k8s/serf-seed/deployment.yaml
	kubectl delete -f ./k8s/serf-seed/serf-seed-config-map.yaml

.PHONY: deploy-user-app
deploy-user-app:
	kubectl create -f ./k8s/user-app/config-map.yaml
	kubectl create -f ./k8s/user-app/serf-config-map.yaml
	kubectl create -f ./k8s/user-app/deployment.yaml

.PHONY: wipe-user-app
wipe-user-app:
	kubectl delete -f ./k8s/user-app/config-map.yaml
	kubectl delete -f ./k8s/user-app/serf-config-map.yaml
	kubectl delete -f ./k8s/user-app/deployment.yaml
