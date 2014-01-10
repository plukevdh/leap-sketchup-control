PLUGIN_PATH = File.expand_path(File.join(File.dirname(__FILE__), 'leap-sketchup-control'))
$LOAD_PATH.unshift PLUGIN_PATH

require File.join(PLUGIN_PATH, 'sketchup_json')
require 'sketchup'

class LeapSketchupReceiver 
	def run
		cam = Sketchup.active_model.active_view.camera

		timer_id = UI.start_timer(0.01, true) do
			open("/Users/hungerandthirst/Code/Projects/personal/leap-sketchup-control/my_pipe", "r+") do |pipe|
			
				begin
					data = pipe.read_nonblock(128)
					pos = SketchUpJSON::Parser.new(data).parse

					puts pos.inspect

					up = Geom::Vector3d.new(*pos["stick"])
					targ = Geom::Vector3d.new(*pos["dir"])
					
					cam.set(targ, cam.target, up)

				rescue SketchUpJSON::SyntaxError => ex
					puts data
				rescue Errno::EAGAIN => ex
					# puts ex
				end
			end
		end
	end
end

LeapSketchupReceiver.new.run