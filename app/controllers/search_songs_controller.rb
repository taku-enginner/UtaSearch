class SearchSongsController < ApplicationController
  before_action :set_search_song, only: %i[ show edit destroy ]

  # GET /search_songs or /search_songs.json
  def index
    @search_song = SearchSong.new
    @search_songs = SearchSong.all.order(created_at: :desc)
  end

  # GET /search_songs/search_results
  def search_results
    Rails.logger.debug "search_resultsアクションに入りました"
    @search_song = SearchSong.new(search_song_params)
    if @search_song.title.present? || @search_song.artist_name.present?
      genius_client = GeniusClient.new
      @hits = genius_client.search_song(@search_song.title, @search_song.artist_name)
      Rails.logger.debug "Hits: #{@hits}"
    else
      @hits = []
    end
  end

  def show
    @search_song = SearchSong.find(params[:id])
  end

  def lyrics
    Rails.logger.debug "Lyricsアクションに入りました"
    Rails.logger.debug "lyrics_action_Params: #{params}"
    genius_client = GeniusClient.new
    api_path = params[:hit][:result][:api_path]

    begin
      @lyrics = genius_client.get_lyrics("https://genius.com#{api_path}")   
      Rails.logger.debug "getLyrics: #{@lyrics}"
    rescue StandardError => e
      Rails.logger.error "API call failed: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      @lyrics = "Error retrieving lyrics."
    end
    # # URLの検証
    # unless valid_url?(api_path)
    #   flash[:alert] = "無効なURLです"
    #   redirect_to search_songs_path and return
    # end
    # Rails.logger.debug "lyrics_path: #{api_path}"

    

    # # デバッグ用のログ
    # Rails.logger.debug "Title: #{params[:title]}"
    # Rails.logger.debug "Artist Name: #{params[:artist_name]}"
    # Rails.logger.debug "URL: #{params[:url]}"

    # # 曲名とアーティスト名を保存
    # @search_song = SearchSong.new(title: params[:title], artist_name: params[:artist_name], url: params[:url])
    # if @search_song.save
    #   flash[:notice] = "履歴が保存されました"
    # else
    #   flash[:alert] = "履歴の保存に失敗しました"
    # end
    p "lyrics: #{@lyrics}"

  end

  def how_to_use
  end

  # DELETE /search_songs/1
  def destroy
    @search_song.destroy
    respond_to do |format|
      format.html { redirect_to search_songs_url, notice: "履歴を削除しました" }
      format.json { head :no_content }
    end
  end

  private

  def set_search_song
    @search_song = SearchSong.find(params[:id])
  end

  def search_song_params
    params.fetch(:search_song, {}).permit(:title, :artist_name, :url)
  end

  def valid_url?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
  rescue URI::InvalidURIError
    false
  end
end
