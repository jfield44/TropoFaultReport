require 'test_helper'

class FaultsControllerTest < ActionController::TestCase
  setup do
    @fault = faults(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:faults)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create fault" do
    assert_difference('Fault.count') do
      post :create, fault: { fault_description: @fault.fault_description, fault_reported_by: @fault.fault_reported_by, fault_type: @fault.fault_type, item_id: @fault.item_id }
    end

    assert_redirected_to fault_path(assigns(:fault))
  end

  test "should show fault" do
    get :show, id: @fault
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @fault
    assert_response :success
  end

  test "should update fault" do
    patch :update, id: @fault, fault: { fault_description: @fault.fault_description, fault_reported_by: @fault.fault_reported_by, fault_type: @fault.fault_type, item_id: @fault.item_id }
    assert_redirected_to fault_path(assigns(:fault))
  end

  test "should destroy fault" do
    assert_difference('Fault.count', -1) do
      delete :destroy, id: @fault
    end

    assert_redirected_to faults_path
  end
end
