
conf = YAML::load(File.open(File.dirname(__FILE__) + '/../config.yml'))
$isearch_conf_yaml = conf # workaround to pass 'conf' into class IndexSearch

require conf['binary_ruby_module']
IndexSearch.init(conf['dump'], conf['dump_index'], conf['dump_map'])

IndexSearch.class_eval do
  def self.request(s,n)
    p s
    p n
    p find(s,n)

    find(s,n).map do |id|
      r = id.split(':')
      [r[0], r[1].to_i]
    end
  end

  def self.db_config
    YAML::load(File.open($isearch_conf_yaml['db_config']))
  end
end

