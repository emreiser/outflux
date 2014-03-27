require'open-uri'

class Country < ActiveRecord::Base
  has_many :origin_ids, class_name: RefugeeCount, foreign_key: :origin_id
  has_many :destination_ids, class_name: RefugeeCount, foreign_key: :destination_id

  has_many :stories

  @@root = "http://www.unhcr.org"


  def getStories
    story_divs = self.getPage

    story_divs.each do |div|
      image = div.css('a img')[0]["src"]
      self.stories.create!(
        url: div.css('a')[0].attributes["href"].value,
        title: div.css('h3').text,
        pub_date: Date.parse(div.css('span').text),
        summary: div.css('.sticky').text,
        image: "#{@@root}#{image}",
      )

    end
  end

  def checkUpdates
    story_divs = self.getPage
    first_date = Date.parse(story_divs[0].css('span').text)

    stories = self.stories.sort_by &:pub_date
    if first_date > stories.first
      self.getStories
    end

  end

  def getPage
    file = open(self.url)

    html = Nokogiri::HTML(file)
    sub_story_section = html.css('#subStories')

    html.css('#subStories div')
  end
end
