require 'test_helper'

class ClientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @client = create(:client, user: @user)
    login_as(@user)
  end

  test 'valid factory' do
    assert @client.valid?
  end

  test 'should get index' do
    get clients_path
    assert_response :success
  end

  test 'should get new' do
    get new_client_path
    assert_response :success
  end

  test 'should create client' do
    assert_difference('Client.count') do
      post clients_path, params: {
        client: {
          firstname: @client.firstname,
          lastname: @client.lastname,
          user: @user
        }
      }
    end

    assert_redirected_to client_path(Client.last)
  end

  test 'should show client' do
    get client_path(@client)
    assert_response :success
  end

  test 'should get edit' do
    get edit_client_path(@client)
    assert_response :success
  end

  test 'should update client' do
    patch client_path(@client), params: {
      client: { firstname: @client.firstname }
    }
    assert_redirected_to client_path(@client)
  end
end
