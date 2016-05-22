json.array!(@faults) do |fault|
  json.extract! fault, :id, :fault_type, :fault_description, :fault_reported_by, :item_id
  json.url fault_url(fault, format: :json)
end
