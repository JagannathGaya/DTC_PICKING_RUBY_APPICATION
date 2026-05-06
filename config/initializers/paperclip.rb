require 'paperclip'

Paperclip.options[:command_path] = 'C:\Program Files\ImageMagick-6.8.3-Q16' if Rails.env.development?
Paperclip.options[:swallow_stderr] = false


# See if this fixes Lonnie's problem
require 'paperclip/media_type_spoof_detector'
module Paperclip
  class MediaTypeSpoofDetector
    def spoofed?
      false
    end
  end
end

