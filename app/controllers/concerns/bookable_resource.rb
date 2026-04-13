module BookableResource
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :set_resource, only: [ :show, :availability ]
    before_action :validate_date_param, only: [ :show, :availability ]
  end

  def show
    @date = @validated_date
    service = ResourceAvailabilityService.new(@resource)
    @slots = service.available_slots(@date, current_user: current_user)
  end

  # JSON endpoint for AJAX availability refresh and lock acquisition
  def availability
    date = @validated_date

    if params[:start_slot].present? && params[:end_slot].present?
      start_slot = params[:start_slot].to_i
      end_slot = params[:end_slot].to_i
      # superclass resources validate method
      validation_errors = @resource.validate_slot_range(start_slot, end_slot)

      if validation_errors.any?
        render json: { error: validation_errors.join(", ") }, status: :unprocessable_entity
        return
      end

      unless @resource.can_book_date?(date)
        render json: { error: "Cannot book this date" }, status: :unprocessable_entity
        return
      end

      # Block booking past time slots for today (HKT = UTC+8)
      hk_now = Time.now.utc + 8.hours
      if date == hk_now.to_date
        current_slot = hk_now.hour * 2 + (hk_now.min >= 30 ? 1 : 0)
        if start_slot < current_slot
          render json: { error: "Cannot book time slots that have already passed." }, status: :unprocessable_entity
          return
        end
      end

      lock_token = BookingLockService.acquire_lock(
        user: current_user,
        resource: @resource,
        date: date,
        start_slot: start_slot,
        end_slot: end_slot
      )

      if lock_token
        render json: { lock_token: lock_token }
      else
        render json: { error: "Slots are no longer available." }, status: :conflict
      end
      return
    end

    service = ResourceAvailabilityService.new(@resource)
    slots = service.available_slots(date, current_user: current_user)
    render json: { slots: slots, date: date.to_s }
  end

  private

  def validate_date_param
    date_str = params[:date].presence

    if date_str.nil?
      @validated_date = Date.current
      return
    end

    begin
      date = Date.parse(date_str)
    rescue Date::Error
      flash[:alert] = "Invalid date format"
      redirect_to polymorphic_path(@resource) and return
    end

    unless @resource.can_book_date?(date)
      flash[:alert] = "Cannot book this date"
      redirect_to polymorphic_path(@resource) and return
    end

    @validated_date = date
  end
end
