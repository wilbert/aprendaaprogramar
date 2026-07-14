# frozen_string_literal: true

Rails.application.routes.draw do
  # Health check for load balancers / uptime monitors.
  get "up" => "rails/health#show", as: :rails_health_check

  # Localized entry points. The engine builds internal links as
  # "/<locale>/index.rb?Chapter=NN"; `format: false` stops Rails from treating
  # the ".rb" suffix as a response format.
  %w[pt en].each do |loc|
    get loc, to: "learn#index", defaults: { locale: loc }, as: :"#{loc}_root"
    get "#{loc}/index.rb", to: "learn#index", defaults: { locale: loc },
                           as: :"#{loc}_index", format: false
  end

  # Default + legacy paths redirect to the Portuguese version (preserving any query).
  root to: redirect("/pt")
  get "index.rb", format: false, to: redirect { |_params, req|
    req.query_string.empty? ? "/pt/index.rb" : "/pt/index.rb?#{req.query_string}"
  }
end
