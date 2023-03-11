class SleepRecordsController < ApplicationController
  before_action :set_sleep_record, only: %i[show]

  def show
    render json: @sleep_record
  end

  def create
    @sleep_record = SleepRecord.new(sleep_record_params.merge(clocked_in_at: Time.current))

    if @sleep_record.save
      render json: @sleep_record, status: :created, location: @sleep_record
    else
      render json: @sleep_record.errors, status: :unprocessable_entity
    end
  end

  private

  def set_sleep_record
    @sleep_record = SleepRecord.find(params[:id])
  end

  def sleep_record_params
    params.require(:sleep_record).permit(:user_id)
  end
end
