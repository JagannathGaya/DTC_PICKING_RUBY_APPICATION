begin
  shards = {:tb_shards => {}}
  envlist = Dir[Rails.root.join('config', 'environments', '*.rb')].map {|file| File.basename(file, '.rb')}

  require 'yaml'
  require 'erb'
  # Load database.yml through ERB so `<%= ENV.fetch(...) %>` interpolations
  # resolve. `YAML.load_file` would treat them as literal strings, breaking
  # any Docker/env-driven host or password override.
  dbyml_content = YAML.load(ERB.new(File.read(Rails.root.join('config', 'database.yml'))).result)

  begin
    Client.all.each do |client|
      if client.database && client.username && client.password
        shards[:tb_shards][client.cust_no] = {:adapter => 'oracle_enhanced',
                                              :database => client.database,
                                              :username => client.username,
                                              :password => client.password,
                                              :pool => 5}
      #   puts "Adding Client DB connector for: #{shards[:tb_shards][client.cust_no].inspect}" unless Rails.env.production?
      # else
      #   puts "Ignoring Client DB connector for: #{client.cust_no}" unless Rails.env.production?
      end
    end if Client rescue false

    shards[:tb_shards]['pg'] = dbyml_content[Rails.env]
    shards[:tb_shards]['tbdash'] = dbyml_content['tbdash_' + Rails.env]

  rescue ActiveRecord::StatementInvalid => e # Capture everything
    puts e.inspect
  end

  Octopus.setup do |config|
    config.environments = envlist
    config.shards = shards
  end

  puts "#{shards[:tb_shards].count} Connectors added: #{shards[:tb_shards].inspect}" unless Rails.env.production?

end

