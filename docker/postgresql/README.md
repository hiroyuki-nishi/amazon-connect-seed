# 起動方法+アクセス
1. 以下のコマンドを実行します。
```
./run.sh
```

# Tips
## マウントエラーの場合
https://qiita.com/nochifuchi/items/d388186409c2c438eb97
## コンテナにアクセス
docker-compose exec db /bin/bash
## データベース選択
psql -U admin 

## テーブル一覧表示
\dt
