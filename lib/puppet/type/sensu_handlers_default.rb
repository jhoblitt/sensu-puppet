require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
                                   'puppet_x', 'sensu', 'boolean_property.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
                                   'puppet_x', 'sensu', 'to_type.rb'))

Puppet::Type.newtype(:sensu_handlers_default) do
  @doc = ""

  # this makes me sad :( -- puppet 4 introduces #autonotify
  def initialize(*args)
    super *args

    self[:notify] = [
      "Service[sensu-client]",
      "Service[sensu-server]",
    ].select { |ref| catalog.resource(ref) }
  end

  ensurable do
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    defaultto :present
  end

  newparam(:name) do
    desc "The name of the check."
  end

  newproperty(:handlers, :array_matching => :all) do
    desc "List of handlers to use by default"
    def insync?(is)
      is.sort == should.sort
    end
  end

  newparam(:base_path) do
    desc "The base path to the client config file"
    defaultto '/etc/sensu/conf.d/'
  end

  autorequire(:package) do
    ['sensu']
  end
end
