# frozen_string_literal: true

require 'json'
require 'yaml'
require 'active_support/all'
require_relative 'endpoint_group'
require_relative 'query_params_repo'

# Convert OpenSearch JsonSchema Spec to OpenAPI Spec
class Converter
  def initialize(input_folder, output_folder, format = 'yaml')
    @input_folder = Pathname.new input_folder
    @output_folder = Pathname.new output_folder
    @format = format
    @query_params_repo = QueryParamsRepo.new
  end

  def generate
    generate_endpoint_groups
    generate_root
    generate_shared_params
    generate_shared_schemas
  end

  def generate_endpoint_groups
    output = create_folder 'paths'
    @input_folder.children.each do |file|
      JSON.parse(file.read).each do |name, src|
        open_api_data = EndpointGroup.new(name, src).generate(@query_params_repo)
        dump output, name, open_api_data
      end
    end
  end

  def generate_root; end

  def generate_shared_schemas
    output = create_folder 'schemas'
    schemas = {
      time: {
        type: :string,
        pattern: '^([0-9]+)(?:d|h|m|s|ms|micros|nanos)$'
      }
    }
    dump output, '_common', schemas
  end

  def generate_shared_params
    output = create_folder 'parameters'
    dump output, 'query', @query_params_repo.generate
  end

  private

  def dump(folder, filename, d)
    filename = @format == 'yaml' ? "#{filename}.yaml" : "#{filename}.json"
    content = @format == 'yaml' ? YAML.dump(d.deep_stringify_keys).gsub('"$ref"', '$ref') : JSON.pretty_generate(d)
    folder.join(filename).write(content)
  end

  def create_folder(name)
    folder = @output_folder.join name
    Dir.mkdir folder unless folder.exist?
    folder
  end
end
