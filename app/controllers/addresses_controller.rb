class AddressesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_address, only: [ :edit, :update, :destroy ]

  # Requirement 3.1.5 - Save address details
  def index
    @addresses = current_user.addresses
  end

  def new
    @address = current_user.addresses.build
  end

  def create
    @address = current_user.addresses.build(address_params)

    if @address.save
      redirect_to addresses_path, notice: "Address added successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @address.update(address_params)
      redirect_to addresses_path, notice: "Address updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @address.orders.any?
      redirect_to addresses_path, alert: "Cannot delete address with existing orders."
    else
      @address.destroy
      redirect_to addresses_path, notice: "Address deleted successfully."
    end
  end

  private

  def set_address
    @address = current_user.addresses.find(params[:id])
  end

  def address_params
    params.require(:address).permit(:street_address, :city, :province, :postal_code, :is_default)
  end
end
