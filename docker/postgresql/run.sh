#!/bin/bash -eu

echo "Postgresqlを起動します"
(
  docker-compose up -d
  cd ../../migrate
  migrate --path ./sql --database 'postgresql://admin:admin123@localhost:5432/admin?sslmode=disable' -verbose up
)
echo "起動完了しました。"
