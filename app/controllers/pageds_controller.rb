class PagedsController < ApplicationController
  before_action :set_paged, only: [:show, :edit, :update, :destroy]

  # GET /pageds
  # GET /pageds.json
  def index
    @pageds = Paged.all
  end

  # GET /pageds/1
  # GET /pageds/1.json
  def show
    @ordered, @error = @paged.order_pages()
    if @error
      flash.now[:error] = "ERROR Ordering Items : #{@error}"
    end
  end

  # GET /pageds/new
  def new
    @paged = Paged.new
  end

  # GET /pageds/1/edit
  def edit
  end

  # POST /pageds
  # POST /pageds.json
  def create
    @paged = Paged.new(paged_params)

    respond_to do |format|
      if @paged.save
        format.html { redirect_to @paged, notice: 'Paged was successfully created.' }
        format.json { render action: 'show', status: :created, location: @paged }
      else
        format.html { render action: 'new' }
        format.json { render json: @paged.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pageds/1
  # PATCH/PUT /pageds/1.json
  def update
    respond_to do |format|
      if @paged.update(paged_params)
        format.html { redirect_to @paged, notice: 'Paged was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @paged.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pageds/1
  # DELETE /pageds/1.json
  def destroy
    @paged.destroy
    respond_to do |format|
      format.html { redirect_to pageds_url }
      format.json { head :no_content }
    end
  end

  def reorder
    unless params[:reorder_submission].nil? || params[:reorder_submission].blank?
      page_ids = params[:reorder_submission].to_s.split(',')
      page_ids ||= []
      pages = []
      page_ids.each do |page_id|
        pages << Page.find(page_id)
      end
      pages.each_with_index do |page, index|
        page.logical_number = (index + 1).to_s
      end

      previous_page = nil
      pages.each do |page|
        page.prev_page = previous_page
        previous_page = page.id
      end
      next_page = nil
      pages.reverse_each do |page|
        page.next_page = next_page
        next_page = page.id
      end

      page_errors = ""
      pages.each do |page|
        if !page.save(unchecked: 1)
          page_errors += "#{page.logical_number}. #{page.id} save error: #{page.errors.messages.to_s} | "
        end
      end
      flash[:notice] = page_errors unless page_errors.blank?
    else
      flash[:notice] = "No changes to the page order were submitted."
    end
    redirect_to action: :show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_paged
      @paged = Paged.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def paged_params
      params.require(:paged).permit(:title, :creator, :type, :xml_file)
    end

    def reorder_params
      params.permit(:reorder_submission)
    end
end
