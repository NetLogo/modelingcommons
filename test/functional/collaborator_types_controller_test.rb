require 'test_helper'

class CollaboratorTypesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:collaborator_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create collaborator_type" do
    assert_difference('CollaboratorType.count') do
      post :create, :collaborator_type => { }
    end

    assert_redirected_to collaborator_type_path(assigns(:collaborator_type))
  end

  test "should show collaborator_type" do
    get :show, :id => collaborator_types(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => collaborator_types(:one).to_param
    assert_response :success
  end

  test "should update collaborator_type" do
    put :update, :id => collaborator_types(:one).to_param, :collaborator_type => { }
    assert_redirected_to collaborator_type_path(assigns(:collaborator_type))
  end

  test "should destroy collaborator_type" do
    assert_difference('CollaboratorType.count', -1) do
      delete :destroy, :id => collaborator_types(:one).to_param
    end

    assert_redirected_to collaborator_types_path
  end
end
