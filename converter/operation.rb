# frozen_string_literal: true

require_relative 'query_params_repo'
require_relative 'param_converter'

# OpenAPI Operation
class Operation
  def initialize(group, path, method, src)
    @group = group
    @path = path
    @method = method
    @src = src
  end

  # @param [QueryParamsRepo] repo
  def build(repo)
    { 'x-endpoint-group': @group,
      description: @src.dig('documentation', 'description'),
      deprecated: @src['deprecated'],
      parameters: parse_params(repo),
      requestBody: parse_body }.compact
  end

  private

  # @param [QueryParamsRepo] repo
  def parse_params(repo)
    params = []

    @src.dig('url', 'paths').find { |p| p['path'] == @path }['parts']&.each do |k, v|
      params.append convert_param('path', k, v, repo.format)
    end

    @src['params']&.each { |k, v| params.append({ '$ref': repo.process(k, v) }) }
    params
  end

  def parse_body
    body = @src['body']
    return nil if %w[put post].exclude?(@method) || body.nil?

    { description: body['description'],
      required: !!body['required'],
      content: {
        'application/json': {
          schema: {
            type: 'object'
          }
        }
      } }.compact
  end
end
