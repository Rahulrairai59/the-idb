class InventoriesController < ApplicationController
  autocomplete :inventory, :name, :full => true
  autocomplete :inventory, :place, :full => true
  autocomplete :inventory, :category, :full => true
  autocomplete :inventory, :seller, :full => true

  def index
    @inventories = Inventory.all #joins(:location).order(:inventory_number)
    locations = Hash.new()
    Location.all.each do |l|
      lpath = l.self_and_ancestors.to_a.reverse.each
      names = Array.new()
      lpath.each do |item|
        names.push(item.name)
      end
      locations[l.id] = names.join(" → ").html_safe
    end
    @locations = locations
  end

  def show
    @inventory = Inventory.find(params[:id])
  end

  def new
    @inventory = Inventory.new
    @form_locations = Location.depth_traverse
    @all_locations = Location.order(:name)
    @form_status = InventoryStatus.order(name: :asc)
  end

  def create
    if params[:inventory]["purchase_date(1i)"]
      p_date = params[:inventory]["purchase_date(1i)"] + "-" + leading_zero_on_single_digits(params[:inventory]["purchase_date(2i)"]) + "-" + leading_zero_on_single_digits(params[:inventory]["purchase_date(3i)"])
      params[:inventory][:purchase_date] = p_date
      params[:inventory].delete("purchase_date(1i)")
      params[:inventory].delete("purchase_date(2i)")
      params[:inventory].delete("purchase_date(3i)")
    end

    if params[:inventory]["warranty_end(1i)"]
      w_date = params[:inventory]["warranty_end(1i)"] + "-" + leading_zero_on_single_digits(params[:inventory]["warranty_end(2i)"]) + "-" + leading_zero_on_single_digits(params[:inventory]["warranty_end(3i)"])
      params[:inventory][:warranty_end] = w_date
      params[:inventory].delete("warranty_end(1i)")
      params[:inventory].delete("warranty_end(2i)")
      params[:inventory].delete("warranty_end(3i)")
    end

    if params[:inventory]["install_date(1i)"]
      w_date = params[:inventory]["install_date(1i)"] + "-" + leading_zero_on_single_digits(params[:inventory]["install_date(2i)"]) + "-" + leading_zero_on_single_digits(params[:inventory]["install_date(3i)"])
      params[:inventory][:install_date] = w_date
      params[:inventory].delete("install_date(1i)")
      params[:inventory].delete("install_date(2i)")
      params[:inventory].delete("install_date(3i)")
    end

    @inventory = Inventory.new(params.require(:inventory).permit(:inventory_number, :name, :serial, :part_number, :seller, :inventory_status_id, :user_id, :owner_id, :machine_id, :comment, :location_id, :place, :category, :warranty_end, :purchase_date, :install_date))
    @form_locations = Location.depth_traverse

    if @inventory.save
      add_attachments(params[:attachments])
      trigger_version_change(@inventory, current_user.display_name)
      redirect_to inventories_path
    else
      render :new
    end
  end

  def edit
    @inventory = Inventory.find(params[:id])
    @form_locations = Location.depth_traverse
    @all_locations = Location.order(:name)
    @form_status = InventoryStatus.order(name: :asc)
  end

  def update
    @inventory = Inventory.find(params[:id])
    @form_locations = Location.depth_traverse

    if @inventory.update(inventory_params)
      add_attachments(params[:attachments])
      trigger_version_change(@inventory, current_user.display_name)
      redirect_to inventory_path(@inventory), notice: 'Inventory updated!'
    else
      render :edit
    end
  end

  def autocomplete_inventory_name
    autocomplete_general("name", params[:term])
  end

  def autocomplete_inventory_place
    autocomplete_general("place", params[:term])
  end

  def autocomplete_inventory_category
    autocomplete_general("category", params[:term])
  end

  def autocomplete_inventory_seller
    autocomplete_general("seller", params[:term])
  end

  private

  def autocomplete_general(attrib, term)
    render json: Inventory.where("#{attrib} like '%#{term}%'").pluck("distinct #{attrib}")
  end

  def leading_zero_on_single_digits(number)
    number.length > 1 ? number : "0#{number}"
  end

  def inventory_params
    params.require(:inventory).permit(:inventory_number, :name, :serial, :part_number, :seller, :inventory_status_id, :user_id, :owner_id, :machine_id, :comment, :location_id, :place, :category, :warranty_end, :purchase_date, :install_date, :attachments)
  end

  def add_attachments(attachments)
    if attachments
      attachments.each { |attachment|
        @inventory.attachments.create(attachment: attachment)
      }
    end
  end
end
