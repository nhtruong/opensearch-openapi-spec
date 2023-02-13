# frozen_string_literal: true

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
    {
      @method.downcase.to_sym => {
        'x-endpoint-group': @group,
        description: @src.dig('documentation', 'description'),
        parameters: parse_params(repo),
        requestBody: parse_body
      }.compact
    }
  end

  private

  # @param [QueryParamsRepo] repo
  def parse_params(repo)
    params = []
    src.dig('url', 'paths').find { |p| p['path'] == @path }['parts'].each do |k, v|
      #
    end
    src['params'].each { |k, v| @params.append({ '$ref': repo.process(k, v) }) }
    params
  end

  def parse_body
    body = src['body']
    return nil if %w[PUT POST].exclude?(@method) || body.nil?

    {
      description: body['description'],
      required: !!body['required'],
      content: { '$ref': 'Content/TBD/genericJsonBody' }
    }
  end
end
