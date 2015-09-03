.PHONY: build proxy push

build: proxy
	docker build -t taste/hub .

proxy:
	docker run --rm -t -v $(PWD)/RemoteProxy:/usr/src/mymaven -w /usr/src/mymaven maven:3.2-jdk-7 mvn clean package
	cp RemoteProxy/target/TASTERemoteProxy-0.0.1-SNAPSHOT.jar app/

run:
	docker run -d \
	-p 4444:4444 \
	-e ETCD_HOST="http://docker-registry.intern.weebly.net:4001" \
	-e METEOR_HOST="http://docker-registry.intern.weebly.net:3000" \
	-e REDIS_HOST="docker-registry.intern.weebly.net" \
	--name taste_hub \
	-t taste/hub

push:
	docker push taste/hub
