# README

## Getting Started

### 必要なもの

- Docker
- Docker Compose

### セットアップ手順

1. リポジトリをクローン
2. Docker Composeで起動

```bash
docker compose build
docker compose run bin/api rails db:drop db:create db:migrate db:seed
docker compose up
```

open <http://localhost:3000>

