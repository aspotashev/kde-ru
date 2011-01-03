
class IndexSearch
  def self.request(s,n)
#    p s
#    p n
#    p find(s,n)

    $po_backend.isearch.find(s,n).map do |id|
      r = id.split(':')
      [r[0], r[1].to_i]
    end
  end

  def self.db_config
    YAML::load(File.open('/home/sasha/python-l10n-db-server/generate-dump/database.yml'))
  end
end

