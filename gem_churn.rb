require 'rubygems'
require 'bundler'
Bundler.require

module SimpleGet
  def get(url:)
    conn = Faraday.new(:url => url) do |faraday|
      faraday.request  :url_encoded
      faraday.adapter  Faraday.default_adapter

      faraday.request :json
      faraday.response :json, :content_type => /\bjson$/
    end
    response = conn.get
    response.status == 200 ? response.body : response
  end
end

class GemChurn
  include SimpleGet
  URL = 'https://rubygems.org/api/v1/versions'

  def initialize(name)
    @name     = name
    @versions = self.get(url: "#{URL}/#{@name}.json").select { |v| v["downloads_count"] > 1000 }
  end

  def stats
    puts "\n#{@name} has #{@versions.count} versions\n"
    puts "The 10 most recent:"
    top_10 = @versions.take(10)
    top_10.each do |version|
      date = Date.parse(version["built_at"])
      data = [version["number"], date.to_s, version["downloads_count"]]
      puts data.join(', ')
    end
  end
end

__END__

gems = %w(
  rails
  minitest
  rspec
  faraday
  pg
  factory_girl
)
gems.each { |gem| GemChurn.new(gem).stats }
