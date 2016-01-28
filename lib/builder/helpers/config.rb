module Builder::Helpers
  module Config
    def nodes
      Builder.recipe[:nodes]
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
  end
end
