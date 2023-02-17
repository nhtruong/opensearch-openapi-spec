# frozen_string_literal: true

# OpenAPI Parameter Converter
class ParamConverter
  def initialize(loc, name, src, format)
    @loc = loc
    @name = name
    @src = src
    @format = format
  end

  def convert
    dep = @src['deprecated']
    {
      in: @loc,
      name: @name,
      description: @src['description'],
      required: @loc == 'path' ? true : @src['required'],
      deprecated: (!!dep unless dep.nil?),
      'x-deprecation-version': (dep['version'] if dep.is_a?(Hash)),
      'x-deprecation-description': (dep['description'] if dep.is_a?(Hash)),
      schema:
    }.compact
  end

  private

  def schema
    return { '$ref': "../schemas/_common.#{@format}#/time" } if @src['type'] == 'time'
    return { '$ref': "../schemas/_common.#{@format}#/string_array" } if @src['type'] == 'list'

    { type: data_type,
      enum: @src['type'] == 'enum' ? @src['options'] : nil }.compact
  end

  def data_type
    case @src['type']
    when 'number' then 'integer'
    when 'list' then 'array'
    when 'boolean' then 'boolean'
    when 'time', 'enum', 'string' then 'string'
    when 'number|string' then %w[integer string]
    else raise "Unrecognized Data Type: #{@src['type']}"
    end
  end
end

def convert_param(loc, name, src, format)
  ParamConverter.new(loc, name, src, format).convert
rescue StandardError => e
  pp loc, name, src
  raise e
end
