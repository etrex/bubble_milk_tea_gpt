class ItemsController < ApplicationController
  before_action :debug_info
  before_action :set_order
  before_action :set_item, only: [:destroy]

  # GET /items
  # GET /items.json
  def index
    @items = @order.items
  end

  # GET /items/new
  def new
    @item = Item.new
  end

  # POST /items
  # POST /items.json
  def create
    @item = Item.new(item_params)
    @item.order = current_user.current_order

    respond_to do |format|
      if @item.save
        @items = @order.items
        format.html { redirect_to @item, notice: 'Item was successfully created.' }
        format.json { render :show, status: :created, location: @item }
        format.line { render :index }
      else
        format.html { render :new }
        format.json { render json: @item.errors, status: :unprocessable_entity }
        format.line { render json: flex_text(@item.errors.to_s) }
      end
    end
  end

  def finish
    @order.finish!
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully finished.' }
      format.json { head :no_content }
      format.line { render json: {
        type: "text",
        text: "訂單已完成"
      } }
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item.destroy
    @items = @order.items
    respond_to do |format|
      format.html { redirect_to items_url, notice: 'Item was successfully destroyed.' }
      format.json { head :no_content }
      format.line { render :index }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = current_user.current_order
    end

    def set_item
      @item = Item.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_params
      params.require(:item).permit(:name, :size, :suger, :ice, :quantity)
    end

    def debug_info
      puts ""
      puts "=== kamigo debug info start ==="
      puts "platform_type: #{params[:platform_type]}"
      puts "source_type: #{params[:source_type]}"
      puts "source_group_id: #{params[:source_group_id]}"
      puts "source_user_id: #{params[:source_user_id]}"
      puts "=== kamigo debug info end ==="
      puts ""
    end
end
