require 'dry-equalizer'
require 'dry/view/scope'

module Dry
  module View
    class Part
      include Dry::Equalizer(:_name, :_value, :_context, :_renderer)

      attr_reader :_name
      attr_reader :_value
      attr_reader :_context
      attr_reader :_renderer

      def initialize(name:, value:, renderer:, context: nil)
        @_name = name
        @_value = value
        @_context = context
        @_renderer = renderer
      end

      def __render(partial_name, as: _name, **locals, &block)
        _renderer.render(
          __partial(partial_name),
          __render_scope(as, **locals),
          &block
        )
      end
      alias_method :render, :__render

      def to_s
        _value.to_s
      end

      private

      def method_missing(name, *args, &block)
        if _value.respond_to?(name)
          _value.public_send(name, *args, &block)
        elsif _value.is_a?(Hash) && _value.key?(name)
          _value[name]
        else
          super
        end
      end

      def __partial(name)
        _renderer.lookup("_#{name}")
      end

      def __render_scope(name, **locals)
        Scope.new(
          locals: locals.merge(name => self),
          context: _context,
          renderer: _renderer,
        )
      end
    end
  end
end
