# frozen_string_literal: true

# Repository for shared query string params
class QueryParamsRepo
  attr_reader :repo

  def initialize
    @repo = {}
  end

  def process(name, info)
    # raise collision_message(name, info) if repo.include?(name) && repo[name] != info

    repo[name] = info
    reference name
  end

  def reference(name)
    "Params/TBD/#{name}"
  end

  def collision_message(name, info)
    "#{name} has already been used \n" \
      "#{info.to_json} \n" \
      "#{repo[name].to_json} \n"
  end
end
