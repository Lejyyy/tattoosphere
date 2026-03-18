module ApplicationHelper
  def favorite_path_for(favoritable)
    case favoritable
    when Tatoueur
      tatoueur_favorite_path(favoritable)
    when Shop
      shop_favorite_path(favoritable)
    when Portfolio
      tatoueur_portfolio_favorite_path(favoritable.tatoueur, favoritable)
    when PortfolioItem
      tatoueur_portfolio_portfolio_item_favorite_path(
        favoritable.portfolio.tatoueur,
        favoritable.portfolio,
        favoritable
      )
    end
  end
  def style_icon(name)
  {
    "Réalisme"    => "🎨",
    "Japonais"    => "🌸",
    "Géométrique" => "🔷",
    "Old School"  => "⚓",
    "Blackwork"   => "⬛",
    "Aquarelle"   => "💧",
    "Tribal"      => "🌀",
    "Minimaliste" => "✦"
  }[name] || "🖋️"
end
end
