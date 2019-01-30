module Orders
  class OrderNumberGenerator
    def call
      "#{Time.now.year}-#{Time.now.month}-#{Time.now.day}-#{SecureRandom.hex(10)}"
    end
  end
end
