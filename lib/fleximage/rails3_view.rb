module Fleximage
  class Rails3View

    class TemplateDidNotReturnImage < RuntimeError #:nodoc:
    end
    
    def self.call(template, source = nil)
      source ||= template.source
      self.new.compile(template, source)
    end

    def compile(template, source)
      <<-CODE
      @template_format = :flexi
      controller.response.content_type ||= Mime[:jpg]
      result = #{source}
      requested_format = (params[:format] || :jpg).to_sym
      begin
        # Raise an error if object returned from template is not an image record
        unless result.class.include?(Fleximage::Model::InstanceMethods)
          raise TemplateDidNotReturnImage, ".flexi template was expected to return a model instance that acts_as_fleximage, but got an instance of instead."
        end
        # Figure out the proper format
        raise 'Image must be requested with an image type format.  jpg, gif and png only are supported.' unless [:jpg, :gif, :png, :webp].include?(requested_format)

        x = result.output_image(:format => requested_format)
        #puts x.inspect
        x
      rescue Exception => e
        e
      end
      CODE
    ensure
      #JL GC.start
    end

  end
end
