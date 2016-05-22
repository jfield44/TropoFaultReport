json.array!(@items) do |item|
  json.extract! item, :id, :item_type, :item_identifier, :item_latitude, :item_longitude, :item_location, :item_repair_time
  json.url item_url(item, format: :json)
end
