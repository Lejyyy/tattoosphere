Geocoder.configure(
  language: :fr,
  units: :km,
  timeout: 10,
  lookup: :nominatim,
  http_headers: {
    "User-Agent" => "Tattoosphere/1.0 (contact@tattoosphere.com)",
    "Accept-Language" => "fr"
  }
)
