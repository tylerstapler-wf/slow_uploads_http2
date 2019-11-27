
build:
	workiva-build-cli -t docker.workiva.net/tylerstapler-wf/slow_uploads:dev

build-client: 
	@docker build -qf ClientDockerfile -t slow_uploads_client:dev .

upload: build
	docker push docker.workiva.net/tylerstapler-wf/slow_uploads:dev

context:
	kubectl config use-context squad2

install: context
	helm install slow-uploads helm/slow-uploads --set ingress.clusterDomain=squad2.workiva.org

test-dart-http1:
	dart upload_blob.dart --target https://h.squad2.workiva.org/slow_uploads/uploadfile/ --file random_data_100mb

test-dart-http2:
	dart upload_blob.dart --target https://h.squad2.workiva.org/slow_uploads/uploadfile/ --file random_data_100mb --http2

test-http1: build-client
	docker run --rm -it -v $(shell pwd):/slow_uploads slow_uploads_client:dev /working/upload_blob.py --target https://h.squad2.workiva.org/slow_uploads/uploadfile/ --file /slow_uploads/random_data_100mb

test-http2: build-client
	docker run --rm -it -v $(shell pwd):/slow_uploads slow_uploads_client:dev /working/upload_blob.py --target https://h.squad2.workiva.org/slow_uploads/uploadfile/ --http2 --file /slow_uploads/random_data_100mb

test-nghttp2:
	nghttp --stat --data random_data_100mb https://h.squad2.workiva.org/slow_uploads/uploadfile/

build-go-client:
	@go build -o upload_blob .

test-go-http1: build-go-client
	./upload_blob --target https://h.squad2.workiva.org/slow_uploads/uploadfile/ --file random_data_100mb

test-go-http2: build-go-client
	./upload_blob --target https://h.squad2.workiva.org/slow_uploads/uploadfile/ --http2 --file random_data_100mb
