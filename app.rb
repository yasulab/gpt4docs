require 'openai'
require 'json'
require 'pry'
require 'open-uri'

def read_online_file_until_line(url, line_number)
  line_count = 0
  lines = ""
  URI.open(url) do |file|
    file.each_line do |line|
      line_count += 1
      lines << line
      break if line_count >= line_number
    end
  end
  lines
end

def client
  OpenAI::Client.new(access_token: ENV.fetch('OPENAI_ACCESS_TOKEN'), request_timeout: 1200)
end

def ja_doc
  # Japanese document
  # Orignial markdown https://github.com/yasslab/railsguides.jp/blob/master/guides/source/ja/association_basics.md
  read_online_file_until_line("https://raw.githubusercontent.com/yasslab/railsguides.jp/master/guides/source/ja/association_basics.md", 80)
end

def update_doc
  # GitHub PR Patch File.
  # This would be the latest file that will be used to check for matching translation in ja_doc
  # Original PR https://github.com/rails/rails/pull/48166
  read_online_file_until_line("https://patch-diff.githubusercontent.com/raw/rails/rails/pull/48166.patch", 53)
end

def message
  [
    { role: "system", content: 'Use the git log patch file to match the possible translation in japanese. Insert the english text to the japanese text when it matches. Also output the missing or not matching results. ' },
    { role: "user", content: "
      git log patch:
      '''
      #{update_doc}
      '''

      japanese:
      '''
      #{ja_doc}
      '''
    "}
  ]
end

request = client.chat(parameters: { model: "gpt-4", messages: message, temperature: 0.0 })

chat_gpt_response = File.open("ar_associate_chatgpt.json", "w")

chat_gpt_response.puts request

chat_gpt_response.close

response_json = File.read('ar_associate_chatgpt.json')

response_content = JSON.parse(response_json).dig("choices", 0, "message", "content")

response_md = File.open("ar_associate_chatgpt.md", "w")

response_md.puts response_content

response_md.close
