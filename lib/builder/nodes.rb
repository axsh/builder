require 'builder'

module Builder
  class Nodes
    class << self
      def list_to_provision
        nodes.inject([]) do |nodes_to_provision, (key, value)|
          if value.include?(:provision)
            nodes_to_provision << key
          end
          nodes_to_provision
        end
      end

      private

      def nodes
        Builder.recipe[:nodes]
      end
    end
  end
end
