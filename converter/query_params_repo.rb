# frozen_string_literal: true

require_relative 'param_converter'

# Repository for shared query string params
class QueryParamsRepo
  attr_reader :repo, :format

  def initialize(format = :yaml)
    @format = format
    @repo = {}
  end

  def generate
    repo.to_a.sort_by(&:first).to_h do |name, src|
      [name, convert_param('query', name, src, @format)]
    end
  end

  def process(name, info)
    # raise collision_message(name, info) if repo.include?(name) && repo[name] != info

    repo[name] = info
    reference name
  end

  def reference(name)
    "../parameters/query.#{@format}#/#{name}"
  end

  def collision_message(name, info)
    "#{name} has already been used \n" \
      "#{info.to_json} \n" \
      "#{repo[name].to_json} \n"
  end
end
