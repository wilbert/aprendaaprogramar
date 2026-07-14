# frozen_string_literal: true

Rails.application.routes.draw do
  # The tutorial engine builds internal links as "/index.rb?Chapter=NN", so keep
  # that legacy path working alongside the root. `format: false` stops Rails from
  # treating the ".rb" suffix as a response format.
  root "learn#index"
  get "index.rb", to: "learn#index", as: :legacy_index, format: false

  # Health check for load balancers / uptime monitors.
  get "up" => "rails/health#show", as: :rails_health_check
end
