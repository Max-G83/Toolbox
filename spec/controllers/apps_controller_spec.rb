require 'spec_helper'

describe AppsController do

  describe "GET 'locations'" do
    it "returns http success" do
      get 'locations'
      response.should be_success
    end
  end

  describe "GET 'restock_clear'" do
    it "returns http success" do
      get 'restock_clear'
      response.should be_success
    end
  end

  describe "GET 'labels'" do
    it "returns http success" do
      get 'labels'
      response.should be_success
    end
  end

  describe "GET 'quote'" do
    it "returns http success" do
      get 'quote'
      response.should be_success
    end
  end

end
