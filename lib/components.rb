require "components/version"

module Components
  class Engine < Rails::Engine
    initializer "Components: static assets" do |app|
      app.middleware.use(::ActionDispatch::Static, "#{ config.root }/public")
    end
  end
end
