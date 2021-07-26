class RequestContext
  class << self
    def fetch
      Thread.current[:context] || clear!
    end

    def clear!
      Thread.current[:context] = {}
    end

    def redis
      $redis = Redis.new(url: ENV['REDIS_URL'], driver: :ruby, ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
    rescue NoMethodError
      raise LoadError, "You don't appear to have any Redis config in config/database.yml"
    end

    %i[user community].each do |field|
      define_method "#{field}=" do |value|
        fetch[field] = value
      end

      define_method field do
        fetch[field]
      end

      define_method "#{field}_id" do
        fetch[field]&.id
      end
    end
  end
end
