# env-server-k8s

## 概要
自身のenvをレスポンスとして返すwebサーバと、それをkubernetesにデプロイするためのマニフェスト

## 前提条件
以下がインストールされていること。

- python 3.12
- poetry
- Docker
- kubectl
- kind
- kustomize

## 環境構築
1. Python依存関係のインストール
    ```
    poetry install
    ```
1. kindクラスタの作成
    developmentとproduction用のクラスタを作成
    ```
    kind create cluster --name dev-cluster --config kind-config.yaml
    kind create cluster --name prod-cluster --config kind-config.yaml
    ```

1. Docker imageのビルド、ロード
    webサーバ用のDocker imageをビルドし、各クラスタにロード
    ```
    docker build -t env-webserver:latest .
    kind load docker-image env-webserver:latest --name dev-cluster
    kind load docker-image env-webserver:latest --name prod-cluster
    ```

1. メトリクスサーバーのインストール
    HPAを使用するためにメトリクスサーバーをインストール
    ```
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    ```
    1. PodがReadyになっている事を確認する
        ```
        kubectl get po -A
        ```
    1. Readyにならない場合は以下の手順で修正
        参考：https://github.com/kubernetes-sigs/kind/issues/398#issuecomment-478311167
        1. metrics-severのdeploymentを修正
            ```
            kubectl edit deployment metrics-server -n kube-system
            ```
        1. `args`に以下様にflags を追加
            ```
                args:
                - --kubelet-insecure-tls
                - --kubelet-preferred-address-types=InternalIP
            ```


## マニフェストの適用
各環境にマニフェストを適用
```
kubectl --context kind-dev-cluster apply -k kubernetes/overlays/development
kubectl --context kind-dev-cluster apply -k kubernetes/overlays/production
```


## 動作確認
```
kubectl --context kind-dev-cluster port-forward service/webserver-service 8080:80
kubectl --context kind-prod-cluster port-forward service/webserver-service 8081:80
```
