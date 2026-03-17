Geocoder.configure(
  language: :fr,
  units: :km,
  distances: :spherical,
  timeout: 5,
  lookup: :nominatim,
  cache: (Rails.env.production? ? Redis.new(url: ENV["REDIS_URL"]) : nil),
  http_headers: {
    "User-Agent" => "Tattoosphere/1.0 (contact@tattoosphere.com)",
    "Accept-Language" => "fr"
  }
)
