require 'open-uri'
require 'json'
require "net/http"
require "uri"

voice_option = "daniel"

wait 1000
say "Welcome to the Tropo Fault Reporting System", {:voice => voice_option}
wait 750
reported_faulty_item = ask "Please enter the 4 digit reference number of the Faulty Item", {
 :choices => "[4 DIGITS]",
 :mode => "dtmf",
 :voice => voice_option}

#Retrieve the list of Faulty Items from the Server 
uri = ('YOUR_TROPO_FAULT_REPORT_SERVER/item_by_identifier/' + reported_faulty_item.value + '.json')
response = open(uri).read
faulty_item = JSON.parse(response)
fault_options = {}

say "Okay great, you are reporting a problem with the " + faulty_item['item_type'] + " located at " + faulty_item['item_location'], {:voice => voice_option}

#Populate the list of faults based on whether the issue with with a Street Light or a Bin
if faulty_item['item_type'] == "Street Light"
	fault_options = {"1" => "Light is Not Working", "2" => "Light is Flickering", "3" => "Light has been Vandalised"}
elsif faulty_item['item_type'] == "Bin"
	fault_options = {"1" => "Bin is Full", "2" => "Bin is on Fire", "3" => "Bin has been Vandalised"}
end

question = "Please select the fault with the #{faulty_item['item_type']}. "

fault_options.each do |key, value|
	question = question + "Press #{key} if the #{value}. "
end

wait 750
type_of_fault = ask question, {
 :choices => "[1 DIGIT]",
 :mode => "dtmf",
 :voice => voice_option}

uri = URI.parse("YOUR_TROPO_FAULT_REPORT_SERVER/faults/")

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true if uri.scheme == 'https'

request = Net::HTTP::Post.new(uri.request_uri)
params = {"fault_type" => fault_options[type_of_fault.value], "fault_description" => "NA", "fault_reported_by" => $currentCall.callerID, "item_id" => faulty_item['id']}
json_headers = {"Content-Type" => "application/json",
                "Accept" => "application/json"}

response = http.post(uri.path, params.to_json, json_headers)

#Voice Confirmation
say "Thank you for reporting the #{faulty_item['item_type']} at #{faulty_item['item_location']}. You can expect the issue to be resolved within #{faulty_item['item_repair_time']}", {:voice => voice_option}
#SMS Confirmation

wait 350
say "Goodbye for now", {:voice => voice_option}

hangup

call $currentCall.callerID, {:network => "SMS"}
say "Thank you for reporting the #{faulty_item['item_type']} at #{faulty_item['item_location']}. You can expect the issue to be resolved within #{faulty_item['item_repair_time']}"