module RecordFilter
  module DSL
    class DSL < ConjunctionDSL

      # Define an limit and/or offset for the results returned from the current
      # filter. This method can only be called from the outermost scope of a filter
      # (i.e. not inside of a having block, etc.). If it is called multiple times, the
      # last one will override any others.
      #
      # ==== Parameters
      # limit<Integer>::
      #   Used for the limit of the query.
      # offset<Integer>::
      #   Used as the offset for the query. This argument is optional, with the default
      #   being no offset.
      #
      # ==== Returns
      # nil
      #
      # @public
      def limit(limit, offset=nil)
        @conjunction.add_limit(limit)
        @conjunction.add_offset(offset) if offset
        nil
      end

      # Define an offset for the results returned from the current
      # filter. This method can only be called from the outermost scope of a filter
      # (i.e. not inside of a having block, etc.). If it is called multiple times, the
      # last one will override any others.
      #
      # ==== Parameters
      # offset<Integer>::
      #   The offset of the query.
      #
      # ==== Returns
      # nil
      #
      # @public
      def offset(offset)
        @conjunction.add_offset(offset)
        nil
      end

      # Define an order clause for the current query, with options for specifying
      # both the column to use as well as the direction. This method can only be called
      # in the outermost scope of a filter (i.e. not inside of a having block, etc.).
      # Multiple calls will create multiple order clauses in the resulting query, and
      # they will be added in the order in which they were called in the filter. In order
      # to specify ordering on columns added through joins, a hash can be passed as the
      # first argument, specifying a path through the joins to the column, as in this 
      # example:
      #
      #   Blog.filter do
      #     having(:posts) do
      #       having(:comments).with(:created_at).greater_than(3.days.ago)
      #     end
      #     order(:posts => :comments => :created_at, :desc)
      #     order(:id, :asc)
      #   end
      #
      # ==== Parameters
      # column<Symbol, Hash>::
      #   Specify the column for the ordering. If a symbol is given, it is assumed to represent
      #   a column in the class that is being filtered. With a hash argument, it is possible
      #   to specify a path to a column in one of the joined tables, as seen above. If a string
      #   is given and it doesn't match up with a column name, it is used as a literal string
      #   for ordering.
      # direction<Symbol>::
      #   Specifies the direction of the order. Should be either :asc or :desc and defaults to :asc.
      #
      # ==== Returns
      # nil
      #
      # ==== Raises
      # InvalidFilterException::
      #   If the direction is neither :asc nor :desc.
      #
      # ==== Alternatives
      # As described above, it is possible to pass a symbol, a hash or a string as the first
      # argument.
      #
      # @public
      def order(column, direction=:asc)
        unless [:asc, :desc].include?(direction)
          raise InvalidFilterException.new("The direction for orders must be either :asc or :desc but was #{direction}")
        end
        @conjunction.add_order(column, direction)
        nil
      end

      # Specify a group_by clause for the resulting query.  This method can only be called
      # in the outermost scope of a filter (i.e. not inside of a having block, etc.).
      # Multiple calls will create multiple group_by clauses in the resulting query, and
      # they will be added in the order in which they were called in the filter. In order
      # to specify grouping on columns added through joins, a hash can be passed as the
      # argument, specifying a path through the joins to the column, as in this example:
      #
      #   Blog.filter do
      #     having(:posts) do
      #       having(:comments).with(:created_at).greater_than(3.days.ago)
      #     end
      #     group_by(:posts => :comments => :offensive)
      #     group_by(:id)
      #   end
      #
      # ==== Parameters
      # column<Symbol, Hash>::
      #   If a symbol is specified, it is taken to represent the name of a column on the
      #   class being filtered. If a hash is given, it should represent a path through the
      #   joins to a column in one of the joined tables. If a string is given, it is used
      #   without modification as the grouping parameter.
      #
      # ==== Returns
      # nil
      #
      # ==== Alternatives
      # As described above, it is possible to pass either a symbol, a hash, or a string 
      # as the argument.
      #
      # @public
      def group_by(column)
        @conjunction.add_group_by(column)
        nil
      end

      # Specify that the resulting query should select distinct results.  This method 
      # can only be called in the outermost scope of a filter (i.e. not inside of a having 
      # block, etc.).
      #
      # ==== Parameters
      # 
      # columns...<Symbol>:
      #   Zero or more column names to select. Equivalent to
      #   select(:col1, :col2) ; distinct. If empty, select all columns.
      #
      # ==== Returns
      # nil
      #
      # @public
      def distinct(*columns)
        select(*columns) unless columns.empty?
        @conjunction.set_distinct
        nil
      end

      #
      # Specify one or more columns to select from the database.
      #
      def select(*columns)
        @conjunction.set_select_columns(columns)
      end
    end
  end
end
