TARGET_URL=https://h.squad2.workiva.org/slow_uploads/uploadfile/
HTTP1_ARGS=--target $(TARGET_URL) --file random_data_100mb
HTTP2_ARGS=$(HTTP1_ARGS) --http2

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
	dart upload_blob.dart $(HTTP1_ARGS)

test-dart-http2:
	dart upload_blob.dart $(HTTP2_ARGS)

test-http1: build-client
	docker run --rm -it -v $(shell pwd):/slow_uploads slow_uploads_client:dev /working/upload_blob.py $(HTTP1_ARGS)

test-http2: build-client
	docker run --rm -it -v $(shell pwd):/slow_uploads slow_uploads_client:dev /working/upload_blob.py $(HTTP2_ARGS)

test-curl-http1:
	./run_curl.py $(HTTP1_ARGS)

test-curl-http2:
	./run_curl.py $(HTTP2_ARGS)

test-nghttp2:
	nghttp --stat --data random_data_100mb https://h.squad2.workiva.org/slow_uploads/uploadfile/

build-go-client:
	@go build -o upload_blob .

test-go-http1: build-go-client
	./upload_blob $(HTTP1_ARGS)

test-go-http2: build-go-client
	./upload_blob $(HTTP2_ARGS)
