require 'rubygems'
require 'bundler'
Bundler.require

module SimpleGet
  def get(url:)
    conn = Faraday.new(:url => url) do |faraday|
      faraday.request  :url_encoded
      # faraday.response :logger
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
    @versions = self.get(url: "#{URL}/#{@name}.json")
  end

  def stats
    puts
    puts "#{@name} has #{@versions.count} versions"
    puts
    puts "The 10 most recent:"
    @versions.take(10).each do |version|
      data = [version["number"], version["built_at"], version["downloads_count"]]
      puts data.join(', ')
    end
    puts
    nil
  end
end

__END__

rails
minitest
rspec
faraday

GemChurn.new('rails').stats
GemChurn.new('minitest').stats
GemChurn.new('rspec').stats
GemChurn.new('faraday').stats
GemChurn.new('pg').stats
