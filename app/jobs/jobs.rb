require File.expand_path("../../../config/environment", __FILE__)

job "pology_check" do |options|
  puts "~~~~~~~~~~~~~~~ inside worker ~~~~~~~~~~~~~~~~~~"

  file_content = FileContent.find(options['file_content_id'])
  if not file_content.pology_check_done? or
    file_content.updated_at < Time.now - 1.day # force update every day

#    $po_backend.error_hook = lambda {|s| flash[:error] = s }
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

