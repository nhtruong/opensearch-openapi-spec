# frozen_string_literal: true

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

  def generate_root; end
  def generate_endpoint_groups; end
  def generate_shared_params; end
end
