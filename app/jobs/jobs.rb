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

    res.empty? ? nil : "'msgfmt --check' reported an error:\n" + res # 'nil' = no errors
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

    begin
      res = PoSieve.check_rules(content_data)
    rescue Errno::ENOMEM => e
      res = "Errno::ENOMEM"
    end

    if res.nil?
      res = "res is still nil. We did not catch some type of error."
    end

    gettext_error = PoSieve.check_gettext(content_data) # if gettext_error is not nil, then it is a String containing the error message
    if gettext_error.is_a?(String)
      res.unshift({ :gettext_error => gettext_error })
    end

    file_content.pology_errors_cache = res.to_yaml
    file_content.pology_errors_count_cache = res.size
    file_content.save!
    file_content.touch # force update of updated_at
  end
end

job "deliver_signup_notification" do |options|
  UserMailer.deliver_signup_notification(User.find(options['user_id']))
end

job "deliver_activation" do |options|
  UserMailer.deliver_activation(User.find(options['user_id']))
end

class FilenameInBranch < Struct.new(:base_dir, :filename)
  def full_filename
    base_dir + "/" + filename
  end
end

class FilenameList < Array
  attr_accessor :base_dir

  def initialize(base)
    @base_dir = base
  end

  def list_by_pattern(pattern)
    `ls -1 #{@base_dir}/#{pattern}`.split("\n").map do |full_filename|
      FilenameInBranch.new(base_dir, full_filename[(base_dir.size + 1)..-1])
    end
  end

  # pattern: e.g. "*/*.po", relative to base_dir
  def add_files(pattern)
    concat(list_by_pattern(pattern)) # TODO: avoid using shell commands
  end

  def remove_files(pattern)
    list_to_substract = list_by_pattern(pattern)
    delete_if {|x| list_to_substract.include?(x) } # like "-" operation, but without creating new array
  end

  def plain_list
    self.map(&:full_filename)
  end
end

# Remove all data previously grabbed from KDE l10n repository.
def remove_repository_data
  # remove all FileContents "uploaded" by user "repository"
  user_repository = User.find_by_login('repository')
  user_repository.file_contents.each do |content|
    content.delete(user_repository)
  end

  # TODO: how to simplify this by using ActiveRecord? (move "f.file_contents.size == 0" condition to SQL request)
  TranslationFile.all_except_dump.select {|f| f.file_contents.size == 0 }.each {|f| f.delete }

  FileBranching.delete_all
  TranslationBranch.delete_all
end

def update_branch(options)
  branch = TranslationBranch.create_by_name(options[:branch])

  file_list = options[:files]
  file_basename_list = file_list.map {|s| File.basename(s.filename) }
  raise "Duplicate .po files (with same basenames): #{file_basename_list.uniq.select {|x| file_basename_list.count(x) > 1 }}" if file_basename_list.uniq.size != file_basename_list.size

#  # Removed files
#  (branch.translation_files.basename - file_basename_list).each do |filename|
#  end

  # Still existing and new files
  file_list.each do |file|
    tr_file = TranslationFile.create_by_name(file.filename)

    existing = FileBranching.find(:first, :conditions => { :translation_file_id => tr_file.id, :translation_branch_id => branch.id })
#    if existing.nil?
#      # TODO: remove file_content from disk
#    end

    content = FileContent.create(:translation_file_id => tr_file.id, :user_id => -2) # user "repository"
    content.save(false) # pre-create to occupy content.id
    content_filename = "/system/contents/#{content.id}/original/#{File.basename(file.filename)}" # TODO: make paperclip or another plugin do this
    content_filename_full = RAILS_ROOT + "/public" + content_filename
    `mkdir -p #{File.dirname(content_filename_full)}`
    `cp '#{file.full_filename}' '#{content_filename_full}'`
    content.content_file_name = File.basename(content_filename)
    content.content_content_type = 'text/x-gettext-translation'
    content.content_file_size = File.size(content_filename_full)
    content.content_updated_at = Time.now
    content.save(false) # TODO: set user_id to something (not nil)

    FileBranching.create(:translation_file_id => tr_file.id, :translation_branch_id => branch.id, :file_content_id => content.id)

#    t.integer  "user_id"

  end
end

# Run "update_branch" for all branches.
job "update_branches" do |options|
  remove_repository_data

  # TODO: enqueue 4 branches: trunk, stable, koffice-trunk, koffice-stable

  # TODO: how to pass the paths and mappings? (for clarification: we should rename, i.e. "map", some files from koffice/ to match filenames from calligra/)
  file_list = FilenameList.new('/home/sasha/messages')
#  file_list.add_files('*/*.po')
#  file_list.remove_files('koffice/*.po')
  file_list.add_files('kdelibs/*.po')
  update_branch(:branch => 'trunk', :files => file_list)
end
