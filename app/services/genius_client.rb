require "httparty"
require "nokogiri"
require "json"
require "net/http"

class GeniusClient
  include HTTParty
  base_uri "https://api.genius.com"

  def initialize(access_token = {})
    access_token = "olwyQYzqqJ5yoAJLNscJFZOIFFtVjmidkMWwfpZdz8phk8aN_vX4yC_r0BFIYM49"
    @headers = {
      "Authorization" => "Bearer #{access_token}",
      "Content-Type" => "application/json"
    }
  end

  def search_song(song_title, artist_name)
    response = self.class.get("/search", headers: @headers, query: { q: "#{song_title} #{artist_name}" })
    # response = self.class.get("/search", query: { q: "#{song_title} #{artist_name}" })
    if response.success?
      JSON.parse(response.body)["response"]["hits"]
    else
      puts "Response Code: #{response.code}"
      puts "Response Message: #{response.message}"
      puts "Response Headers: #{response.headers.inspect}"
      puts "Response Body: #{response.body}"
      raise StandardError.new("Error: #{response.response}")
    end
  end

  def get_lyrics(url)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    parsed_html = Nokogiri::HTML(response)
    
    # 特定のdivタグの中身を抽出
    lyrics_div = parsed_html.css('div[data-lyrics-container="true"]')
    lyrics = lyrics_div.map(&:inner_html).join("\n")
    
    # if response.success?
    #   # matches = response.body.scan(/<div data-lyrics-container="true" class="Lyrics-sc-3051f9b7-1 kLpNCS">(.*?)<\/div>/m)
    #   response
    #   # if response.any?
    #   #   lyrics_array = matches.map { |match| match[0] } # マッチした内容を配列に格納
    #   #   lyrics_array
    #   # else
    #   #   raise StandardError.new("Lyrics not found in the response body")
    #   # end
    # else
    #   puts "Response Code: #{response.code}"
    #   puts "Response Message: #{response.message}"
    #   puts "Response Headers: #{response.headers.inspect}"
    #   puts "Response Body: #{response.body}"
    #   raise StandardError.new("Error: #{response.response}")
    # end
  end
end
