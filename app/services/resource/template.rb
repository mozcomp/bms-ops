module Resource
  class Template < Base
    def initialize(path)
      @path = path
      if path.extname == ".json"
        @content = symbolize_recursive(load_json(path))
      elsif path.extname == ".yml"
        @content = symbolize_recursive(load_yaml(path))
      end
    end

    def content
      @content
    end

    def environment_variables
      @content[:environment] || {}
    end

    def save
      @path = Pathname.new(@path.parent.join(@path.basename.to_s.gsub(/json/, "yml")))
      save_yaml(@path.parent, @path.basename, @content)
    end
  end
end
