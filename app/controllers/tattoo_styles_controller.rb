class TattooStylesController < ApplicationController
 skip_before_action :authenticate_user!, only: [ :index ]

  def index
    @tattoo_styles = TattooStyle.all
  end
end
