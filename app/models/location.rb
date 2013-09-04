class Location < App
  def initialize(customer_id, machine_id)
    @customer_id = customer_id
    @machine_id = machine_id
  end
end