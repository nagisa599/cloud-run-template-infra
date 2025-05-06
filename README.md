# cloud-run-template-infra

## 前提条件

### gcloud コマンドが使えること

```bash
$ gcloud --version
Google Cloud SDK 520.0.0
bq 2.1.15
core 2025.04.25
gcloud-crc32c 1.0.0
gsutil 5.34

```

## 注意すること

GCR の image をあらかじめ push しとくこと

```bash
docker build -f ./Dockerfile -t asia-northeast1-docker.pkg.dev/manamu-kasyatter-dev/gateway/test_1 .


gcloud auth configure-docker asia-northeast1-docker.pkg.dev

docker push asia-northeast1-docker.pkg.dev/manamu-kasyatter-dev/gateway/test_1
```

```bash
 curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  https://sample-api-cloud-run-488213584782.asia-northeast1.run.app
{"message":"Hello from FastAPI on Cloud Run!"}%
```
