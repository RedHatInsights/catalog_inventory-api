module Headers
  class Service
    def self.x_rh_identity(user)
      Base64.strict_encode64(user.to_json)
    end

    def self.x_rh_identity_dummy_admin
      Base64.strict_encode64(User::ADMIN_USER.to_json)
    end

    def self.x_rh_identity_tenant_user(account_number)
      Base64.strict_encode64(User.tenant_user(account_number).to_json)
    end
  end

  module User
    ADMIN_USER ||= {
      "identity" => {
        "account_number" => "SYSTEM_USER",
        "type"           => "User",
        "user"           => {
          "username"     => "system",
          "email"        => "dummy_user@redhat.com",
          "first_name"   => "dummy",
          "last_name"    => "user",
          "is_active"    => false,
          "is_org_admin" => true,
          "is_internal"  => false,
          "system"       => true,
          "locale"       => "en_US"
        },
        "internal"       => {
          "org_id"    => "1234567",
          "auth_type" => "basic-auth",
          "auth_time" => 6300
        }
      }
    }.freeze

    def self.tenant_user(account_number)
      {
        "entitlements" => {
          "ansible"          => {
            "is_entitled" => true
          },
          "hybrid_cloud"     => {
            "is_entitled" => true
          },
          "insights"         => {
            "is_entitled" => true
          },
          "migrations"       => {
            "is_entitled" => true
          },
          "openshift"        => {
            "is_entitled" => true
          },
          "smart_management" => {
            "is_entitled" => true
          }
        },
        "identity" => {
          "account_number" => account_number,
          "type"           => "User",
          "auth_type"      => "basic-auth",
          "user"           =>  {
            "username"     => "system",
            "email"        => "jdoe@acme.com",
            "first_name"   => "John",
            "last_name"    => "Doe",
            "is_active"    => true,
            "is_org_admin" => false,
            "is_internal"  => false,
            "locale"       => "en_US"
          },
          "internal"       => {
            "org_id"    => "3340851",
            "auth_time" => 6300
          }
        }
      }
    end
  end
end
