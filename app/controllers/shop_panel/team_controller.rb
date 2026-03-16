class ShopPanel::TeamController < ShopPanel::BaseController
  def index
    @tatoueurs          = current_shop.tatoueurs.includes(:tattoo_styles, avatar_attachment: :blob)
    @available_tatoueurs = Tatoueur.where(is_active: true)
                                    .where.not(id: current_shop.tatoueur_ids)
  end
end
