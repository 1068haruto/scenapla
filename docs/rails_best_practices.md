# Railsベストプラクティス準拠度レポート

> 調査日: 2026-06-09  
> Railsバージョン: 7.2.1.1  
> Rubyバージョン: 3.2.3

---

## 総合スコア: 83%

---

## カテゴリ別スコア

| カテゴリ | 準拠度 | 評価 |
|----------|--------|------|
| ディレクトリ構造 | 95% | ✅ 優秀 |
| Gemfile・gem選定 | 80% | 🟡 良好 |
| データベース設計 | 95% | ✅ 優秀 |
| モデル | 90% | ✅ 優秀 |
| コントローラ | 85% | ✅ 良好 |
| ルーティング | 95% | ✅ 優秀 |
| テスト | 85% | ✅ 良好 |
| 設定管理 | 90% | ✅ 優秀 |
| コードスタイル (Rubocop) | 80% | 🟡 良好 |
| セキュリティ | 85% | ✅ 良好 |
| バックグラウンドジョブ | 20% | 🔴 要改善 |
| サービス・コンサーン | 90% | ✅ 優秀 |
| I18n | 75% | 🟡 改善余地あり |
| アセットパイプライン | 95% | ✅ 優秀 |

---

## カテゴリ別詳細

### 1. ディレクトリ構造 — 95%

Railsの標準構成に則っており、責務ごとのディレクトリが適切に分離されている。

- `app/models/concerns` — 共有ロジックの抽出
- `app/services/` — `api/`, `data_generator/`, `data_updater/` のサブディレクトリ構成
- `app/view_models/` — プレゼンテーションロジックの分離
- `app/jobs/` — ActiveJob 基底クラスあり
- `spec/` — RSpec 構成 (models, requests, factories, services)

### 2. Gemfile・gem選定 — 80%

**優れている点:**

- Devise 4.9 + OmniAuth (Google OAuth2) による認証
- RSpec 7.1 + FactoryBot 6.4 + Shoulda Matchers 6.5 のテストスタック
- rubocop-rails-omakase によるコードスタイル統一
- Brakeman 7.1 によるセキュリティ静的解析
- Turbo Rails 2.0 + Stimulus Rails 1.3 (Hotwire スタック)
- Chartkick 5.1 + groupdate 6.5 による可視化

**不足している点:**

- 認可 gem (Pundit / CanCanCan) なし
- バックグラウンドジョブ処理 gem (Sidekiq / Delayed Job) なし
- レートリミット gem なし

### 3. データベース設計 — 95%

- `schema.rb` が最新の状態に維持されている
- 全リレーションに外部キー制約を設定
- 金額フィールドに CHECK 制約 (`amount >= 0` など)
- JSONB カラムの適切な活用
- 金融データに `decimal` 型を使用し精度を確保
- マイグレーション名が `YYYYMMDDHHMMSS` 形式に準拠

### 4. モデル — 90%

**バリデーション:** 各モデルに適切なバリデーションが実装されている。

- `User` — email・name の presence、パスワード強度の正規表現チェック
- `Income`, `Expense`, `UserAsset`, `LifeEvent` — presence + numericality (>= 0)

**アソシエーション:** `has_many` / `belongs_to` が双方向かつ `dependent: :destroy` 付きで定義。

**コールバック:**

- `User#after_create` でシミュレーション・シナリオを自動初期化

**コンサーン:**

- `AgeCalculatable` — 年齢計算ロジックの再利用
- `ApplicationEnums` — enum 定義の一元管理

**改善余地:**

- 共通クエリ用の named scope がほぼ未実装

### 5. コントローラ — 85%

- `AfterBaseController` に `before_action :authenticate_user!` を集約
- Strong Parameters を全コントローラで実装
- ビジネスロジックをサービスオブジェクトに委譲し、コントローラを薄く保つ
- `render_error` ヘルパーによるエラーハンドリングの統一

### 6. ルーティング — 95%

- RESTful なリソースベース設計
- 必要なアクションのみを `only:` で明示
- Devise のカスタムコントローラを適切に設定
- PWA 用ルート (service_worker, manifest) の設定
- `/up` ヘルスチェックエンドポイント

### 7. テスト — 85%

- 33本のスペックファイル (models: 13本、requests: 10本、services・concerns・lib)
- FactoryBot ファクトリが全主要モデルに整備
- Shoulda Matchers によるアソシエーション・バリデーションの簡潔なテスト
- Devise テストヘルパーをリクエストスペックに組み込み

**改善余地:**

- Capybara を使ったシステム/フィーチャースペックの不足
- CI/CD パイプラインの設定が確認できない
- テストカバレッジ計測 (SimpleCov など) なし

