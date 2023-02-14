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
  end

  def generate_endpoint_groups
    output = @output_folder.join 'paths'
    Dir.mkdir output unless output.exist?
    @input_folder.children.each do |file|
      JSON.parse(file.read).each do |name, src|
        open_api_data = EndpointGroup.new(name, src).generate(@query_params_repo)
        dump(output, name, open_api_data)
      end
    end
  end

  def generate_root; end
  def generate_shared_params; end

  private

  def dump(folder, filename, d)
    filename = @format == 'yaml' ? "#{filename}.yaml" : "#{filename}.json"
    content = @format == 'yaml' ? YAML.dump(d.deep_stringify_keys).gsub('"$ref"', '$ref') : JSON.pretty_generate(d)
    folder.join(filename).write(content)
  end
end
