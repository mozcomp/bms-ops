require "pathname"
require "yaml"

module Resource
  class Base
    include AwsService

    private

    def load_yaml(path)
      return Hash.new({}) unless File.exist?(path)
      data = YAML.unsafe_load_file(path)
      symbolize_recursive(data)
    end

    def load_json(path)
      return Hash.new({}) unless File.exist?(path)
      data = JSON.parse(File.new(path).read)
      # If key is is accidentally set to nil it screws up the merge_base later.
      # So ensure that all keys with nil value are set to {}
      data.each do |env, _setting|
        data[env] ||= {}
      end
      symbolize_recursive(data)
    end

    def save_json(path, filename, data)
      path.parent.mkdir unless path.parent.exist?
      path.mkdir unless path.exist?
      File.open(path.join(filename), "wt") do |file|
        file.write(JSON.pretty_generate(stringify_recursive(data).to_hash))
      end
    end

    def save_yaml(path, filename, data)
      path.parent.mkdir unless path.parent.exist?
      path.mkdir unless path.exist?
      File.open(path.join(filename), "wt") do |file|
        file.write(stringify_recursive(data).to_yaml)
      end
    end

    def stringify_recursive(hash)
      {}.tap do |h|
        hash.each { |key, value| h[key.to_s] = transform(value, :stringify) }
      end
    end

    def symbolize_recursive(hash)
      {}.tap do |h|
        hash.each { |key, value| h[key.to_sym] = transform(value, :symbolize) }
      end
    end

    def transform(thing, action)
      case thing
      when Hash
        if action == :stringify
          stringify_recursive(thing)
        elsif action == :symbolize
          symbolize_recursive(thing)
        end
      when Array; thing.map { |v| transform(v, action) }
      else; thing
      end
    end
  end
end
