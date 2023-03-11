class SleepRecordsController < ApplicationController
  before_action :set_sleep_record, only: %i[ show update destroy ]

  # GET /sleep_records
  def index
    @sleep_records = SleepRecord.all

    render json: @sleep_records
  end

  # GET /sleep_records/1
  def show
    render json: @sleep_record
  end

  # POST /sleep_records
  def create
    @sleep_record = SleepRecord.new(sleep_record_params)

    if @sleep_record.save
      render json: @sleep_record, status: :created, location: @sleep_record
    else
      render json: @sleep_record.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /sleep_records/1
  def update
    if @sleep_record.update(sleep_record_params)
      render json: @sleep_record
    else
      render json: @sleep_record.errors, status: :unprocessable_entity
    end
  end

  # DELETE /sleep_records/1
  def destroy
    @sleep_record.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sleep_record
      @sleep_record = SleepRecord.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def sleep_record_params
      params.require(:sleep_record).permit(:user_id, :clocked_in_at)
    end
end
