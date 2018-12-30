.PHONY: build clean

BONNY_IMAGE=quay.io/coryodaniel/hello_operator

build: clean
build:
	mix deps.get
	mix compile
	mix bonny.gen.dockerfile
	docker build -t ${BONNY_IMAGE} .
	docker push ${BONNY_IMAGE}:latest
	mix bonny.gen.manifest --image ${BONNY_IMAGE}
	kubectl apply -f ./manifest.yaml
	kubectl get all
	echo "kubectl apply -f ./greetings.yaml"

clean:
	- kubectl delete -f ./greetings.yaml
	sleep 10
	- kubectl delete -f ./manifest.yaml
	- rm manifest.yaml
	- rm -rf mix.lock _build deps
