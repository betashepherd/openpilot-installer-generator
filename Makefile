MAIN_PKG := openpilot-installer
MAIN_PREFIX := $(dir $(MAIN_PKG))
MAIN := $(subst $(MAIN_PREFIX), , $(MAIN_PKG))
BIN := $(strip $(MAIN))

#GIT_TAG := $(shell git describe --abbrev=0 --tags 2>/dev/null || echo 0.0.0)
GIT_TAG := 0.0.1
GIT_COMMIT_SEQ := $(shell git rev-parse --short HEAD)
GIT_COMMIT_CNT := $(shell git rev-list --all --count)
VERSION := $(GIT_TAG).$(GIT_COMMIT_CNT).$(GIT_COMMIT_SEQ)
FULL_VERSION := $(MAIN_PKG):$(VERSION)

build:
	go build -tags=jsoniter -mod vendor -o $(BIN).$(VERSION)

frontend:
	cd frontend && npm install --registry=https://registry.npm.taobao.org && npm run build

pb:
	protoc --go_out=plugins=grpc:./ ./protos/*/*.proto

docker-login:
	docker login ccr.ccs.tencentyun.com --username=xxxxx --password=xxxxxxx

docker-save:
	docker save ccr.ccs.tencentyun.com/xspace/$(FULL_VERSION) > $(MAIN_PKG).$(VERSION).tar

docker-build:
	echo $(VERSION) > build.txt
	docker build . -t ccr.ccs.tencentyun.com/xspace/$(FULL_VERSION) && \
	docker push ccr.ccs.tencentyun.com/xspace/$(FULL_VERSION)

docker-clean:
	docker images | grep $(MAIN_PKG) | awk '{print $$3}' | xargs docker rmi -f
	echo "y" | docker image prune

deploy:
	echo $(VERSION) > build.txt
	docker build . -t ccr.ccs.tencentyun.com/xspace/$(MAIN_PKG):$(VERSION)
	docker push ccr.ccs.tencentyun.com/xspace/$(MAIN_PKG):$(VERSION)
	kubectl --kubeconfig .k3s.yaml config set-context --current --namespace $(MAIN_PKG)
	kubectl --kubeconfig .k3s.yaml set image deployment php-fpm-nginx php-fpm=ccr.ccs.tencentyun.com/xspace/$(MAIN_PKG):$(VERSION)

.PHONY: build frontend
