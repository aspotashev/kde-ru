module FileContentHelper
  private # helper methods are not controller actions!

  def posieve_check_rules_fill_cache(file_content)
    Stalker.enqueue("pology_check", :file_content_id => file_content.id)
  end

  # file_content is an instance of FileContent model class
  def posieve_check_rules(file_content)
    # TODO: invalidate cache regularly (to follow updates of rules), e.g. at rule updates
    if file_content.pology_errors_cache.nil? or file_content.pology_errors_cache.empty? or
        file_content.updated_at < Time.now - 1.day # force update every day
      posieve_check_rules_fill_cache(file_content)
    end

    if file_content.pology_check_done?
      YAML.load(file_content.pology_errors_cache)
    else
      nil
    end
  end

  def posieve_check_rules_count(file_content)
    if not file_content.pology_check_done? or
        file_content.updated_at < Time.now - 1.day # force update every day
      posieve_check_rules_fill_cache(file_content)
    end

    file_content.pology_errors_count_cache
  end
end
