module BlacklightHierarchy
  module HierarchicalFacets
    class FacetItem
      attr_reader :qname, :hits
  
      def initialize(qname, hits, facet)
        @qname = qname
        @hits = hits
        @facet = facet
      end
  
      def [](value)
        @facet.facets([qname,value].select(&:present?).join(@facet.delimiter))
      end

      def each_pair
        keys.each { |k| yield k, self[k] }
      end
  
      def keys
        @facet.keys(qname)
      end

      def path
        @qname.split(@facet.delimiter)[0..-2]
      end
  
      def name
        @qname.split(@facet.delimiter).last
      end
  
      def inspect
        "#<#{self.class.name}:#{name}=>#{hits.inspect} (#{keys.join ', '})>"
      end
    end

    class FacetGroup
      attr_reader :facet_data, :qname, :hits, :delimiter
      include Enumerable
  
      def initialize(facet_data, delimiter=":")
        @facet_data = Hash[*facet_data]
        @delimiter = delimiter
      end
  
      def each &block
        facets.each &block
      end
  
      def each_pair
        facets.each { |f| yield f.name, f }
      end
  
      def keys(prefix=nil)
        if prefix.nil?
          facet_data.collect { |k,v| k.split(delimiter).first }.uniq
        else
          path = prefix.to_s.split(delimiter)
          facet_data.collect do |k,v|
            facet_path = k.split(delimiter)
            facet_path[0..path.length-1] == path ? facet_path[path.length] : nil
          end.compact.uniq
        end
      end
  
      def facets(prefix=nil)
        FacetItem.new(prefix.to_s,facet_data[prefix],self)
      end
  
      def [](value)
        facets(value)
      end
    end
  end
end