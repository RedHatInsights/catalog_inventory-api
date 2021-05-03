module UserHeaderSpecHelper
  DEFAULT_USER = {
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
    "identity"     => {
      "account_number" => "0369233",
      "type"           => "User",
      "auth_type"      => "basic-auth",
      "user"           => {
        "username"     => "jdoe",
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
  }.freeze

  DEFAULT_CERT_USER = {
    "identity"     => {
      "internal"       => {
        "auth_time"    => 0,
        "cross_access" => false,
        "org_id"       => "11789772"
      },
      "account_number" => "6089719",
      "auth_type"      => "cert-auth",
      "system"         => {
        "cn"        => "8e564c08-3d46-476c-8fca-587863c5b48b",
        "cert_type" => "system"
      },
      "type"           => "System"
    },
    "entitlements" => {
      "insights"         => {
        "is_entitled" => true,
        "is_trial"    => false
      },
      "cost_management"  => {
        "is_entitled" => true,
        "is_trial"    => false
      },
      "migrations"       => {
        "is_entitled" => true,
        "is_trial"    => false
      },
      "rhel"             => {
        "is_entitled" => true,
        "is_trial"    => false
      },
      "user_preferences" => {
        "is_entitled" => true,
        "is_trial"    => false
      },
      "ansible"          => {
        "is_entitled" => true,
        "is_trial"    => false
      },
      "internal"         => {
        "is_entitled" => false,
        "is_trial"    => false
      },
      "openshift"        => {
        "is_entitled" => true,
        "is_trial"    => false
      },
      "smart_management" => {
        "is_entitled" => true,
        "is_trial"    => false
      },
      "subscriptions"    => {
        "is_entitled" => true,
        "is_trial"    => false
      },
      "settings"         => {
        "is_entitled" => true,
        "is_trial"    => false
      }
    }
  }.freeze

  DEFAULT_SYSTEM = {
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
    "identity"     => {
      "account_number" => "0369233",
      "type"           => "System",
      "auth_type"      => "cert-auth",
      "system"         => {
        "cn" => "certificate"
      },
      "internal"       => {
        "org_id"    => "3340851",
        "auth_time" => 6300
      }
    }
  }.freeze

  def default_account_number
    default_user_hash["identity"]["account_number"]
  end

  def default_username
    default_user_hash["identity"]["user"]["username"]
  end

  def default_auth_type
    default_user_hash["identity"]["auth_type"]
  end

  def default_system_cn
    default_system_hash["identity"]["system"]["cn"]
  end

  def encode(val)
    if val.kind_of?(Hash)
      hashed = val.stringify_keys
      Base64.strict_encode64(hashed.to_json)
    else
      raise StandardError, "Must be a Hash"
    end
  end

  def encoded_user_hash(hash = nil)
    encode(hash || DEFAULT_USER)
  end

  def encoded_system_hash(hash = nil)
    encode(hash || DEFAULT_SYSTEM)
  end

  def default_user_hash
    Marshal.load(Marshal.dump(DEFAULT_USER))
  end

  def default_system_hash
    Marshal.load(Marshal.dump(DEFAULT_SYSTEM))
  end
end
