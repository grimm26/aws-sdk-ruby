module AwsSdkCodeGenerator
  module Views
    class ResourceClass < View

      def initialize(options)
        @module_name = options.fetch(:module_name).split('::').last
        @class_name = options.fetch(:class_name)
        api = options.fetch(:api)
        resource = options.fetch(:resource)
        @identifiers = ResourceIdentifier.build_list(resource)
        @identifiers_method = ResourceIdentifiersMethod.build(@identifiers)
        @data_attributes = ResourceAttribute.build_list(resource, api)
        @load_method = ResourceLoadMethod.build(@class_name, resource) if resource['load']
        @client_load_method = Underscore.underscore(resource['load']['request']['operation']) if resource['load']
        @data_class = "Types::#{resource['shape']}"
        @waiters = ResourceWaiter.build_list(resource, options[:waiters])
        @actions = ResourceAction.build_list(@class_name, resource, api)
        @associations = build_associations(options)
        @batch_actions = ResourceBatchAction.build_list(@class_name, resource, api)
      end

      # @return [String]
      attr_reader :module_name

      # @return [String]
      attr_reader :class_name

      # @return [Array<ResourceIdentifier>]
      attr_reader :identifiers

      # @return [String]
      attr_reader :identifiers_method

      # @return [Array<ResourceAttribute>]
      attr_reader :data_attributes

      # @return [String]
      attr_reader :data_class

      # @return [String]
      attr_reader :load_method

      # @return [String, nil]
      attr_reader :client_load_method

      # @return [Array<Waiter>]
      attr_reader :waiters

      # @return [Array<ResourceAction>]
      attr_reader :actions

      # @return [Array<ResourceAssociation>]
      attr_reader :associations

      # @return [Array<ResourceBatchAction>]
      attr_reader :batch_actions

      # @return [Boolean]
      def waiters?
        !@waiters.empty?
      end

      # @return [ResoruceWiater, nil]
      def exists_waiter
        @waiters.find { |w| w.name == 'exists' }
      end

      # @return [Boolean]
      def actions?
        actions.size > 0
      end

      # @return [Boolean]
      def associations?
        associations.size > 0
      end

      # @return [Boolean]
      def batch_actions?
        batch_actions.size > 0
      end

      private

      def build_associations(options)
        ResourceAssociation.build_list(
          class_name: options.fetch(:class_name),
          resource: options.fetch(:resource),
          api: options.fetch(:api),
          paginators: options.fetch(:paginators)
        )
      end

    end
  end
end
