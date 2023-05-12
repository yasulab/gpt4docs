require 'openai'
require 'json'
require 'pry'

def client
  OpenAI::Client.new(access_token: ENV.fetch('OPENAI_ACCESS_TOKEN'), request_timeout: 1200)
end

def message
    patch = File.read('ar_associate_en.patch')
    markdown = File.read('ar_associate_ja.md')

  [
    { role: "system", content: 'Use the git log patch file to match the possible translation in japanese. Insert the english text to the japanese text when it matches. Also output the missing or not matching results. ' },
    { role: "user", content: "
      git log patch:
      '''
      #{patch}
      '''

      japanese:
      '''
      #{markdown}
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
