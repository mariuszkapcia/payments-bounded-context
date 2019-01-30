path = Rails.root.join('fulfilment/spec')
Dir.glob("#{path}/**/*_spec.rb") do |file|
  require file
end
