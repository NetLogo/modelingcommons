# Disable Paperclip.  Paperclip is a major security problem, since it
# sends filenames to ImageMagick through the shell, to check which file
# extension should be attached to the uploaded file.  --Jason B. (2/9/26)
module PaperclipStub
  class DummyAttachment
    attr_reader :name, :instance

    def initialize(name, instance)
      @name = name
      @instance = instance
    end

    def url(style_name = nil)
      file_name_method = "#{name}_file_name"

      if instance.respond_to?(file_name_method)
        file_name = instance.send(file_name_method)

        if file_name.present?
          style = style_name || 'original'
          return "/system/#{name}/#{instance.id}/#{style}/#{file_name}"
        end
      end

      style = style_name || 'original'
      "/assets/default-person/#{style}/default-person.png"
    end

    def path(style_name = nil)
      file_name_method = "#{name}_file_name"

      if instance.respond_to?(file_name_method)
        file_name = instance.send(file_name_method)

        if file_name.present?
          style = style_name || 'original'
          return "#{Rails.root}/public/system/#{name}/#{instance.id}/#{style}/#{file_name}"
        end
      end

      nil
    end

    def present?
      file_name_method = "#{name}_file_name"
      instance.respond_to?(file_name_method) && instance.send(file_name_method).present?
    end

    def blank?
      !present?
    end

    def exists?(style_name = nil)
      return false unless present?

      file_path = path(style_name)
      file_path && File.exist?(file_path)
    end

    def size
      file_name_method = "#{name}_file_size"
      if instance.respond_to?(file_name_method)
        instance.send(file_name_method) || 0
      else
        0
      end
    end

    def content_type
      content_type_method = "#{name}_content_type"
      if instance.respond_to?(content_type_method)
        instance.send(content_type_method)
      else
        nil
      end
    end

    def original_filename
      file_name_method = "#{name}_file_name"
      if instance.respond_to?(file_name_method)
        instance.send(file_name_method)
      else
        nil
      end
    end

    def dirty?
      false
    end

    def to_s
      original_filename || ""
    end
  end

  module ClassMethods
    def has_attached_file(name, options = {})
      Rails.logger.info "Paperclip stub: ignoring has_attached_file :#{name} on #{self.name}"

      class_variable_set("@@_paperclip_options_#{name}", options)

      define_method(name) do
        instance_var = "@_paperclip_stub_#{name}"
        instance_variable_get(instance_var) ||
          instance_variable_set(instance_var, PaperclipStub::DummyAttachment.new(name, self))
      end

      define_method("#{name}=") do |uploaded_file|
        Rails.logger.warn "Paperclip stub: BLOCKING upload to #{name} (uploads disabled)"
        nil
      end

      define_method("#{name}?") do
        file_name_attr = "#{name}_file_name"
        respond_to?(file_name_attr) && send(file_name_attr).present?
      end

      define_method("#{name}_url") do |style_name = nil|
        opts = self.class.class_variable_get("@@_paperclip_options_#{name}") rescue {}

        file_name_attr = "#{name}_file_name"

        if respond_to?(file_name_attr) && send(file_name_attr).present?
          file_name = send(file_name_attr)
          style = style_name || 'original'

          if opts[:url]
            url_pattern = opts[:url]
            url_pattern.gsub(':attachment', name.to_s)
                      .gsub(':id', id.to_s)
                      .gsub(':style', style.to_s)
                      .gsub(':filename', file_name.to_s)
          else
            "/system/#{name}/#{id}/#{style}/#{file_name}"
          end
        else
          default_url = opts[:default_url]

          if default_url
            default_url.gsub(':style', (style_name || 'original').to_s)
                      .gsub(':attachment', name.to_s)
          else
            "/assets/default-#{name}.png"
          end
        end
      end

      unless method_defined?("#{name}_file_name")
        define_method("#{name}_file_name") do
          read_attribute("#{name}_file_name") rescue nil
        end
      end

      unless method_defined?("#{name}_file_name=")
        define_method("#{name}_file_name=") do |value|
          write_attribute("#{name}_file_name", value) rescue nil
        end
      end
    end

    def validates_attachment(*args)
      Rails.logger.info "Paperclip stub: ignoring validates_attachment on #{self.name}"
      true
    end

    def validates_attachment_presence(*args)
      Rails.logger.info "Paperclip stub: ignoring validates_attachment_presence"
      true
    end

    def validates_attachment_content_type(*args)
      Rails.logger.info "Paperclip stub: ignoring validates_attachment_content_type"
      true
    end

    def validates_attachment_size(*args)
      Rails.logger.info "Paperclip stub: ignoring validates_attachment_size"
      true
    end
  end
end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend(PaperclipStub::ClassMethods)
end

Rails.logger.warn "⚠️  PAPERCLIP UPLOADS DISABLED - Existing images will still be served, but new uploads are blocked"
