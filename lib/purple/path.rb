# frozen_string_literal: true

require 'dry-initializer'

module Purple
  class Path
    extend Dry::Initializer[undefined: false]

    option :client
    option :name
    option :parent
    option :children, default: -> { [] }
    option :method, optional: true
    option :request, optional: true, default: -> { Purple::Request.new }
    option :responses, optional: true, default: -> { [] }

    def full_path
      parent.nil? ? name : "#{parent.full_path}/#{name}"
    end

    def method_missing(method_name, *args, &)
      if children.any? { |child| child.name == method_name }
        children.find { |child| child.name == method_name }
      else
        super
      end
    end

    def execute(params = {}, args = {})
      headers = {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }

      if client.authorization
        authorization = client.authorization[:data].call

        headers.deep_merge!(authorization) if client.authorization[:type].in?(%i[bearer custom_headers])
        params.deep_merge!(authorization) if client.authorization[:type] == :custom_query
      end

      connection = Faraday.new(url: client.domain) do |conn|
        conn.headers = headers
      end

      url = "#{client.domain}/#{full_path}"
      response = case method
                 when :get
                   connection.get(url, params)
                 when :post
                   connection.post(url, params.to_json)
                 end

      resp_structure = responses.find { |resp| resp.status_code == response.status }

      if resp_structure.nil?
        raise "#{client.domain}/#{full_path} returns #{response.status}, but it is not defined in the client"
      else
        object = if resp_structure.body.is_a?(Purple::Responses::Body)
                   resp_structure.body.validate!(response.body, args)
                 elsif resp_structure.body == :default
                   response.body
                 else
                   {}
                 end

        client.callback&.call(url, params, headers, JSON.parse(response.body))

        if block_given?
          yield(resp_structure.status, object)
        else
          object
        end
      end
    end
  end
end
