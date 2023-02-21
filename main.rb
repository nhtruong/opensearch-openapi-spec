require_relative './converter/converter'

input_folder = Pathname(Dir.pwd).join('json_schema_spec/api')

output_folder = Pathname(Dir.pwd).join('openapi_spec/yaml')
output_folder.mkdir unless output_folder.exist?
Converter.new(input_folder, output_folder, format: :yaml).generate

output_folder = Pathname(Dir.pwd).join('openapi_spec/json')
output_folder.mkdir unless output_folder.exist?
con = Converter.new(input_folder, output_folder, format: :json)
con.generate
puts con.operation_count
