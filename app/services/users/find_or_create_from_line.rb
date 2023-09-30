module Users
  class FindOrCreateFromLine
    def initialize(name:, line_id:)
      @name = name
      @line_id = line_id
    end

    def run
      oauth_provider = OauthProvider.find_or_create_by(provider: "line", uid: @line_id)
      oauth_provider.name = @name
      oauth_provider.user ||= User.create(email: "#{Time.current.to_i}@fake.mail")
      oauth_provider.save
      oauth_provider.user
    end
  end
end
