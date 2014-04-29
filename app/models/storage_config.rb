class StorageConfig
    @@config = nil

    def self.config
        if @@config.nil?
            @@config = open("config/storage_properties.yml") { |f| YAML.load(f) }
        else
            @@config
        end
    end

    def self.put(key,value)
        config.store(key,value)
        open("config/storage_properties.yml","w:ASCII-8BIT:utf-8") { |f| YAML.dump(@@config,f) }
    end
end
