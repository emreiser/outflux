require'open-uri'

class Story < ActiveRecord::Base
  belongs_to :country

  def self.getStories(country_id)
    country = Country.find(country_id)
    binding.pry

    file = open(country.url)
    root = "http://www.unhcr.org"

    html = Nokogiri::HTML(file)
    sub_story_section = html.css('#subStories')

    story_divs = html.css('#subStories div')


    story_divs.each do |div|
      image = div.css('a img')[0]["src"]
      Story.create!(
        url: div.css('a')[0].attributes["href"].value,
        title: div.css('h3').text,
        pub_date: Date.parse(div.css('span').text),
        summary: div.css('.sticky').text,
        image: "#{root}#{image}",
        country: country
      )

    end
  end

end
