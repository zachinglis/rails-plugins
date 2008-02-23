module ActionView
  module Helpers
    module FormHelper
      # Displays a fieldset and if specified a legend with it.
      def fieldset(legend=nil, &block)
        raise ArgumentError, "Missing block" unless block_given?

        inner = capture(&block)
        inner = content_tag("legend", legend) + inner unless legend.nil?
        concat "
        #{content_tag "fieldset" do
            inner
        end}", block.binding
      end
    end
  end
end