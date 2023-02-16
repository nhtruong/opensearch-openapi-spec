# frozen_string_literal: true

require_relative 'operation'

# Group of API endpoints that should be treated as one action
class EndpointGroup
  def initialize(group, src)
    @group = group
    @src = src
  end

  # @param [QueryParamsRepo] repo
  def generate(repo)
    output = {}
    @src.dig('url', 'paths').each do |path|
      path_url = path['path']
      output[path_url] = {}
      path['methods'].each do |method|
        method = method.downcase
        op = Operation.new(@group, path_url, method, @src)
        output[path_url][method] = op.build(repo)
      end
    end
    output
  end
end
