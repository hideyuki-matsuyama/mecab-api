# ヘルスチェックにバージョン番号を付与するためオーバーライド
class Rails::HealthController < ActionController::API
  def show
    render json: { version: ENV["APP_REVISION"].presence || "development" }
  end
end
