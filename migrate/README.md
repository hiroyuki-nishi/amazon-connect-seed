## マイグレーション実行方法(ローカル)
1. dockerディレクトリ配下のrun.shでデータベースを起動する
```
./run.sh
```

2. ローカルのデータベースにマイグレーションを適用する
```
migrate --path ./sql --database 'postgresql://admin:admin123@localhost:5432/admin?sslmode=disable' -verbose up  
```
