require 'rack'
require 'erb'
require 'faye/websocket'
require 'json'
require "wavefile"
include Rack
include WaveFile

EXTERNAL_WS_URL = 'ws://example.com/cable'

def create_wav_file(data, file_name)
  buffer = Buffer.new(data, Format.new(:mono, :pcm_16, 16000)) 
  puts "Audio Buffer Created..."
  writer = Writer.new(file_name, Format.new(:mono, :pcm_16, 16000))
  puts "New Audio File Created..."
  puts "Writing to the Buffer..."
  writer.write(buffer)
  puts "Closing Buffer Writing..."
  writer.close
  puts "WAV File Created..."
  file_name
end

def erb(template)
  path = File.expand_path("#{template}")
  ERB.new(File.read(path)).result(binding)
end


Rack::Handler::Thin.run(Rack::Builder.new {
  Faye::WebSocket.load_adapter('thin')
  use(Rack::Static, urls: ["/recording"], root: 'recording')

  map('/cable') do
    run(->env{
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
          create_wav_file(@call_data.flatten, 'recording/recording.wav')
          @call_status = 'Audio Loaded!'
          run(->env {
            [ 302, {'Location' =>'/'}, [[erb("views/index.html.erb")]] ]
          })
        end
    
        ws.rack_response
      end
    })
  end
  
  map('/') do
    if File.exist?('recording.wav')
      @call_status = 'Audio Loaded!'
      @file = 'recording.wav'
    end
    run(->env{
      [200, { 'Content-Type' => 'text/html'}, [erb("views/index.html.erb")]]})
  end

  map('/webhooks/answer') do
    run(->env{
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
    })
  end

  map('/webhooks/event') do
    run(->env{
      [200, { 'Content-Type' => 'text/html'}, ['']]
    })
  end
}, Port: 9292)