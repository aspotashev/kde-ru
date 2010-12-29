class FileContentsWorker < Workling::Base
  def pology_check(options)
    file_content = FileContent.find(options[:file_content_id])

    $po_backend.error_hook = lambda {|s| flash[:error] = s }
    if posieve = $po_backend.posieve
      res = posieve.check_rules(file_content.content.to_file.read)

      if res
        file_content.pology_errors_cache = res.to_yaml
        file_content.pology_errors_count_cache = res.size
        file_content.save!
      end
    else
      nil
    end
  end
end
