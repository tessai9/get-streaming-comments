# Script for getting youtube streaming comments

## About

This script gets comments from youtube streaming, and exports as csv.

## Prerequired

- You need to have account of the GCP
  - Create new project
  - Generate API key to use `Youtube Data API`
- Copy `.env.template` as `.env`
  - Open the file and set API key generated in the above

## How to use

1. Run `bundle install`
1. Get Video ID of the streaming from URL
    When the URL is `https://www.youtube.com/watch?v=ruXX7vJQbmk`, Video ID is `ruXX7vJQbmk`
1. Run this script with the Video ID
    ```
    # When the video ID is ruXX7vJQbmk
    $ bundle exec ruby main.rb ruXX7vJQbmk
    ```
1. Script automatically ends when the streaming is finished.
1. Comments are exported as csv to `tmp` directory which name is `comments_(Video ID)_(YYYYMMDD_His).csv`

## Note

This script can only be run on the content that is on streaming.
