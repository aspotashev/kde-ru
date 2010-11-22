module FileContentHelper
  # file_content is an instance of FileContent model class
  def posieve_check_rules(file_content)
    $po_backend.error_hook = lambda {|s| flash[:error] = s }
    if posieve = $po_backend.posieve
      posieve.check_rules(file_content.content.to_file.read)
    else
      nil
    end
  end
end
