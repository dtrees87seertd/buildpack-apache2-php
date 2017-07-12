# encoding: utf-8

module JboxDatabase
  class PrestashopPasswordUpdater < Base

    PRESTA_SETTINGS = %w[ cookie_key site_dns ]

    attr_reader :email
    attr_reader :password
    attr_reader :salted_password

    attr_reader :cookie_key
    attr_reader :site_dns


    def initialize(app_dir)
      super

      # Load needed environment variables (it raises error if fails)
      load_prestashop_variables

      # Set needed attributes
      @email    = 'admin@jbox-web.com'
      @password = 'admin'
      @salted_password = "#{cookie_key}#{password}"
    end


    def run!
      db_connection.query("UPDATE ps_employee SET passwd = md5('#{salted_password}') WHERE email = '#{email}'")
      db_connection.query("UPDATE ps_configuration SET value = '#{site_dns}' WHERE name = 'PS_SHOP_DOMAIN'")
      db_connection.query("UPDATE ps_configuration SET value = '#{site_dns}' WHERE name = 'PS_SHOP_DOMAIN_SSL'")
      db_connection.query("UPDATE ps_shop_url SET domain = '#{site_dns}', domain_ssl = '#{site_dns}' WHERE id_shop = 1")

      status "Prestashop has been updated, here the new password :"
      status ""
      status "email    : #{email}"
      status "password : #{password}"
      status ""
    end


    private


      def load_prestashop_variables
        PRESTA_SETTINGS.each do |param|
          param_name = param.upcase
          if !ENV[param_name].nil?
            instance_variable_set("@#{param}" , ENV[param_name])
          else
            raise MissingParameterError, param_name
          end
        end
      end

  end
end
