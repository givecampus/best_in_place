require 'rails/railtie'
require 'action_view/base'

module BestInPlace
  class Railtie < ::Rails::Railtie #:nodoc:
    initializer 'best_in_place.deprecator', before: :load_environment_config do |app|
      app.deprecators[:best_in_place] = BestInPlace.deprecator if app.respond_to?(:deprecators)
    end

    config.after_initialize do
      BestInPlace::ViewHelpers = ActionView::Base.new({}, {}, "")
    end
  end
end
