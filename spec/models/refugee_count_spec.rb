require 'spec_helper'


describe RefugeeCount do

  describe "relationships" do
    it should { belong_to :origin }
    it should { belong_to :destination }
  end

end