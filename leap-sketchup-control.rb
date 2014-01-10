require 'socket'
require 'json'
require 'bundler'

Bundler.require

class LeapSketchupControl < LEAP::Motion::WS
  def on_connect
    puts "Connected"
    @pipe = open "my_pipe", "w+"
    write "Hello from LeapMotion controller"
  end

  def on_frame(frame)
  	hand = frame.hands.first
    
    if hand && frame.pointables.count < 2
      stick = hand.palmNormal
      direct = hand.direction
      
      stick = [stick[0], -stick[2], -stick[1]]
      direct = [direct[0], direct[2], -direct[1]]

      dat = {stick: stick, dir: direct}
      puts dat.inspect

      send_json(dat)
    end
  end

  def on_disconnect
    puts "Disconected"
    write "Goodbye from LeapMotion controller"
    @pipe.close
    stop
  end

  private 
  def send_json(data)
    @pipe.puts JSON.generate(data)
    @pipe.flush
  end

  def write(msg)
    @pipe.puts msg
    @pipe.flush
  end
end

leap = LeapSketchupControl.new()
leap.start
