#!/bin/bash -eu

echo "Lambdaのビルドを開始します"
echo "ユニットテストを開始します"
(
  cd app
  npm i
  npx jest --runInBand
)
echo ".ts -> .jsに変換"
(
  cd app
  npx esbuild ./interfaces/handler/xxx-lambda-trigger/index.ts --bundle --platform=node --target=es2020 --outfile=../terraform/project/dist/xxx-lambda-trigger/index.js
  npx esbuild ./interfaces/handler/xxx-schedule-trigger/index.ts --bundle --platform=node --target=es2020 --outfile=../terraform/project/dist/xxx-schedule-trigger/index.js
  npx esbuild ./interfaces/handler/xxx-for-firehose/index.ts --bundle --platform=node --target=es2020 --outfile=../terraform/project/dist/xxx-for-firehose/index.js
)
echo "Lambdaのビルドが完了しました。"
echo "終了"