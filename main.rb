require "bundler/setup"
require "faraday"
require "json"
require "dotenv"
require "csv"

# load environment values
Dotenv.load

# Request URI
YOUTUBE_API_URI = 'https://www.googleapis.com/youtube/v3'.freeze
API_KEY = ENV['API_KEY'].freeze

if ARGV[0].nil?
  puts "error: input stream ID"
  exit
end

# Get video id from argument
video_id = ARGV[0]

paths = {
  :streaming => "/liveChat/messages",
  :videos => "/videos"
}

params_for_videos = {
  :part => "liveStreamingDetails",
  :id => video_id,
  :key => API_KEY
}

# puts "Target livestreaming is : " + video_id

# Get channel ID from the streaming
resp_from_videos = Faraday.get(YOUTUBE_API_URI + paths[:videos], params_for_videos)
chat_id = JSON.parse(resp_from_videos.body)["items"][0]["liveStreamingDetails"]["activeLiveChatId"]

# puts "Active Chat ID is : " + chat_id

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
  comments = []
  begin

    resp_from_liveChat = Faraday.get(YOUTUBE_API_URI + paths[:streaming], params_for_streaming)

    res_body = JSON.parse(resp_from_liveChat.body)
    res_body['items'].each do |chat|
      comments << chat['snippet']['authorChannelId']
      comments << chat['snippet']['displayMessage']
    end
    puts comments

    params_for_streaming[:nextPageToken] = res_body['nextPageToken']

    sleep res_body['pollingIntervalMillis'] / 1000
  rescue Interrupt
    puts "bye"
    break
  rescue
    puts "Program exited by unexpected error"
    break
  end
end

# Create CSV file
# CSV.open(video_id + ".csv", "w") do |csv|
# end
