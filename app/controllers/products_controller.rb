class ProductsController < ApplicationController
  def index
    search = params[:search]
    if search
      @products = Product.where("LOWER(name) LIKE ?", "%#{search.downcase}%")
                # Product.where("LOWER(name) LIKE LOWER(?)", "%#{params[:search]}%")
      # SELECT * FROM products WHERE LOWER(name) LIKE '%streamed%'

      # case insensitive search, ILIKE is not supported on SQLite
      # @products = Produce.where("name ILIKE ?", "&#{search}%")
    else
      @products = Product.all
    end

    @products = @products.order('products.created_at DESC').page(params[:page])

    respond_to do |format|
      format.html do
      # if this request is an AJAX request (XMLHttpRequest)
        if request.xhr?
           render @products  # render _product partial for each product
           # render partial: "product", collection: @products    # equivalent to above line
        else
          render :index
        end
      end

      format.js do |format|

      end

      format.json { render json: @products.as_json }

    end
  end

  def show
    @product = Product.find(params[:id])

    if current_user
      @review = @product.reviews.build
    end
  end

  def new
    @product = Product.new
  end

  def edit
    @product = Product.find(params[:id])
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to products_url
      # render :create # render create.js.erb  # window.location.replace("http://stackoverflow.com");
      # respond_to do |format|
      #   format.js
      # end
    else
      render :new
    end
  end

  def update
    @product = Product.find(params[:id])
    if @product.update_attributes(product_params)
      redirect_to product_path(@product)
    else
      render :edit
    end
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to products_path
  end

  private
  def product_params
    params.require(:product).permit(:name, :description, :price_in_cents)
  end
end

