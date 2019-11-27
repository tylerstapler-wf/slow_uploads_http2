Large uploads through ALBs are extremely slow when using http2. Uploads are consistently 6+ times slower when using http2. We were advised to disable http2 on the ALB as a workaround for upload slowness. Disabling http2 solves the immediate problem but we need to use http2 in the future for some subset of our services. We cannot switch to NLBs because our customer contracts mandate that we use WAF on our APIs. Is this a bug that the ALB team is aware of? Is there anything on the road map that can help us use http2 and ALBs together?

I've included reproduction steps and tooling [in this github repo](https://github.com/tylerstapler-wf/slow_uploads_http2).

# Network Diagram

Our environment has an ALB which forwards traffic to several nginx containers running in Kubernetes. The nginx containers forward the traffic to the end service.

![Network Diagram](./network_diagram.png)

# Reproduction Instructions

I build a simple server using FastAPI which just reads file uploads and throws away the data. I also wrote a python script which makes it easy to toggle http vs http2.

If you don't care to set up the server you can test against a deployed version of the service at this url https://h.squad2.workiva.org/slow_uploads/uploadfile/

Skip to [Configuring the client](#configuring-the-client) to get started sending data.

## Setting up the server

1. Build the docker container
```
docker build . -t some_tag
```

2. Push the container to your docker registry

````
docker push some_tag
````

3. Install the server using Kubernetes (or some other method)
A helm chart is included. It's somewhat Workiva specific but it can be modified to suit your needs.
```
helm install slow-uploads helm/slow-uploads --set ingress.clusterDomain=h.squad2.workiva.org
```

## Configuring the client

1. Generate your test data. I used random data from urandom.

Generate 100Mb of random data
```
dd if=/dev/urandom of=random_data_100mb bs=1M count=100
```

2. Install the dependencies for the client script

```
pip3 install -r client_requirements.txt
```


3. Test uploads using http1 and http2
```
╰─ ./upload_blob.py --target https://h.squad2.workiva.org/slow_uploads/uploadfile/ --file random_data_100mb
Using http1
Started at 2019-11-20 09:14:57.475375
Ended at 2019-11-20 09:15:13.509904
Upload took: 0:00:16.034529
```

```
╰─ ./upload_blob.py --target https://h.squad2.workiva.org/slow_uploads/uploadfile/ --file random_data_100mb --http
2
Using http2
Started at 2019-11-20 09:17:57.184395
Ended at 2019-11-20 09:19:03.050816
Upload took: 0:01:05.866421
```

# Additional included resources

## PCAPS
These [PCAPS](https://drive.google.com/drive/u/0/folders/1m83XW-7O43wtxAk9m64iJYRqOIJELPzH) are taken from the client machine during the uploads. You should be able to open these in Wireshark and decrypt the HTTPS by specifying the Pre-Master Secret.

You can use the file `sslkeylog.txt` to decrypt the provided pcaps. For more information on how to do this [see the wireshark documentation](https://wiki.wireshark.org/TLS?action=show&redirect=SSL#Using_the_.28Pre.29-Master-Secret)

## Logs

Related logs from the `ALB` and `nginx-ingress` are included in the file `load_balancer_logs.json`. They were exported from splunk as csv.
