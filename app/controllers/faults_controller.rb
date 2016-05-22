require 'net/http'
require 'net/https'
require 'uri'
require 'open-uri'

class FaultsController < ApplicationController

  before_action :set_fault, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token

  # GET /faults
  # GET /faults.json
  def index
    @faults = Fault.all
  end

  def webhook
    message_id = params[:data][:id]
    sender = params[:data][:personEmail]
    room_id = params[:data][:roomId]

    recieved_message = CiscoSpark::Message.fetch(message_id)
    parsed_message = recieved_message.text
    puts parsed_message

    if parsed_message.match(/^-fault/) || parsed_message.match(/^#fault/) || parsed_message.start_with?("/fault") || parsed_message.start_with?("/Fault")
      request_values = parsed_message.split()
      fault_id = request_values[1]
      fault_status = request_values[2]
      message = ""

      for index in 3 ... request_values.size
        message = message + " " + request_values[index]
        puts "request_values[#{index}] = #{request_values[index]}"
      end

    end

      if fault_status == "resolved" || fault_status == "Resolved"
        Fault.update(fault_id, :fault_status => "Resolved", :resolved_at => Time.now, :case_note => message)
        respond_to_fault_resolution_dynamic(Fault.find(fault_id), room_id)
      end
    render :nothing => true, :status => 200, :content_type => 'text/html'
  end

  # GET /faults/1
  # GET /faults/1.json
  def show
    gon.fault = Fault.find(params[:id])
  end

  # GET /faults/new
  def new
    @fault = Fault.new
  end

  # GET /faults/1/edit
  def edit
  end

  def dispatch_engineering_team
    @fault = Fault.find(params[:id])
    flash[:notice] = "Fault report has been dispatched to the engineering team!"
    created_room = create_room(@fault.id)
    fault_report_webhook = "YOURWEBADDRESS/webhook"
    tropo_spark_webhook = "YOURTROPOSPARKSERVER/webhook"
    create_membership(params[:email], created_room)
    create_membership("TROPO/SPARK_BOT_HERE", created_room)
    post_to_spark_dynamic(@fault, created_room)
    post_file_to_spark_dynamic(created_room, "Street Light Status Report", "https://www.dropbox.com/s/735kx5a2swq7ke3/status.xlsx?dl=1")
    post_file_to_spark_dynamic(created_room, "Street Light Diagnostic Guide","https://www.dropbox.com/s/p22gvcafghsenyz/diagnostictest.pdf?dl=1")
    create_webhook(created_room, fault_report_webhook)
    create_webhook(created_room, tropo_spark_webhook)
    redirect_to fault_path(@fault)
  end

  def post_to_spark_dynamic(fault, room_id)
    fault_report = "Fault Report: #{fault.fault_type} | Fault ID: #{fault.id}\nReported By: #{fault.fault_reported_by} | #{fault.created_at} \nLocation: #{fault.item.item_type} (ID: #{fault.item.item_identifier}) | #{fault.item.item_location} \nGPS: https://www.google.co.uk/maps/@#{fault.item.item_latitude},#{fault.item.item_longitude},19.44z\n\n"
    message = CiscoSpark::Message.create(roomId: room_id, text: fault_report)
  end

  def generic_post_to_spark_dynamic(message, room_id)
    message = CiscoSpark::Message.create(roomId: room_id, text: message)
  end

  def post_file_to_spark_dynamic(room_id, title, url)
    message = CiscoSpark::Message.create(roomId: room_id, text: title, files: [url])
  end

  def respond_to_fault_resolution_dynamic(fault, room_id)
    fault_status = "Fault Updated: ID #{fault.id} | Status Resolved | #{fault.resolved_at}"
    message = CiscoSpark::Message.create(roomId: room_id, text: fault_status)
  end

  #Create a Spark Room that will be used for the Fault Resolution Process
  def create_room(fault_id)
    room = CiscoSpark::Room.create(title: "Fault: #{fault_id}")
    return room.id
  end

  def create_membership(person_email_address, room_id)
    membership = CiscoSpark::Membership.create(roomId: room_id, personEmail: person_email_address)
  end

  def create_webhook(room_id, target_url)
    webhook = CiscoSpark::Webhook.create(name: "Tropo Spark Auto Added Webhook", targetUrl: target_url, resource: "messages", event: "created", filter: "roomId=#{room_id}")
  end

  # POST /faults
  # POST /faults.json
  def create
    @fault = Fault.new(fault_params)

    respond_to do |format|
      if @fault.save
        format.html { redirect_to @fault, notice: 'Fault was successfully created.' }
        format.json { render :show, status: :created, location: @fault }
      else
        format.html { render :new }
        format.json { render json: @fault.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /faults/1
  # PATCH/PUT /faults/1.json
  def update
    respond_to do |format|
      if @fault.update(fault_params)
        format.html { redirect_to @fault, notice: 'Fault was successfully updated.' }
        format.json { render :show, status: :ok, location: @fault }
      else
        format.html { render :edit }
        format.json { render json: @fault.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /faults/1
  # DELETE /faults/1.json
  def destroy
    @fault.destroy
    respond_to do |format|
      format.html { redirect_to faults_url, notice: 'Fault was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fault
      @fault = Fault.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fault_params
      params.require(:fault).permit(:fault_type, :fault_description, :fault_reported_by, :item_id)
    end
end
