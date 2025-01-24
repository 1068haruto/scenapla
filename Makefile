# 定義: Docker Composeを使った便利コマンド集
# Docker Compose内のwebコンテナを使ってコマンドを実行する。

# 定義済み変数
COMPOSE = docker compose
SERVICE = web

# RuboCop関連タスク
rubocop:
	$(COMPOSE) run --rm $(SERVICE) bundle exec rubocop

rubocop-performance:
	$(COMPOSE) run --rm $(SERVICE) bundle exec rubocop -P

rubocop-autocorrect:
	$(COMPOSE) run --rm $(SERVICE) bundle exec rubocop --auto-correct

rubocop-gen-config:
	$(COMPOSE) run --rm $(SERVICE) bundle exec rubocop --auto-gen-config

# その他便利タスク
build:
	$(COMPOSE) build

up:
	$(COMPOSE) up

down:
	$(COMPOSE) down

logs:
	$(COMPOSE) logs -f