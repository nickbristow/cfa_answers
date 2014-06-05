class CategoriesController < ApplicationController
  add_breadcrumb "Home", :root_url
  def index
  	@bodyclass = "results"

    @categories = Category.by_access_count
    add_breadcrumb "Categories"
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @categories }
    end
  end
  def show
  	return render(:template => 'categories/missing') unless Category.exists? params[:id]

    @category = Category.find(params[:id])
    add_breadcrumb @category.name
    # redirection of old permalinks
    if request.path != category_path( @category )
      logger.info "Old permalink: #{request.path}"
      return redirect_to @category, status: :moved_permanently
    end

    @category.delay.increment! :access_count

    @content_html = BlueCloth.new(@category.name).to_html
    @bodyclass = "results"

    respond_to do |format|
      format.html
      format.json { render json: @category }
    end
  end

  def missing
    render :layout => 'missing'
  end
end
