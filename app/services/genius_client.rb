require "httparty"
require "nokogiri"
require "json"
require "net/http"

class GeniusClient
  include HTTParty
  base_uri "https://api.genius.com"

  def initialize(access_token = {})
    access_token = "U3wPmo7TSnuErUWHNhM-D5akWLS1csPLxWlmp4NKsGhO2-09uFwVJ-pyYNtXsOsc"
    @headers = {
      "Authorization" => "Bearer #{access_token}",
      "Content-Type" => "application/json"
    }
  end

  def search_song(song_title, artist_name)
    response = self.class.get("/search", headers: @headers, query: { q: "#{song_title} #{artist_name}" })
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
    request["Authorization"] = @headers["Authorization"]  # アクセストークンを設定
    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      parsed_html = Nokogiri::HTML(response.body)
      lyrics_div = parsed_html.css('div[data-lyrics-container="true"]')
      lyrics = lyrics_div.map(&:inner_html).join("\n")
      lyrics
    else
      raise StandardError.new("Error: #{response.code} #{response.message}")
    end
  end
end
