### 事前準備
以下のツール群の環境構築を行なっておくこと
[terraform]: 1.4.5
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

[golang-migrate] v4.15.2
https://github.com/golang-migrate/migrate/tree/v4.15.2/cmd/migrate

[aws-ssm]
https://docs.aws.amazon.com/ja_jp/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html

[docker]
https://docs.docker.com/engine/install/

### 環境構築手順
1. terraformを適用するAWSアカウントのプロファイルを設定しておく
2. 作成するAWSアカウントで以下のrdsパスワード用のSSMの値を手動で作成しておく
3. terraformの状態管理するS3バケットを作成する　
   ・${env}/main.tfのbackendのs3に名前は記載している
   ・バージョニングは有効にする
 
```
パラメータ名: /prefix/xxx/db/password
種類：String
```

3. 以下のディレクトリに移動してterraformで環境構築を行う
 
```
1. dockerディレクトリ配下のrun.shでpostgresqlを起動する
2. lambdaのtypescriptをビルドする
./build.sh

3. terraformを適用する 
cd terraform/project/environments/${dev or prod}
terraform init
terraform apply
```

4. 以下のコマンドでローカルからSSM -> 踏台EC2 -> RDSへ接続する
```
aws ssm start-session --target <踏み台EC2のインスタンスID> --region ap-northeast-1 --profile ${接続先のAWSプロファイル} \
--document AWS-StartPortForwardingSessionToRemoteHost \
--parameters "{\"host\":[\"<RDSのライターのエンドポイント>\"], \"portNumber\":[\"5432\"], \"localPortNumber\":[\"5434\"]}"


例) aws ssm start-session --target i-xxxx --region ap-northeast-1 --profile xxxxx \
--document AWS-StartPortForwardingSessionToRemoteHost \
--parameters "{\"host\":[\"prefix-xxx-dev-aurora-postgresql-cluster.cluster-xxxxx.ap-northeast-1.rds.amazonaws.com\"], \"portNumber\":[\"5432\"], \"localPortNumber\":[\"5434\"]}"
```

6. migrationを適用する
```
cd migrate
migrate --path ./sql --database 'postgresql://<ユーザー名>:<パスワード>@localhost:5434/<データベース名>?sslmode=disable' -verbose up
```

----------------------
検証コマンド一覧

ローカルからRDSへ接続する
1. 環境構築手順の手順.4の方法でローカル->RDS接続を行う
2. 別ターミナルで以下のコマンドを実行する
 
```
psql -h localhost -p 5434 -U <作成したデータベースのユーザー名: ex. dev_master_user> -d prefix_xxx
```


踏み台EC2に接続
```
aws ssm start-session --target i-0bdb9656ccc507137 --region ap-northeast-1 --profile prefix-xxx-sandbox
sudo -s
```


Kinesisにテストデータを送信する方法
```
1. 適当なダミーデータのファイルを作成する
{
    "Key1": "Value1",
    "Key2": "Value2"
}

2. エンコードする
openssl base64 -in data.json -out encodedData.json

3. Kinesisに送信する
aws kinesis put-record --stream-name <任意のKinesis> --partition-key 123 --data file://encodedData.json
```

