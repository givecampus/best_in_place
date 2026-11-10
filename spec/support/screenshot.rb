require 'fileutils'
require 'launchy'

def screenshot(path = Rails.root.join("local", "screenshot.png"), open: !ENV['CI'])
  FileUtils.mkdir_p(File.dirname(path))
  save_screenshot(path)
  Launchy.open(path.to_s) if open
end
