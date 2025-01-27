# 定義: Docker Composeを使った便利コマンド集
# Docker Compose内のwebコンテナを使ってコマンドを実行する。

# -----定義済み変数-----
COMPOSE = docker compose
SERVICE = web

# -----RuboCop関連タスク-----
rubocop:
	$(COMPOSE) run --rm $(SERVICE) bundle exec rubocop

rubocop-performance:
	$(COMPOSE) run --rm $(SERVICE) bundle exec rubocop -P

rubocop-autocorrect:
	$(COMPOSE) run --rm $(SERVICE) bundle exec rubocop --auto-correct

rubocop-gen-config:  # RuboCopの設定ファイル(.rubocop.yml)を自動生成
	$(COMPOSE) run --rm $(SERVICE) bundle exec rubocop --auto-gen-config

# -----RSpec関連タスク-----
rspec:
	$(COMPOSE) run --rm $(SERVICE) bundle exec rspec

rspec-verbose:  # テスト & 結果をドキュメント形式表示
	$(COMPOSE) run --rm $(SERVICE) bundle exec rspec --format documentation

rspec-with-coverage:  # テスト & カバレッジレポート生成
	$(COMPOSE) run --rm $(SERVICE) bundle exec rspec --coverage

# -----その他便利タスク-----
build:
	$(COMPOSE) build

up:
	$(COMPOSE) up

down:
	$(COMPOSE) down

logs:  # コンテナのログをリアルタイム表示
	$(COMPOSE) logs -f

rails-c:
	$(COMPOSE) run --rm $(SERVICE) bundle exec rails console

# -----インストール関連-----
bundle-install:
	$(COMPOSE) run --rm $(SERVICE) bundle install