### 8. 設定管理 — 90%

- 環境別設定ファイル (development / test / production) が適切に分離
- Rails credentials によるシークレット管理 (`credentials.dig` パターン)
- 本番環境で `force_ssl` 有効
- `filter_parameter_logging` で機密パラメータをマスク
- `ENV.fetch` でデフォルト値付きの環境変数参照

### 9. コードスタイル — 80%

- `.rubocop.yml` で `rubocop-rails-omakase` を継承
- `.rubocop_todo.yml` で既存の違反を段階的に修正中
- rubocop-performance 1.22 によるパフォーマンス指摘の自動化

### 10. セキュリティ — 85%

- Devise による安全な認証 (bcrypt ハッシュ化、メール確認、パスワードリセット)
- omniauth-rails_csrf_protection で OmniAuth の CSRF 対策
- Brakeman による脆弱性の静的解析
- 本番環境での強制 SSL
- `allow_browser versions: :modern` による古いブラウザの排除

**改善余地:**

- 認可 gem (Pundit 推奨) による明示的なポリシー定義
- CSP・Permissions Policy が初期化ファイルにあるがコメントアウト中
- レートリミットなし
- 2要素認証なし
- 監査ログなし

### 11. バックグラウンドジョブ — 20% 🔴

`ApplicationJob` クラスは存在するが、ジョブキュー処理の gem が未導入。

以下の処理が同期実行されており、タイムアウトやレスポンス遅延のリスクがある:

- OpenAI API 呼び出し (`Api::OpenaiService`)
- GNews API 呼び出し (`Api::GNewsService`)
- メール送信 (Devise のパスワードリセット等)

**推奨対応:** Sidekiq + Redis を導入し、API 呼び出しを非同期化する。

### 12. サービス・コンサーン・ビューモデル — 90%

**サービスオブジェクト:**

- `DataGenerator::*` — シミュレーションデータ生成 (6クラス)
- `DataUpdater::*` — データ更新のオーケストレーション (4クラス)
- `Api::OpenaiService` — AI アドバイス生成
- `Api::GNewsService` — ニュース取得 (HTTP クライアント抽象化・キャッシュ)
- `Formatter` — BigDecimal フォーマット、チャートデータ変換

**ビューモデル:** `ActiveModel::Naming` / `ActiveModel::Conversion` を実装し、遅延ロードと値のキャッシュを適切に使用。

### 13. I18n — 75%

- デフォルトロケール `:ja` を `config/application.rb` で設定
- `devise.ja.yml` + `ja.yml` による日本語ロケール
- コントローラで `t()` ヘルパーを使用

**改善余地:**

- 英語フォールバックロケールなし
- ビューにハードコードされた日本語テキストが一部存在
- `ja.yml` のカバレッジが限定的 (81行)

### 14. アセットパイプライン — 95%

- ESBuild (jsbundling-rails) による高速な JavaScript バンドル
- Sass + PostCSS + Autoprefixer による CSS ビルド
- Bootstrap 5.3.3 + Chartkick + Chart.js
- Turbo + Stimulus (Hotwire スタック) によるモダンなフロントエンド
- PWA サポート (Service Worker・マニフェスト)

---

## 主な強み

1. **モダンスタック** — Rails 7.2 + Hotwire (Turbo/Stimulus) の最新構成
2. **サービス層の充実** — データ生成・更新・API呼び出しが明確に分離
3. **認証の堅牢性** — Devise + OmniAuth (Google OAuth2)
4. **DB設計の品質** — 外部キー制約・CHECK制約・適切な型選定
5. **テスト基盤** — RSpec + FactoryBot + Shoulda Matchers の整備
6. **ビューモデル** — プレゼンテーションロジックのコントローラ・ビューからの分離

---

## 優先改善事項

| 優先度 | 対応内容 | 推奨 gem |
|--------|----------|----------|
| 🔴 高 | バックグラウンドジョブ処理の導入 | Sidekiq + Redis |
| 🔴 高 | 認可 gem の導入 | Pundit |
| 🟡 中 | CI/CD パイプラインの構築 | GitHub Actions |
| 🟡 中 | CSP・Permissions Policy の有効化 | (設定済みのため有効化のみ) |
| 🟡 中 | システム/フィーチャースペックの追加 | Capybara |
| 🟡 中 | テストカバレッジ計測の導入 | SimpleCov |
| 🟢 低 | モデルのスコープ追加 | — |
| 🟢 低 | I18n カバレッジの拡充 | — |
| 🟢 低 | レートリミットの実装 | rack-attack |
| 🟢 低 | 監査ログの実装 | paper_trail |
