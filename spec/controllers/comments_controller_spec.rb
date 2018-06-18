require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  describe "comments#create action" do
    it "should allow users to create comments on grams" do
      gram = FactoryBot.create(:gram) # Create a gram in the database
      user = FactoryBot.create(:user) # Create a new user in the database
      sign_in user # Sign in as that user
      post :create, params: { gram_id: gram.id, comment: { message: 'awesome gram' } } # POST req

      expect(response).to redirect_to root_path
      expect(gram.comments.length).to eq 1
      expect(gram.comments.first.message).to eq 'awesome gram'
    end

    it "should require a user to be logged in to comment on a gram" do
      gram = FactoryBot.create(:gram) # Create a gram in the database
      # Need to simulate somebody who is NOT logged in, so no user sign-in here
      post :create, params: { gram_id: gram.id, comment: { message: 'awesome gram' } } # POST req

      expect(response).to redirect_to new_user_session_path # Redirect to the sign-in page
    end

    it "should return HTTP status code of not found if the gram isn't found" do
      user = FactoryBot.create(:user) # Create a new user in the database
      sign_in user # Sign in as that user
      post :create, params: { gram_id: 'YOLOSWAG', comment: { message: 'awesome gram' } }

      expect(response).to have_http_status :not_found # Resp should say YOLOSWAG doesn't exist
    end
  end 
end