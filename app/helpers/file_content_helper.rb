module FileContentHelper
  private # helper methods are not controller actions!

  def posieve_check_rules_fill_cache(file_content)
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

  # file_content is an instance of FileContent model class
  def posieve_check_rules(file_content)
    # TODO: invalidate cache regularly (to follow updates of rules), e.g. at rule updates
    if file_content.pology_errors_cache.nil? or file_content.pology_errors_cache.empty? or
        file_content.updated_at < Time.now - 1.day # force update every day
      posieve_check_rules_fill_cache(file_content)
    end

    YAML.load(file_content.pology_errors_cache)
  end

  def posieve_check_rules_count(file_content)
    if file_content.pology_errors_cache.nil? or file_content.pology_errors_cache.empty? or
        file_content.updated_at < Time.now - 1.day # force update every day
      posieve_check_rules_fill_cache(file_content)
    end

    puts "file_content.pology_errors_count_cache:"
    p file_content.pology_errors_count_cache
    file_content.pology_errors_count_cache
  end
end
