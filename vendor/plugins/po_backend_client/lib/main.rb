# Po-backend-client

require 'drb'

$po_backend = DRbObject.new nil, 'druby://:9000'

class Object
  def singleton_class
    (class << self ; self ; end) rescue nil
  end
end

$po_backend.singleton_class.class_eval do
  attr_accessor :error_hook

  def method_missing_patched(*args)
    begin
      method_missing_orig(*args)
    rescue
      puts 'Could not connect to DRb server.'
      p @error_hook
      @error_hook['Could not connect to DRb server.'] if @error_hook
      nil
    end
  end

  alias method_missing_orig method_missing
  alias method_missing method_missing_patched
end

