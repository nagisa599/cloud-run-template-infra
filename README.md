# cloud-run-template-infra

- GCP の Cloud run と cloud build で実装するための terraform のコード
  ![Image](https://github.com/user-attachments/assets/80142ced-662c-4436-8d3e-8a0c1cafa0c7)

## 前提条件

- terraform コマンドが使える。
- gcloud コマンドが使える。

## 手順

1. gcloud コマンドでプロジェクトの作成
2. terraform からアクセスができるように gcloud にログインを行う

```bash
gcloud auth application-default login
```

3. terraform 直下に terraform.tfstate を作成

```bash
project_id                        = ""
project_name                      = ""
github_app_installation_id        = ""
github_oauth_token_secret_version = ""
github_repository_remote_uri      = ""
```

4. terraform の初期化・構築 (cloud run の moudle はコメントアウト)

```bash
terraform init
terraform apply
```

5. docker image を GCR に push する (理由: cloud run で i1 つも image がないとエラーが出てしまうため)

```bash
$ docker buildx build --platform linux/amd64  -t asia-northeast1-docker.pkg.dev/manamu-kasyatter-dev/gateway/test_2 .

gcloud auth configure-docker asia-northeast1-docker.pkg.dev

docker push asia-northeast1-docker.pkg.dev/manamu-kasyatter-dev/gateway/test_2
```

6. terraform に cloud run の実装を追加(cloud run の moudle はコメントアウト)

```bash
terraform init
terraform apply
```

```bash
 curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  https://sample-api-cloud-run-488213584782.asia-northeast1.run.app
{"message":"Hello from FastAPI on Cloud Run!"}%
```
