describe BestInPlace::DisplayMethods do
  before do
    stub_const('DisplayMethodRecord', Struct.new(:name, :money) do
      extend ActiveModel::Naming

      def display_name
        name.upcase
      end
    end)
    described_class.model_attributes(DisplayMethodRecord).clear
  end

  let(:record) { DisplayMethodRecord.new('Lucia', 150) }

  def rendered_value(attribute)
    renderer = described_class.lookup(DisplayMethodRecord, attribute)
    JSON.parse(renderer.render_json(record))
  end

  it 'returns nil for an unregistered attribute' do
    expect(described_class.lookup(DisplayMethodRecord, :name)).to be_nil
  end

  it 'renders a model method and normalizes attribute keys' do
    described_class.add_model_method(DisplayMethodRecord, :name, :display_name)

    expect(rendered_value('name')).to eq('display_as' => 'LUCIA')
  end

  it 'renders a view helper without options' do
    described_class.add_helper_method(DisplayMethodRecord, :money, :number_to_currency)

    expect(rendered_value(:money)).to eq('display_as' => '$150.00')
  end

  it 'passes options to view helpers' do
    described_class.add_helper_method(DisplayMethodRecord, :money, :number_to_currency, unit: 'GBP ')

    expect(rendered_value(:money)).to eq('display_as' => 'GBP 150.00')
  end

  it 'renders a proc' do
    described_class.add_helper_proc(DisplayMethodRecord, :name, ->(value) { "Hello, #{value}" })

    expect(rendered_value(:name)).to eq('display_as' => 'Hello, Lucia')
  end

  it 'keeps registrations separate for different models' do
    described_class.add_model_method(DisplayMethodRecord, :name, :display_name)

    expect(described_class.lookup(Cuca::Car, :name)).to be_nil
  end

  it 'returns an empty JSON object for an unknown renderer type' do
    renderer = described_class::Renderer.new({ type: :unknown })

    expect(JSON.parse(renderer.render_json(record))).to eq({})
  end
end
