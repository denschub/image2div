require "rubygems"
require "RMagick"
require "tenjin"

class HtmlImage
  def initialize(filename)
    @filename = filename
    @file = Magick::Image.read(filename).first
    @width = @file.columns
    @height = @file.rows
    @pixels = @width * @height
  end

  def readPixels
    @pixels = Array.new
    for y in 0..(@height-1)
      for x in 0..(@width-1)
        pixel = @file.pixel_color(x, y)
        color = pixel.to_color(Magick::XPMCompliance, false, 8, true)
        color[0] = ''
        @pixels.push(color)
      end
    end
    puts "#{@pixels.count} pixels"
  end

  def getColors
    @colors = @pixels.uniq
    @colors.sort!

    puts "#{@colors.count} colors"
  end

  def writeToFile
    tplEngine = Tenjin::Engine.new()
    @output_file = File.new("#{@filename}.html", "w+")

    tplVars = {:title => @filename,
               :width => @width,
               :height => @height,
               :colors => @colors,
               :pixels => @pixels}

    htmlFile = tplEngine.render("template.rbhtml", tplVars)
    @output_file.puts htmlFile
    @output_file.close
  end
end

image = HtmlImage.new(ARGV[0])
image.readPixels
image.getColors
image.writeToFile
