# name: discourse-debtcollective-migratepassword
# about: enable password from the old platform to work, based on https://github.com/discoursehosting/discourse-migratepassword
# version: 0.1
# authors: Orlando Del Aguila <orlando@hashlabs.com>
# url: https://github.com/debtcollective/discourse-debtcollective-migratepassword

gem 'bcrypt', '3.1.3'

enabled_site_setting :debtcollective_migratepassword_enabled

after_initialize do
  module OldPasswordValidator
    def confirm_password?(password)
      return true if super
      return false unless SiteSetting.debtcollective_migratepassword_enabled
      return false unless custom_fields.key?('import_pass')

      if BCrypt::Password.new(custom_fields['import_pass']) == password
        self.password = password
        custom_fields.delete('import_pass')

        save(validate: false)
      else
        false
      end
    end
  end

  class ::User
    prepend OldPasswordValidator
  end
end
