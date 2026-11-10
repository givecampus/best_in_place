# encoding: utf-8

describe BestInPlace::Utils do
  include BestInPlace::Utils
  describe '#build_best_in_place_id' do
    it 'build id from symbol' do
      expect(build_best_in_place_id(:user, :login)).to eq('best_in_place_user_login')
    end

    it 'builds an id from a string' do
      expect(build_best_in_place_id('custom_user', :login)).to eq('best_in_place_custom_user_login')
    end

    it 'builds an id from a persisted record' do
      car = Cuca::Car.create!
      expect(build_best_in_place_id(car, :model)).to eq("best_in_place_cuca_car_#{car.id}_model")
    end

    it 'omits the record id for a new record' do
      expect(build_best_in_place_id(User.new, :name)).to eq('best_in_place_user_name')
    end
  end

  describe '#object_to_key' do
    it 'uses the model parameter key for a class' do
      expect(object_to_key(User)).to eq('user')
    end

    it 'uses the model parameter key for an instance' do
      expect(object_to_key(User.new)).to eq('user')
    end

    it 'preserves model namespaces' do
      expect(object_to_key(Cuca::Car.new)).to eq('cuca_car')
    end

    it 'unwraps objects exposing to_model' do
      wrapper = double('model wrapper', to_model: User.new)
      expect(object_to_key(wrapper)).to eq('user')
    end
  end

  describe '#convert_to_model' do
    it 'leaves objects without to_model unchanged' do
      object = Object.new
      expect(convert_to_model(object)).to equal(object)
    end
  end
end
