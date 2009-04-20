module RecordFilter
  module DSL
    class Restriction

      attr_reader :column, :negated, :operator, :value

      def initialize(column, negated)
        @column, @negated, @operator = column, negated, nil
      end

      [:equal_to, :is_null, :less_than, :less_than_or_equal_to, :greater_than, :greater_than_or_equal_to, :in, :like].each do |operator|
        define_method(operator) do |*args|
          @value = args[0] 
          @operator = operator
          self
        end
      end

      # Between can take either a tuple of [start, finish], a range, or two values.
      def between(start, finish=nil)
        @operator = :between
        if !finish.nil?
          @value = [start, finish]
        else
          @value = start
        end
      end

      alias_method :gt, :greater_than
      alias_method :gte, :greater_than_or_equal_to
      alias_method :lt, :less_than
      alias_method :lte, :less_than_or_equal_to
      alias_method :null, :is_null
      alias_method :nil, :is_null
    end
  end
end
