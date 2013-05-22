class TrustCommerce
  class TrusteeMerchantHost
    class Error < StandardError
      attr_accessor :error

      def initialize(params)
        if params.blank?
          @error = "The response was blank."
        elsif !params.is_a?(Hash)
          @error = "The response was malformed."
        elsif params['status'] == 'baddata'
          @error = "Bad Data: #{params['offenders']}"
        elsif params['status'] == 'error'
          @error = "Error: #{params['offenders']}"
        else
          @error = "There was a problem with the TrustCommerce request. #{params.inspect}"
        end
      end

      def to_s
        @error
      end
    end

    attr_accessor :returnurl

    def self.token(action, options = {})
      conn = Faraday.new(:url => "https://#{API_SETTINGS[:domain]}") do |faraday|
        faraday.adapter Faraday.default_adapter
        faraday.request :url_encoded
      end

      conn.post '/trusteemerchanthost/token.php' do |faraday|
        faraday.params['custid']    = TrustCommerce.custid
        faraday.params['password']  = TrustCommerce.password
        faraday.params['action']    = action.to_s
        faraday.params['returnurl'] = options[:returnurl]
      end.body
    end

    def self.complete(params, options = {})
      conn = Faraday.new(:url => "https://#{API_SETTINGS[:domain]}") do |faraday|
        faraday.adapter Faraday.default_adapter
        faraday.request :url_encoded
      end

      response = conn.post '/trusteemerchanthost/complete.php' do |faraday|
        faraday.params['token']     = params['token']
        faraday.params['password']  = TrustCommerce.password
        faraday.params['action']    = params['action']
      end

      parsed_response = parse_response(response.body)

      if success?(parsed_response)
        parsed_response
      else
        raise Error.new(parsed_response)
      end
    end

    def self.validate_redirect(params)
      ret = false

      if /(.*)&hash=(\w+)$/.match(params)
        digest = OpenSSL::HMAC.hexdigest('sha1', TrustCommerce.password, $1)
        ret = digest.to_s == $2
      end

      ret
    end

    private
      def self.parse_response(response)
        data = {}

        response.each_line do |line|
          param, val = line.split('=')
          data[param] = val.chomp
        end

        data
      end

      def self.success?(response)
        response.is_a?(Hash) && (response['status'] == 'accepted' || response['status'] == 'approved')
      end


  end
end