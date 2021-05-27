require "bundler/setup"
require "faraday"
require "json"
require "dotenv"
require "csv"

# Raise error if no argument provided
raise ArgumentError, "Execute this script with stream ID" if ARGV.empty?

# load environment values
Dotenv.load

# Consts
YOUTUBE_API_URI = 'https://www.googleapis.com/youtube/v3'.freeze
API_KEY = ENV['API_KEY'].freeze
API_PATH = {
  :streaming => "/liveChat/messages",
  :videos => "/videos"
}.freeze

# Get video id from argument
video_id = ARGV.first

# Set request info
params_for_videos = {
  :part => "liveStreamingDetails",
  :id => video_id,
  :key => API_KEY
}

# Get channel ID from the streaming
resp_from_videos = Faraday.get("#{YOUTUBE_API_URI}#{API_PATH[:videos]}", params_for_videos)
chat_id = JSON.parse(resp_from_videos.body, symbolize_names: true)[:items]
            .first[:liveStreamingDetails][:activeLiveChatId]

# Create file
f = File.new("./tmp/comments_#{video_id}_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv", "a")

# Get comments from the streaming
pageToken = 1
nextPageToken = nil
offlinedAt = nil

params_for_streaming = {
  :part => "id,snippet,authorDetails",
  :liveChatId => chat_id,
  :key => API_KEY,
}

while offlinedAt.nil?
  output = []
  begin

    # Get data from streaming
    resp_from_liveChat = Faraday.get("#{YOUTUBE_API_URI}#{API_PATH[:streaming]}", params_for_streaming)

    res_body = JSON.parse(resp_from_liveChat.body, symbolize_names: true)
    comments = res_body[:items]
    comments.each do |chat|
      snippet = chat[:snippet]
      row = CSV.generate_line([
                          snippet[:publishedAt],
                          snippet[:authorChannelId],
                          snippet[:displayMessage],
                        ])
      f.puts row
    end

    params_for_streaming[:nextPageToken] = res_body[:nextPageToken]

    sleep res_body[:pollingIntervalMillis] / 1000
  rescue Interrupt
    f.close
    puts "bye"
    break
  rescue
    f.close
    puts "Program exited by unexpected error"
    break
  end
end

f.close
