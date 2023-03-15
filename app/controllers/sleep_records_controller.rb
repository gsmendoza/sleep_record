class SleepRecordsController < ApplicationController
  before_action :set_sleep_record, only: %i[show clock_out]
  before_action :set_user, only: %i[friend]

  def index
    @sleep_records = SleepRecord.order(:created_at).page(params[:page]).per(params[:per])

    render json: @sleep_records
  end

  # Sleep records of user's friends
  def friend
    @sleep_records =
      SleepRecord.completed
        .where(user: @user.friends)
        .where("clocked_out_at >= :clocked_out_at", clocked_out_at: 1.week.ago)
        .order(:duration)
        .page(params[:page])
        .per(params[:per])

    render json: @sleep_records
  end

  def show
    render json: @sleep_record
  end

  def create
    @sleep_record = SleepRecord.new_clock_in(sleep_record_params)

    if @sleep_record.save
      render json: @sleep_record, status: :created, location: @sleep_record
    else
      render json: @sleep_record.errors, status: :unprocessable_entity
    end
  end

  def clock_out
    if @sleep_record.clock_out
      render json: @sleep_record
    else
      render json: @sleep_record.errors, status: :unprocessable_entity
    end
  end

  private

  def set_sleep_record
    @sleep_record = SleepRecord.find(params[:id])
  end

  def set_user
    @user = User.find(params[:user_id])
  end

  def sleep_record_params
    params.require(:sleep_record).permit(:user_id)
  end
end
