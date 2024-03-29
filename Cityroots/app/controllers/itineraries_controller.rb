class ItinerariesController < ApplicationController
  
  before_action :set_itinerary, only: [:show, :edit, :update, :destroy]

  before_filter do
    resource = controller_path.singularize.gsub('/', '_').to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end
  
  load_and_authorize_resource

  # GET /itineraries
  # GET /itineraries.json
  def index
     if (!params[:search].nil?)
      if (current_user.role? (:admin))
        @itineraries = Itinerary.where("LOWER(name) LIKE LOWER(?)", "%#{params[:search]}%").page(params[:page]).per(10)
      else
        @itineraries = Itinerary.where("user_id=? and LOWER(name) LIKE LOWER(?)",current_user.id, "%#{params[:search]}%").page(params[:page]).per(10)
      end
    else
      if (current_user.role? (:admin))
        @itineraries=Itinerary.all.page(params[:page]).per(10)
      else
        @itineraries = current_user.itineraries.page(params[:page]).per(10) if  current_user
      end
    end
    respond_to do |format|
      format.html{ @itineraries }
      format.json{render :json =>  Itinerary.page(params[:page]).per(25).as_json( :include => {
          :itinerary_attractions=>{:include=>{:attraction=>{:include=>{:attraction_translations=>{:include=>:language},:city=>{:include=>:country},:photo_attractions=>{},:types=>{},:comment_attractions=>{:include=>:mobile_user}}}}},
          :itinerary_events=>{:include=>{:event=>{:include=>{:event_translations=>{:include=>:language},:city=>{:include=>:country},:photo_events=>{},:types=>{},:comment_events=>{:include=>:mobile_user}}}}},
          :itinerary_services=>{:include=>{:service=>{:include=>{:service_translations=>{:include=>:language},:city=>{:include=>:country},:photo_services=>{},:types=>{},:comment_services=>{:include=>:mobile_user}}}}},
          :comment_itineraries=>{:include=>{:mobile_user=>{}}},
          :rating_itineraries=>{:include=>{:mobile_user=>{}}}
      }) }
    end
  end

  # GET /itineraries/1
  # GET /itineraries/1.json
  def show

  end
  def autocomplete_itinerary_name
     if (!current_user.nil?) && (current_user.role? (:admin))
      itineraries = Itinerary.select([:name]).where("name LIKE ?", "#{params[:name]}%")
    else
      itineraries = Itinerary.select([:name]).where("user_id=? and name LIKE ?", current_user.id, "#{params[:name]}%")
    end
    result = itineraries.collect do |t|
      { value: t.name }
    end
    render json: result
  end

  # GET /itineraries/new
  def new
    @itinerary = Itinerary.new
  end

  # GET /itineraries/1/edit
  def edit
  end

  # POST /itineraries
  # POST /itineraries.json
  def create
    @itinerary = Itinerary.new(itinerary_params)


    respond_to do |format|
      if @itinerary.save
        format.html { redirect_to @itinerary, notice: 'Rota criada com sucesso.' }
        format.json { render action: 'show', status: :created, location: @itinerary }
      else
        format.html { render action: 'new' }
        format.json { render json: @itinerary.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /itineraries/1
  # PATCH/PUT /itineraries/1.json
  def update
    respond_to do |format|
      if @itinerary.update(itinerary_params)
        format.html { redirect_to @itinerary, notice: 'Rota actualizada com sucesso.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @itinerary.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /itineraries/1
  # DELETE /itineraries/1.json
  def destroy
    @itinerary.destroy
    respond_to do |format|
      format.html { redirect_to itineraries_url }
      format.json { head :no_content }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_itinerary
      @itinerary = Itinerary.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def itinerary_params
      params.require(:itinerary).permit(
          :name,
          :description,
          :user_id,
          :itinerary_type_id,
          itinerary_attractions_attributes:[
              :id,
              :order,
              :itinerary_id,
              :attraction_id,
              :_destroy
          ],
          itinerary_events_attributes:[
              :id,
              :order,
              :itinerary_id,
              :event_id,
              :_destroy
          ],
          itinerary_services_attributes:[
              :id,
              :order,
              :itinerary_id,
              :service_id,
              :_destroy
          ]
      )
    end
end
