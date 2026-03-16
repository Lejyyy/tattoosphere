
class Admin::TattooStylesController < Admin::BaseController
  def index
    @styles    = TattooStyle.order(:name)
    @new_style = TattooStyle.new
  end

  def create
    @style = TattooStyle.new(style_params)
    if @style.save
      log_action("create_style", @style)
      redirect_to admin_tattoo_styles_path, notice: "Style créé."
    else
      @styles    = TattooStyle.order(:name)
      @new_style = @style
      render :index, status: :unprocessable_entity
    end
  end

  def update
    @style = TattooStyle.find(params[:id])
    @style.update(style_params)
    redirect_to admin_tattoo_styles_path, notice: "Style mis à jour."
  end

  def destroy
    TattooStyle.find(params[:id]).destroy
    redirect_to admin_tattoo_styles_path, notice: "Style supprimé."
  end

  private
  def style_params = params.require(:tattoo_style).permit(:name)
end
