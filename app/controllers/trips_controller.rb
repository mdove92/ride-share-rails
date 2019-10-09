class TripsController < ApplicationController
  def index
    @trips = Trip.all.order(:id)
  end

  def show
    trip_id = params[:id].to_i
    @trip = Trip.find_by(id:trip_id)
    if @trip.nil?
      redirect_to trips_path
      return
    end
  end

end
