class JistsController < ApplicationController

  def index
    @jists = Jist.all
  end

  def show
    @jist = Jist.find(params[:id])
    @commit = params[:sha] ? params[:sha] : @jist.head.id
  end

  def new
    @jist = Jist.new
  end

  def create
    @jist = Jist.new(params[:jist])
    
    respond_to do |format|
      if @jist.save
        format.html { redirect_to(@jist, :notice => 'Jist was successfully created.') }
      else
        format.html { render :new }
      end
    end
  end

  def edit
    @jist = Jist.find(params[:id])
  end

  def update
    @jist = Jist.find(params[:id])

    respond_to do |format|
      if @jist.update_attributes(params[:jist])
        format.html { redirect_to(@jist, :notice => 'Jist was successfully updated.') }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @jist = Jist.find(params[:id])
  end
end
