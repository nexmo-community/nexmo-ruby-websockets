require 'faye/websocket'
require 'json'
require "wavefile"
include WaveFile

EXTERNAL_WS_URL = 'ws://example.com/cable'

Faye::WebSocket.load_adapter('thin')

App = lambda do |env|
  if Faye::WebSocket.websocket?(env)
    puts "WebSockets connection opened..."
    @call_data = []
    ws = Faye::WebSocket.new(env)

    ws.on :message do |event|
      if event.data.is_a?(Array)
        @call_data.append(event.data.pack('c*').unpack('s*'))
      else
        puts event.data
      end
    end

    ws.on :close do |event|
      puts 'WebSocket connection closed...'
      create_wav_file(@call_data.flatten)
    end

    ws.rack_response

  elsif env['REQUEST_PATH'] == '/'
    [200, { 'Content-Type' => 'text/html'}, ['Hi there']]
  
  elsif env['REQUEST_PATH'] == '/webhooks/answer'
    ncco = [
      {
        "action": "talk",
        "text": "You will be streaming momentarily."
      },
      {
        "action": "connect",
        "endpoint": [
          {
            "type": "websocket",
            "uri": "#{EXTERNAL_WS_URL}",
            "content-type": "audio/l16;rate=16000",
          }
        ]
      }
    ].to_json

    [200, { 'Content-Type' => 'application/json' }, [ncco]]

  elsif env['REQUEST_PATH'] == '/webhooks/event'
    [200, { 'Content-Type' => 'text/html'}, ['']]
  end
end

def create_wav_file(data)
  buffer = Buffer.new(data, Format.new(:mono, :pcm_16, 16000)) 
  puts "Audio Buffer Created..."
  writer = Writer.new("my_file.wav", Format.new(:mono, :pcm_16, 16000))
  puts "New Audio File Created..."
  puts "Writing to the Buffer..."
  writer.write(buffer)
  puts "Closing Buffer Writing..."
  writer.close
  puts "WAV File Created..."
end