module Builder::Helpers
  module Config
    def nodes
      Builder.recipe[:nodes]
    end

    def node_spec(name)
      nodes[name][:provision][:spec]
    end

    def config
      Builder.config
    end
  end
end
