# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :story do
    title "MyText"
    url "MyText"
    image "MyText"
    summary "MyText"
    pub_date "2014-03-27 09:41:14"
    country nil
  end
end
