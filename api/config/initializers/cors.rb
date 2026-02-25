allowed_origins = ENV.fetch("CORS_ALLOWED_ORIGINS", "http://localhost:3000,http://127.0.0.1:3000")
                     .split(",")
                     .map(&:strip)
                     .reject(&:empty?)

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*allowed_origins)

    resource "*",
      headers: %w[Authorization Content-Type Accept Origin],
      methods: %i[get options head],
      expose: %w[Authorization],
      max_age: 600
  end
end
