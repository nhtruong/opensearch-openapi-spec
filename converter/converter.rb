# frozen_string_literal: true

require 'json'
require 'yaml'
require 'active_support/all'
require_relative 'endpoint_group'
require_relative 'query_params_repo'

# Convert OpenSearch JsonSchema Spec to OpenAPI Spec
class Converter
  attr_reader :operation_count

  def initialize(input_folder, output_folder, format: :yaml)
    @input_folder = Pathname.new input_folder
    @output_folder = Pathname.new output_folder
    @format = format
    @query_params_repo = QueryParamsRepo.new @format
    @paths = {}
    @operation_count = 0
  end

  def generate
    generate_paths
    generate_query_params
    generate_shared_schemas
    generate_root
  end

  def generate_paths
    folder = create_folder 'paths'
    @input_folder.children.each do |file|
      JSON.parse(file.read).each do |group, src|
        endpoint_group = EndpointGroup.new(group, src)
        @paths.deep_merge! endpoint_group.generate(@query_params_repo)
        @operation_count += endpoint_group.count
      end
    end

    @paths.each { |path, content| dump folder, path_filename(path), content }
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
    schemas = {
      time: {
        type: 'string',
        pattern: '^([0-9]+)(?:d|h|m|s|ms|micros|nanos)$'
      },
      string_array: {
        type: 'array',
        items: { type: 'string' },
        minItems: 1
      }
    }
    dump create_folder('schemas'), '_common', schemas
  end

  def generate_query_params
    dump create_folder('parameters'), 'query', @query_params_repo.generate
  end

  private

  def path_filename(path)
    path = path[1..]
    path = '_' if path == ''
    path.gsub('/', '.').gsub('{', '(').gsub('}', ')')
  end

  def dump(folder, filename, data)
    yaml = @format.downcase.to_sym == :yaml
    filename = yaml ? "#{filename}.yaml" : "#{filename}.json"
    content = yaml ? YAML.dump(data.deep_stringify_keys).gsub('"$ref"', '$ref') : JSON.pretty_generate(data)
    folder.join(filename).write(content)
  end

  def create_folder(name)
    folder = @output_folder.join name
    folder.rmtree if folder.exist?
    folder.mkdir unless folder.exist?
    folder
  end
end
