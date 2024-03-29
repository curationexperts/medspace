# Generated via
#  `rails generate hyrax:work Publication`
require 'rails_helper'
include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a Document', js: false do
  context 'a logged in user' do
    let(:user_attributes) do
      { email: 'test@example.com' }
    end
    let(:user) do
      User.new(user_attributes) { |u| u.save(validate: false) }
    end

    before do
      login_as user
    end

    scenario do
      visit '/concern/documents/new'
      fill_in 'Title', with: "My Object Title"
      fill_in 'Description', with: "A description of my object"
      fill_in 'Subject', with: 'Vase'
      fill_in 'Object Date', with: '1973'
      # removed link during customization click_link("Additional fields")
      fill_in "Archival collection", with: "Eugene Stead Papers"
      select('Medical Library Association', from: 'Host organization')
      # If you generate more than one work uncomment these lines
      # choose "payload_concern", option: "Image"
      # click_button "Create work"

      expect(page).to have_content "Medical Library Association"
    end
  end
end
