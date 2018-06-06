require 'rails_helper'

RSpec.describe GramsController, type: :controller do
  describe "grams#destroy action" do
    it "shouldn't allow users who didn't create the gram to destroy it" do
      gram = FactoryBot.create(:gram) # Create a gram in our database
      user = FactoryBot.create(:user) # Create a new (different) user
      sign_in user # Sign in the new user, not the creator of the gram
      delete :destroy, params: { id: gram.id } # Try to delete the new gram as new user
      expect(response).to have_http_status(:forbidden) # Expect this to be forbidden
    end

    it "shouldn't let unauthenticated users destroy a gram" do
      gram = FactoryBot.create(:gram) # A gram needs to exist in our database
      delete :destroy, params: { id: gram.id } 
      expect(response).to redirect_to new_user_session_path      
    end

    it "should allow a user to destroy grams" do
      gram = FactoryBot.create(:gram) # Create a gram in the database
      sign_in gram.user # Make sure that a user is logged in
      delete :destroy, params: { id: gram.id } # Perform Delete HTTP req to Destroy action
      expect(response).to redirect_to root_path
      gram = Gram.find_by_id(gram.id)
      expect(gram).to eq nil # Check that gram no longer exists in DB
    end

    it "should return a 404 message if we cannot find a gram with the id that is specified" do
      user = FactoryBot.create(:user) # Create a user in the database
      sign_in user # Make sure that the user is logged in
      delete :destroy, params: { id: 'SPACEDUCK' } # Trigger the Delete HTTP req to grams#destroy action
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "grams#update action" do
    it "shouldn't let users who didn't create the gram update it" do
      gram = FactoryBot.create(:gram) # A gram needs to exist in our database
      user = FactoryBot.create(:user) # Create a new (different) user
      sign_in user # Sign in as the new user, not the creator of the gram
      patch :update, params: { id: gram.id, gram: { message: "wahoo" } }
      expect(response).to have_http_status(:forbidden)
    end

    it "shouldn't let unauthenticated users update a gram" do
      gram = FactoryBot.create(:gram) # A gram needs to exist in our database
      patch :update, params: { id: gram.id, gram: { message: "Hello" } }
      expect(response).to redirect_to new_user_session_path
    end

    it "should allow users to successfully update grams" do
      gram = FactoryBot.create(:gram, message: "Initial Value") # Create gram with msg of "Initial Value"
      sign_in gram.user # Make sure that a user is logged in

      patch :update, params: { id: gram.id, gram: { message: "Changed" } } # Trigger HTTP Patch req to 'update' action
      expect(response).to redirect_to root_path
      gram.reload # gram var contains old db record, so need to reload with new
      expect(gram.message).to eq "Changed" # Check that record contains new value
    end

    it "should have http 404 error if the gram cannot be found" do
      user = FactoryBot.create(:user) # Create a user in the database
      sign_in user # Make sure that the user is logged in

      patch :update, params: { id: "YOLOSWAG", gram: { message: "Changed" } }
      expect(response).to have_http_status(:not_found)
    end

    it "should render the edit form with an http status of unprocessable_entity" do
      gram = FactoryBot.create(:gram, message: "Initial Value") # We need a gram in our DB
      sign_in gram.user # Make sure that a user is logged in

      patch :update, params: { id: gram.id, gram: { message: "" } } # Perform HTTP Patch req, but with empty string
      expect(response).to have_http_status(:unprocessable_entity) # Test expects HTTP status of 422
      gram.reload
      expect(gram.message).to eq "Initial Value" # Check that nothing's changed      
    end
  end

  describe "grams#edit action" do
    it "shouldn't let a user edit a gram if they did not create it" do
      gram = FactoryBot.create(:gram) # A gram needs to exist in our database
      user = FactoryBot.create(:user) # Create a new (different) user
      sign_in user # Sign in as the new user, not the gram creator
      get :edit, params: { id: gram.id } # Trigger GET req to the edit action for new gram
      expect(response).to have_http_status(:forbidden)
    end

    it "shouldn't let unauthenticated users edit a gram" do
      gram = FactoryBot.create(:gram) # A gram needs to exist in our database
      get :edit, params: { id: gram.id } 
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully show the edit form if the gram is found" do
      gram = FactoryBot.create(:gram) # We need a gram in our DB
      sign_in gram.user # Make sure that a user is logged in

      get :edit, params: { id: gram.id }
      expect(response).to have_http_status(:success)
    end

    it "should return a 404 error message if the gram is not found" do
      user = FactoryBot.create(:user) # Create a user in the database
      sign_in user # Make sure that the user is logged in

      get :edit, params: { id: 'BLAHBLAH' }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "grams#show action" do
    it "should successfully show the page if the gram is found" do
      gram = FactoryBot.create(:gram)
      get :show, params: { id: gram.id }
      expect(response).to have_http_status(:success)
    end

    it "should return a 404 error if the gram is not found" do
      get :show, params: { id: 'TACOCAT' }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "grams#index action" do
    it "should successfully show the page" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#new action" do
    it "should require users to be logged in" do
      get :new
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully show the new form" do
      user = FactoryBot.create(:user) # Create a user in the database
      sign_in user # Make sure that the user is logged in

      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#create action" do
    it "should require users to be logged in" do
      post :create, params: { gram: { message: "Hello" } }
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully create a new gram in our database" do
      user = FactoryBot.create(:user) # Create a user in the database
      sign_in user # Make sure that the user is logged in

      post :create, params: { gram: { message: 'Hello!' } }
      expect(response).to redirect_to root_path

      gram = Gram.last
      expect(gram.message).to eq("Hello!")
      expect(gram.user).to eq(user)
    end

    it "should properly deal with validation errors" do
      user = FactoryBot.create(:user) # Create a user in the database
      sign_in user # Make sure that the user is logged in

      gram_count = Gram.count
      post :create, params: { gram: { message: '' } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(gram_count).to eq Gram.count
    end
  end
end