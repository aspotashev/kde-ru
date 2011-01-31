# encoding: utf-8
require File.expand_path("../../../config/environment", __FILE__)
require 'xml' # gem install libxml-ruby


$conf = YAML::load(File.open(File.join(File.dirname(__FILE__), 'config.yml')))

def report_error(s)
  # TODO: what are the other ways to report an error?
  File.open("/tmp/stalk-jobs.log", "w+") do |f|
    f.puts s
  end
end

class PoSieve
  def self.get_tempfile
    '/tmp/po-backend-' + Time.now.to_i.to_s + rand.to_s
  end

  def self.recalc_offset(offset, msgstr)
    res = []
    s = nil
    index = 0

    allowed_chars = /[^a-zA-Z&áňŠěéČć³²]/u # see pology/lang/ru/rules/check-spell.rules
    while (s = msgstr[index..-1]).index(allowed_chars)
      index += s.index(allowed_chars)
      res << index
      index += 1
    end

    res[offset] || offset
  end

  def self.check_gettext(content)
    tempfile = get_tempfile
    tempfile_po = tempfile + '.po'

    File.open(tempfile_po, 'w') {|f| f.print content }
    `msgfmt --check #{tempfile_po} -o - 2> #{tempfile} > /dev/null`

    res = File.read(tempfile)

    `rm -f #{tempfile}`
    `rm -f #{tempfile_po}`

    res.empty? ? nil : "'msgfmt --check' reported an error: " + res # 'nil' = no errors
  end

  def self.check_rules(content)
    tempfile = get_tempfile
    File.open(tempfile + '.po', 'w') {|f| f.write(content) }
    `#{$conf['pology_path']}/scripts/posieve.py check-rules --skip-obsolete -slang:ru --raw-colors --quiet -snomsg #{tempfile + '.po'} -sxml:#{tempfile + '.xml'}`
    xml = File.open(tempfile + '.xml').read

    `rm -f #{tempfile + '.xml'}`
    `rm -f #{tempfile + '.po'}`

    parser = XML::Parser.string(xml)
    begin
      doc = parser.parse
    rescue LibXML::XML::Error => e
      report_error("LibXML::XML::Error -- #{tempfile + '.xml'}")
      return "LibXML::XML::Error"
    end


    res = doc.find('//error').map do |err|
      h = {}

      err.find('*').each do |arg|
	if arg.name == 'highlight'
	  msgstr = err.find('msgstr')[0].content.force_encoding('UTF-8')
	  msgstr_begin = recalc_offset(arg.attributes[:begin].to_i, msgstr)
	  msgstr_end = recalc_offset(arg.attributes[:end].to_i, msgstr)

	  h = h.merge({ :highlight => (msgstr_begin...msgstr_end) })
	else
	  h = h.merge({ arg.name.to_sym => arg.content })
	end
      end

      h
    end

    res
  end
end

job "pology_check" do |options|
  file_content = FileContent.find(options['file_content_id'])
  if not file_content.pology_check_done? or
    file_content.updated_at < Time.now - 1.day # force update every day

    content_data = file_content.read_content

    res = nil

    res = PoSieve.check_gettext(content_data) # if res is not nil, then it is a String containing the error message

    if res.nil? # if everything is still OK
      begin
	res = PoSieve.check_rules(content_data)
      rescue Errno::ENOMEM => e
	res = "Errno::ENOMEM"
      end
    end

    if res.nil?
      res = "res is still nil. We did not catch some type of error."
    end

    file_content.pology_errors_cache = res.to_yaml
    file_content.pology_errors_count_cache = res.size
    file_content.save!
    file_content.touch # force update of updated_at
  end
end

