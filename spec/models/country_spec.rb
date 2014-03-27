require 'spec_helper'

describe Country do

  before(:each) do
    @country = Country.create!(name: "Mali", code: "144", url: "http://www.unhcr.org/pages/50597c616.html")
  end

  describe "relationships" do
    it {should have_many :origins }
    it {should have_many :destinations }
  end

  describe "#getPage" do

    it "should return an array of Nokogiri elements if found" do
      expect(@country.getPage.class).to be Nokogiri::XML::NodeSet
    end
  end

  describe "#getStories" do

    it "should create story instances asssociated with the country if found" do
      @country.getStories
      expect(@country.stories.count).to_not eq 0
    end

  end


end