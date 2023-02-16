# frozen_string_literal: true

# OpenAPI Parameter Converter
class ParamConverter
  def initialize(loc, name, src)
    @loc = loc
    @name = name
    @src = src
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
    return { '$ref': '../schemas/_common.yaml#/time' } if @src['type'] == 'time'

    { type: data_type,
      enum: @src['type'] == 'enum' ? @src['options'] : nil,
      items: @src['type'] == 'array' ? { type: 'string' } : nil,
      minItems: @src['type'] == 'array' ? 1 : nil }.compact
  end

  def data_type
    case @src['type']
    when 'number' then 'integer'
    when 'list' then 'array'
    when 'time', 'enum' then 'string'
    else @src['type']
    end
  end
end

def convert_param(loc, name, src)
  ParamConverter.new(loc, name, src).convert
rescue StandardError => e
  pp loc, name, src
  raise e
end
