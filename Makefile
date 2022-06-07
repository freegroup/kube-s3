all:
	docker build -t artifact.onwalk.net/k8s/kube-s3:latest .
	docker push artifact.onwalk.net/k8s/kube-s3:latest
