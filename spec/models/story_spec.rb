require 'spec_helper'

describe Story do

  describe "validations" do
    it should { belong_to :country}
  end
end
