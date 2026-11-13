describe BestInPlace::ControllerExtensions, type: :controller do
  controller(ApplicationController) do
    attr_accessor :editable_record

    def update
      options = params[:object_param] ? { param: params[:object_param] } : {}
      respond_with_bip(editable_record, options)
    end
  end

  let(:record) { User.new(name: 'Lucia') }

  before do
    routes.draw { put 'update', to: 'anonymous#update' }
    controller.editable_record = record
  end

  it 'returns no content when no display renderer is registered' do
    expect(BestInPlace::DisplayMethods).to receive(:lookup).with(User, 'name').and_return(nil)

    put :update, params: { user: { name: 'Lucia' } }, format: :json

    expect(response).to have_http_status(:no_content)
    expect(response.body).to be_empty
  end

  it 'returns the registered display value as JSON' do
    renderer = BestInPlace::DisplayMethods::Renderer.new({ type: :proc, attr: :name, proc: ->(value) { value.upcase } })
    expect(BestInPlace::DisplayMethods).to receive(:lookup).with(User, 'name').and_return(renderer)

    put :update, params: { user: { name: 'Lucia' } }, format: :json

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to eq('display_as' => 'LUCIA')
  end

  it 'accepts a custom parameter key' do
    expect(BestInPlace::DisplayMethods).to receive(:lookup).with(User, 'name').and_return(nil)

    put :update, params: { object_param: 'profile', profile: { name: 'Lucia' } }, format: :json

    expect(response).to have_http_status(:no_content)
  end

  it 'returns validation messages with an unprocessable entity status' do
    record.errors.add(:name, "can't be blank")
    expect(BestInPlace::DisplayMethods).not_to receive(:lookup)

    put :update, params: { user: { name: '' } }, format: :json

    expect(response.status).to eq(422)
    expect(JSON.parse(response.body)).to eq(["Name can't be blank"])
  end
end

describe Admin::TestResultsController, type: :controller do
  let(:user) do
    User.create!(name: 'Lucia', last_name: 'Napoli', email: 'lucia@example.com', address: 'Via Roma 99', zip: '25123')
  end

  it 'creates a result and preserves the rooted JSON response' do
    expect do
      post :create, params: { test_result: { name: 'SAT', result: '1700', user_id: user.id } }, format: :json
    end.to change(TestResult, :count).by(1)

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body).fetch('test_result')).to include(
      'id' => TestResult.last.id, 'name' => 'SAT', 'result' => '1700', 'user_id' => user.id
    )
  end

  it 'rejects a result without an associated user with validation messages' do
    expect do
      post :create, params: { test_result: { name: 'SAT', result: '1700' } }, format: :json
    end.not_to change(TestResult, :count)

    expect(response.status).to eq(422)
    expect(JSON.parse(response.body)).to eq(['User must exist'])
  end
end
