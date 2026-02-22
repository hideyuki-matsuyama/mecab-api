Rails.application.configure do
  config.cache_store = :redis_cache_store, {
    url: "redis://localhost:6379/0",
    namespace: "mecab_api_cache"
  }
end
