# Notice, put back a few revisions until the problems are fixed.
module ActiveRecord
  class Errors
    def full_messages
      full_messages = []

      @errors.each_key do |attr|
        @errors[attr].each do |msg|
          next if msg.nil?

          if attr == "base"
            full_messages << msg
          else
            link = @base.class.name + "_"+ @base.class.human_attribute_name(attr)
            full_messages << "<a href=\"#" + link.downcase + "\">" + @base.class.human_attribute_name(attr) + "</a> " + msg
          end
        end
      end
      full_messages
    end
  end
end