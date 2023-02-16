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
    @paths = {}
  end

  def generate
    generate_paths
    generate_shared_params
    generate_shared_schemas
    generate_root
  end

  def generate_paths
    output = create_folder 'paths'
    @input_folder.children.each do |file|
      JSON.parse(file.read).each do |group, src|
        @paths.deep_merge! EndpointGroup.new(group, src).generate(@query_params_repo)
      end
    end

    @paths.each { |path, content| dump output, path_filename(path), content }
  end

  def generate_root
    content = {
      openapi: '3.1.0',
      info: { title: 'OpenSearch', version: '2.5' },
      paths: @paths.keys.sort.each_with_object({}) do |path, paths|
        paths[path] = { '$ref': "./paths/#{path_filename path}.#{@format}" }
      end
    }
    dump @output_folder, 'opensearch.openapi', content
  end

  def generate_shared_schemas
    output = create_folder 'schemas'
    schemas = {
      time: {
        type: 'string',
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

  def path_filename(path)
    path = path[1..]
    path = '_' if path == ''
    path.gsub('/', '.').gsub('{', '(').gsub('}', ')')
  end

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
