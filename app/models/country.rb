require'open-uri'

class Country < ActiveRecord::Base
  has_many :origins, class_name: RefugeeCount, foreign_key: :origin_id
  has_many :destinations, class_name: RefugeeCount, foreign_key: :destination_id

  has_many :stories


  def getStories
    root = "http://www.unhcr.org"
    story_divs = self.getPage

    story_divs.each do |div|
      image = div.css('a img')[0]["src"]
      self.stories.create(
        url: div.css('a')[0].attributes["href"].value,
        title: div.css('h3').text,
        pub_date: Date.parse(div.css('span').text),
        summary: div.css('.sticky').text,
        image: "#{root}#{image}",
      )

    end
  end

  def getPage
    file = open(self.url)

    html = Nokogiri::HTML(file)
    sub_story_section = html.css('#subStories')

    html.css('#subStories div')
  end
end
