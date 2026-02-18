Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "analyze", to: "analysis#parse"
end
