require 'faker'

# db/seeds.rb
puts "🧹 Nettoyage de la base..."
PortfolioStyle.destroy_all
TatoueurStyle.destroy_all
PortfolioItem.destroy_all
Portfolio.destroy_all
Review.destroy_all
Booking.destroy_all
Availability.destroy_all
Event.destroy_all
Social.destroy_all
ShopTatoueur.destroy_all
Tatoueur.destroy_all
Shop.destroy_all
TattooStyle.destroy_all
User.destroy_all

puts "🎨 Création des styles de tatouage..."
styles = TattooStyle.create!([
  { name: "Réalisme" },
  { name: "Japonais" },
  { name: "Géométrique" },
  { name: "Old School" },
  { name: "Blackwork" },
  { name: "Aquarelle" },
  { name: "Tribal" },
  { name: "Minimaliste" }
])

puts "👤 Création des utilisateurs clients..."
users = []
5.times do |i|
  users << User.create!(
    first_name: Faker::Name.first_name,
    last_name:  Faker::Name.last_name,
    nickname:   Faker::Internet.username,
    email:      Faker::Internet.unique.email,
    password:   "password123",
    phone:      Faker::PhoneNumber.phone_number,
    birth_date: Faker::Date.birthday(min_age: 18, max_age: 60),
    role:       "user",
    is_active:  true
  )
end

puts "💉 Création des utilisateurs tatoueurs..."
tatoueur_users = []
4.times do |i|
  tatoueur_users << User.create!(
    first_name: Faker::Name.first_name,
    last_name:  Faker::Name.last_name,
    nickname:   Faker::Internet.username,
    email:      Faker::Internet.unique.email,
    password:   "password123",
    phone:      Faker::PhoneNumber.phone_number,
    birth_date: Faker::Date.birthday(min_age: 20, max_age: 50),
    role:       "tatoueur",
    is_active:  true
  )
end

puts "🏪 Création des utilisateurs shop owners..."
shop_users = []
2.times do |i|
  shop_users << User.create!(
    first_name: Faker::Name.first_name,
    last_name:  Faker::Name.last_name,
    nickname:   Faker::Internet.username,
    email:      Faker::Internet.unique.email,
    password:   "password123",
    phone:      Faker::PhoneNumber.phone_number,
    birth_date: Faker::Date.birthday(min_age: 25, max_age: 55),
    role:       "shop_owner",
    is_active:  true
  )
end

puts "💉 Création des profils tatoueurs..."
tatoueurs = []
tatoueur_users.each do |u|
  t = Tatoueur.create!(
    user:        u,
    nickname:    u.nickname,
    first_name:  u.first_name,
    last_name:   u.last_name,
    email:       u.email,
    description: Faker::Lorem.paragraph(sentence_count: 3),
    is_active:   true
  )
  # Assigner 2 styles aléatoires
  t.tattoo_styles << styles.sample(2)
  tatoueurs << t
end

puts "🏪 Création des shops..."
shops = []
shop_users.each_with_index do |u, i|
  s = Shop.create!(
    user:        u,
    name:        "#{Faker::Company.name} Tattoo",
    email:       Faker::Internet.email,
    address:     Faker::Address.full_address,
    phone:       Faker::PhoneNumber.phone_number,
    description: Faker::Lorem.paragraph(sentence_count: 2),
    open_hours:  "Lun-Sam : 10h00 - 19h00",
    is_active:   true
  )
  # Associer 2 tatoueurs par shop
  s.tatoueurs << tatoueurs.sample(2)
  shops << s
end

puts "📅 Création des disponibilités..."
tatoueurs.each do |t|
  [1, 2, 3, 4, 5].sample(3).each do |day|
    Availability.create!(
      tatoueur:   t,
      day_of_week: day,
      start_time: "09:00",
      end_time:   "18:00"
    )
  end
end

puts "📁 Création des portfolios et réalisations..."
tatoueurs.each do |t|
  2.times do
    portfolio = Portfolio.create!(
      tatoueur:    t,
      name:        Faker::Lorem.words(number: 3).join(" ").capitalize,
      description: Faker::Lorem.paragraph(sentence_count: 2)
    )
    3.times do
      item = PortfolioItem.create!(
        portfolio:   portfolio,
        description: Faker::Lorem.sentence,
        price:       Faker::Commerce.price(range: 80..500.0)
      )
      item.tattoo_styles << t.tattoo_styles.sample(1)
    end
  end
end

puts "📅 Création des réservations..."
bookings = []
users.each do |u|
  shop = shops.sample
  tatoueur = shop.tatoueurs.sample
  next unless tatoueur

  booking = Booking.create!(
    user:            u,
    shop:            shop,
    tatoueur:        tatoueur,
    date:            Faker::Date.between(from: 2.months.ago, to: 1.month.from_now),
    status:          %w[pending confirmed done cancelled].sample,
    description:     Faker::Lorem.sentence,
    price_estimated: Faker::Commerce.price(range: 80..600.0),
    start_time:      "10:00",
    end_time:        "12:00"
  )
  bookings << booking
end

puts "⭐ Création des avis..."
bookings.select { |b| b.status == "done" }.each do |b|
  Review.create!(
    user:     b.user,
    tatoueur: b.tatoueur,
    booking:  b,
    rating:   rand(3..5),
    comment:  Faker::Lorem.paragraph(sentence_count: 2)
  )
end

puts "🎉 Création des événements..."
2.times do
  shop = shops.sample
  Event.create!(
    name:        "#{Faker::Lorem.word.capitalize} Tattoo Convention",
    description: Faker::Lorem.paragraph(sentence_count: 3),
    location:    Faker::Address.city,
    start_date:  Faker::Date.forward(days: rand(10..60)),
    end_date:    Faker::Date.forward(days: rand(61..90)),
    is_public:   true,
    shop:        shop
  )
end

tatoueurs.each do |t|
  Event.create!(
    name:        "Flash Day #{t.nickname}",
    description: Faker::Lorem.paragraph(sentence_count: 2),
    location:    Faker::Address.city,
    start_date:  Faker::Date.forward(days: rand(5..30)),
    end_date:    Faker::Date.forward(days: rand(31..35)),
    is_public:   true,
    tatoueur:    t
  )
end

puts "📱 Création des réseaux sociaux..."
(shops + tatoueurs).each do |entity|
  %w[instagram facebook].each do |platform|
    Social.create!(
      platform:    platform,
      url:         "https://#{platform}.com/#{Faker::Internet.username}",
      shop:        entity.is_a?(Shop) ? entity : nil,
      tatoueur:    entity.is_a?(Tatoueur) ? entity : nil
    )
  end
end

puts "✅ Seeds terminés !"
puts "  👤 #{User.count} utilisateurs"
puts "  💉 #{Tatoueur.count} tatoueurs"
puts "  🏪 #{Shop.count} shops"
puts "  📅 #{Booking.count} réservations"
puts "  ⭐ #{Review.count} avis"
puts "  🎉 #{Event.count} événements"
puts "  📁 #{Portfolio.count} portfolios"
puts "  🖼️  #{PortfolioItem.count} réalisations"