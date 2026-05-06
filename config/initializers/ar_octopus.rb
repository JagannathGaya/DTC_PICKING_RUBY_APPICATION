module Octopus
  module Model
    module InstanceMethods
      def init_with(coder)
        obj = super
        return obj unless Octopus.enabled?
        # return obj if obj.class.connection_proxy.current_model_replicated?   LJK removed, there was no equivalent for this in older version
        return obj unless coder['attributes'] # added GJ 08/01/2018
        current_shard_value = coder['attributes']['current_shard'].value if coder['attributes']['current_shard'].present? && coder['attributes']['current_shard'].value.present?

        coder['attributes'].send(:attributes).send(:values).delete('current_shard')
        coder['attributes'].send(:attributes).send(:delegate_hash).delete('current_shard')

        obj.current_shard = current_shard_value if current_shard_value.present?
        obj
      end
    end
  end
end