# Org-Account-Service

TerraformでLambdaとLambda layer を使ったインフラ構築。

---

## 📂 ディレクトリ構成

```bash
.
├── src/ # === アプリケーションコード ===
│ ├── functions/ # Lambda それぞれ
│ │ └── account_issue/
│ │ ├── handler.py
│ │ ├── requirements.txt
│ │ └── tests/
│ └── layers/
│   └── shared/ # 共通レイヤ
│     ├── mylib/ # (自前ユーティリティ)
│     ├── requirements.txt # 外部依存
│     └── build/ # make で自動生成
│
├── terraform/ # === IaC ===
│ ├── dev/ # 開発用スタック
│ ├── prod/ # 本番用スタック
│ └── modules/ # 再利用モジュール
│   ├── lambda/
│   ├── network/
│   └── rds/
│
├── dist/ # make で出力された ZIP 置き場
├── buildspec.yml # CodeBuild CI 定義
├── Makefile # テスト・ビルド補助
├── requirements-dev.txt # pytest, moto など
└── README.md # (このファイル)
```

---

## 🛠️ 前提ツール

| ツール      | バージョン例          |
|-------------|-----------------------|
| Terraform   | 1.6 以上              |
| Python      | 3.12                  |
| AWS CLI     | v2                    |
| make        | GNU make 推奨         |
| zip/unzip   | OS 標準で可           |

---

## 🚀 クイックスタート

```bash
# 1) クローン & venv
git clone <this-repo>
cd org-account-service
python -m venv .venv && source .venv/bin/activate

# 2) 開発依存をインストール
pip install -r requirements-dev.txt

# 3) 単体テスト
make test

# 4) Layer ZIP をビルド (依存 + 自前コード)
make layer-package

# 5) Terraform 初期化 & プラン確認
terraform -chdir=terraform/dev init
terraform -chdir=terraform/dev plan

# 6) デプロイ (dev 環境)
terraform -chdir=terraform/dev apply
```

>　NOTE  
  terraform/dev/main.tf の backend S3 バケット名・リージョンは
  環境に合わせて変更してください。


## 🧩 レイヤービルドの仕組み
1. `make layer-package`
    * `src/layers/shared/build/python/` に外部依存を `pip install -t` で展開
    * `mylib/` をコピー
    * `python/` ディレクトリだけを ZIP → `dist/shared_layer.zip`
1. Terraform は そのまま ZIP を参照して Lambda Layer を作成  
    `source_code_hash = filebase64sha256(...)` で差分検知。

## 💻 CI/CD (CodeBuild)
* `buildspec.yml` が `pytest` → `make layer-package → terraform apply` の順で実行。
* Unit テスト結果は JUnit XML でレポート出力。

## 📝 開発メモ
* 環境変数: 共有設定は `terraform/{env}/variables.tf` に、Lambda 個別は env_vars マップで渡す。

* Layer 分割
    * 依存がさらに増えたら「依存専用 Layer」「自前コード Layer」の2 段構成にしても良い。

* 推奨ライブラリ
    * `aws-lambda-powertools` でロギング／トレーシングを統一
    * `pymysql` で RDS (MySQL) へ接続

## 🤝 Contributing
1. `make test` が通ることを確認
2. PR を作成
3. レビュー後マージ
