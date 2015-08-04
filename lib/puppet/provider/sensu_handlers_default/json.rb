require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.version < '3'
require 'json' if Puppet.features.json?
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                   'puppet_x', 'sensu', 'provider_create.rb'))

Puppet::Type.type(:sensu_handlers_default).provide(:json) do
  confine :feature => :json
  include PuppetX::Sensu::ProviderCreate

  def conf
    begin
      @conf ||= JSON.parse(File.read(config_file))
    rescue
      @conf ||= {}
    end
  end

  def flush
    File.open(config_file, 'w') do |f|
      f.puts JSON.pretty_generate(@conf)
    end
  end

  def pre_create
    conf['handlers'] = {}
    conf['handlers'] = {
      'default' => {
        'type' => 'set',
      }
    }
  end

  def destroy
    if !conf.nil? && conf.has_key?('handlers') &&
        conf['handlers'].has_key?('default')
      conf['handlers']['default'].delete 'handlers'
    end
  end

  def exists?
    unless !conf.nil? && conf.has_key?('handlers') &&
        conf['handlers'].has_key?('default')
      return false
    end
    conf['handlers']['default'].has_key? 'handlers'
  end

  def config_file
    "#{resource[:base_path]}/handlers_default.json"
  end

  def handlers
    conf['handlers']['default']['handlers'] || []
  end

  def handlers=(value)
    conf['handlers']['default']['handlers'] = value
  end
end
