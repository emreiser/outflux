require 'csv'

class UNHCRData

  def self.assignUrls
    entries = [
      {code: "211", url: "http://www.unhcr.org/pages/5051e8cd6.html", emergency: true },
      {code: "144", url: "http://www.unhcr.org/pages/50597c616.html", emergency: true },
      {code: "190",  url: "http://www.unhcr.org/emergency/50597bc56-53315e95c.html", emergency: true},
      {code: "110", url: "http://www.unhcr.org/emergency/503353336-533032b3c.html", emergency: true},
      {code: "44", url: "http://www.unhcr.org/emergency/503353336-533032b3c.html", emergency: true},
      {code: "163", url: "http://www.unhcr.org/pages/49e4877d6.html", emergency: false},
      {code: "1", url: "http://unhcr.org/pages/49e486eb6.html", emergency: false},
      {code: "146", url: "http://www.unhcr.org/pages/49e4877d6.html", emergency: false},
      {code: "47", url: "http://www.unhcr.org/cgi-bin/texis/vtx/page?page=49e492ad6", emergency: false},
      {code: "65", url: "http://www.unhcr.org/cgi-bin/texis/vtx/page?page=49e4838e6", emergency: false},
      {code: "105", url: "http://www.unhcr.org/pages/49e486426.html", emergency: false},
      {code: "200", url: "http://www.unhcr.org/pages/49e483ad6.html", emergency: false}
    ]

    entries.each do |entry|
      country = Country.find_by(code: entry[:code])
      if country
        country.url = entry[:url]
        country.emergency = entry[:emergency]
        country.save!
      end
    end

    drc = Country.find_by(code: "44")
    drc.name = "Democratic Republic of the Congo"
    drc.save!

  end

  def self.build_codes_hash
    file = File.read("#{Rails.root}/public/world-topo-min.json")
    countries = JSON.parse(file)["objects"]["countries"]["geometries"]
    codes = {}

    countries.each do |country|
      codes[country["id"].to_s] = country["properties"]["name"]
    end

    return codes
  end

  def self.create_country(name)
    to_alias = [
      "Congo, the Democratic Republic of the",
      "Syrian Arab Republic",
    ]

    new_alias = [
      "DRC",
      "Syria"
    ]

    code = UNHCRData.build_codes_hash.key(name)
    country = Country.create!(name: name, code: code)

    if to_alias.include? name
      country.alias = new_alias[to_alias.index(name)]
      country.save!
    end

    return country

  end

  def self.import_refugee_counts
    unhcr_names = [
      "United States of America",
      "Bolivia (Plurinational State of)",
      "Hong Kong SAR, China",
      "Iran (Islamic Republic of)",
      "Libyan Arab Jamahiriya",
      "Republic of Korea",
      "Republic of Moldova",
      "Serbia and Montenegro",
      "The former Yugoslav Republic of Macedonia",
      "United Kingdom of Great Britain and Northern Ireland",
      "Venezuela (Bolivarian Republic of)",
      "Democratic Republic of the Congo",
      "United Republic of Tanzania",
      "Macao SAR, China",
      "Serbia (and Kosovo: S/RES/1244 (1999))",
      "Micronesia (Federated States of)",
      "Palestinian"
    ]

    topojson_names = [
      "United States",
      "Bolivia, Plurinational State of",
      "Hong Kong",
      "Iran, Islamic Republic of",
      "Libya",
      "Korea, Republic of",
      "Moldova, Republic of",
      "Serbia",
      "Macedonia, the former Yugoslav Republic of",
      "United Kingdom",
      "Venezuela, Bolivarian Republic of",
      "Congo, the Democratic Republic of the",
      "Tanzania, United Republic of",
      "Macao",
      "Serbia",
      "Micronesia, Federated States of",
      "Palestine, State of"
    ]

    # Get all country file names
    dir = "#{Rails.root}/data/refugees"
    country_files = Dir.new(dir).entries
    country_files.delete('.')
    country_files.delete('..')

    # Import data from csv files
    country_files.each do |f|
      data = CSV.read("#{dir}/#{f}")

      origin_name = data[0][0]
      if unhcr_names.include? origin_name
        origin_name = topojson_names[unhcr_names.index(origin_name)]
      end

      origin = Country.find_by(name: origin_name)
      if !origin
        origin = UNHCRData.create_country(origin_name)
      end

      headers = data[1][1,13]
      rows = data[2,200]

      rows.each do |row|
        dest_name = row[0]
        totals = row[1,13]

        if unhcr_names.include? dest_name
          dest_name = topojson_names[unhcr_names.index(dest_name)]
        end

        destination = Country.find_by(name: dest_name)
        if !destination
          destination = UNHCRData.create_country(dest_name)
        end

        totals.each_with_index do |total, i|
          if total && total != "*"
            count = RefugeeCount.create!(total: total, year: headers[i].to_i)
            count.origin = origin
            count.destination = destination

            count.save!
          end
        end

      end
    end

  end

end