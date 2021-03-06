module Brightcontent
  module ViewLookup
    class FilterField < Abstract
      def render_default
        raise "invalid filter field: #{options[:field]}" unless field_name
        [
          options[:form].label(:"#{field_name}_eq", options[:field].humanize),
          options[:form].select(:"#{field_name}_eq", select_options, {include_blank: true}, class: "form-control input-sm")
        ].join(" ").html_safe
      end

      def field_type
        resource_class.columns_hash[options[:field]].try :type
      end

      private

      def field?
        resource_class.column_names.include? options[:field].to_s
      end

      def belongs_to_association?
        association.try :belongs_to?
      end

      def field_name
        if field?
          options[:field]
        elsif belongs_to_association?
          association.foreign_key
        end
      end

      def select_options
        if field?
          field_type == :boolean ? raw_options : raw_options.sort
        elsif belongs_to_association?
          association.klass.where(association.association_primary_key => raw_options).map do |record|
            [record, record[association.association_primary_key]]
          end
        end
      end

      def raw_options
        resource_class.uniq.pluck(field_name)
      end

      def association
        resource_class.reflect_on_association options[:field].to_sym
      end

      def resource_class
        view_context.send :resource_class
      end
    end
  end
end
