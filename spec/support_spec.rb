require 'tmpdir'

describe 'Screenshot support', type: :feature do
  let(:directory) { Dir.mktmpdir('best-in-place-screenshots') }
  let(:path) { File.join(directory, 'nested', 'screenshot.png') }

  before do
    allow(self).to receive(:save_screenshot)
    allow(Launchy).to receive(:open)
  end

  after do
    FileUtils.remove_entry(directory)
  end

  it 'creates the screenshot directory and uses driver-compatible options' do
    expect(self).to receive(:save_screenshot).with(path)

    screenshot(path, open: false)

    expect(File.directory?(File.dirname(path))).to be(true)
  end

  it 'does not launch a browser for failure artifacts' do
    expect(Launchy).not_to receive(:open)

    screenshot(path, open: false)
  end

  it 'can open screenshots during local debugging' do
    expect(Launchy).to receive(:open).with(path)

    screenshot(path, open: true)
  end
end
