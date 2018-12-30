.PHONY: clean compile build apply greetings

BONNY_IMAGE=quay.io/coryodaniel/hello_operator

all: clean compile build apply

compile:
	mix deps.get
	mix compile

build:
	mix bonny.gen.dockerfile
	docker build -t ${BONNY_IMAGE} .
	docker push ${BONNY_IMAGE}:latest

apply:
	mix bonny.gen.manifest --image ${BONNY_IMAGE}
	kubectl apply -f ./manifest.yaml
	kubectl get all

greetings:
	kubectl apply -f ./greetings.yaml
	kubectl get all

clean:
	- kubectl delete -f ./greetings.yaml
	sleep 5
	- kubectl delete -f ./manifest.yaml
	- rm manifest.yaml
	- rm -rf mix.lock _build deps
