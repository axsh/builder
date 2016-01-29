module Builder::Helpers
  module Config
    def recipe
      Builder.recipe[:nodes]
    end

    def nodes
      recipe[:nodes]
    end

    def node_spec(name)
      nodes[name][:provision][:spec]
    end

    def networks
      Builder.recipe[:networks]
    end

    def network_spec(name)
      networks[name]
    end

    def bridge_addif_cmd(type)
      case type
      when 'ovs'
        'add-port'
      when 'linux'
        'addif'
      else
        raise "invalid_type_error"
      end
    end

    def bridge_cmd(type)
      case type
      when 'ovs'
        'ovs-vsctl'
      when 'linux'
        'brctl'
      else
        raise "invalid_type_error"
      end
    end

    def config
      Builder.config
    end

    def recipe_save
      File.open("builder.yml", "w") do |f|
        f.write recipe.to_yaml
      end
    end

    def config_save
      File.open(".builder", "w") do |f|
        f.write config.to_yaml
      end
    end
  end
end
