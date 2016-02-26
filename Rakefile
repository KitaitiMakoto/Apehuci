require 'nokogiri'
require 'uri'
require 'groonga/client'

task :default => [:gh_pages, :search_index]

desc 'Build site'
task :site do
  sh 'middleman build'
end

desc 'Deploy GitHub pages'
task :gh_pages do |t|
  sh 'middleman deploy'
end

GROONGA_URI = URI.parse('http://search.apehuci.kitaitimakoto.net:10041')
GROONGA_TABLE = 'Apehuci'

desc 'Set up Groonga database'
task :setup_db do
  raise 'Environment variable APEHUCI_HTPASSWD not set' unless ENV['APEHUCI_HTPASSWD']

  Groonga::Client.open(host: GROONGA_URI.host, port: GROONGA_URI.port, protocol: GROONGA_URI.scheme, user: 'KitaitiMakoto', password: ENV['APEHUCI_HTPASSWD']) do |client|
    client.table_create name: GROONGA_TABLE, flags: 'TABLE_HASH_KEY', key_type: :ShortText

    client.column_create table: GROONGA_TABLE, name: 'title',   type: :ShortText
    client.column_create table: GROONGA_TABLE, name: 'tags',    type: :ShortText, flags: 'COLUMN_VECTOR'
    client.column_create table: GROONGA_TABLE, name: 'content', type: :Text

    terms_table = "#{GROONGA_TABLE}Terms"
    client.table_create name: terms_table, flags: 'TABLE_PAT_KEY', key_type: :ShortText,
                        default_tokenizer: :TokenMecab, normalizer: :NormalizerAuto

    client.column_create table: terms_table, name: 'title_index',   flags: 'COLUMN_INDEX|WITH_POSITION', type: GROONGA_TABLE, source: 'title'
    client.column_create table: terms_table, name: 'tags_index',    flags: 'COLUMN_INDEX|WITH_POSITION', type: GROONGA_TABLE, source: 'tags'
    client.column_create table: terms_table, name: 'content_index', flags: 'COLUMN_INDEX|WITH_POSITION', type: GROONGA_TABLE, source: 'content'
  end
end

desc 'Generate search index and deploy it'
task :search_index do |t|
  files = FileList['build/**/*.html'].grep(%r|\Abuild/\d{4}/\d{2}/\d{2}\.html\z|)
  raise 'Environment variable APEHUCI_HTPASSWD not set' unless ENV['APEHUCI_HTPASSWD']

  resources = files.collect {|path|
    doc = Nokogiri.HTML(open(path))
    {
      :_key    => path.sub(/\Abuild\//, ''),
      :title   => doc.css('title').first.content,
      :tags    => doc.css('.tags li').collect(&:content),
      :content => doc.css('article > paper-card').first.content
    }
  }

  Groonga::Client.open(host: GROONGA_URI.host, port: GROONGA_URI.port, protocol: GROONGA_URI.scheme, user: 'KitaitiMakoto', password: ENV['APEHUCI_HTPASSWD']) do |client|
    client.load table: GROONGA_TABLE, values: resources
  end
end

require 'groonga/client/protocol/http/synchronous'
module GroongaNoKeepAlive
  def headers
    {"connection" => "Close"}.merge(super)
  end
end
Groonga::Client::Protocol::HTTP::Synchronous.send :prepend, GroongaNoKeepAlive
