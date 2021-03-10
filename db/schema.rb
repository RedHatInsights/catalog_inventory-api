# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_03_10_203929) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "service_credential_types", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "source_id"
    t.string "name"
    t.string "description"
    t.string "kind"
    t.string "namespace"
    t.string "source_ref", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.datetime "source_created_at"
    t.datetime "source_deleted_at"
    t.datetime "last_seen_at"
    t.index ["archived_at"], name: "index_service_credential_types_on_archived_at"
    t.index ["last_seen_at"], name: "index_service_credential_types_on_last_seen_at"
    t.index ["source_id", "source_ref"], name: "index_service_credential_types_on_source_id_and_source_ref", unique: true
    t.index ["tenant_id"], name: "index_service_credential_types_on_tenant_id"
  end

  create_table "service_credentials", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "source_id"
    t.string "source_ref", null: false
    t.string "name"
    t.string "type_name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.datetime "source_created_at"
    t.datetime "source_updated_at"
    t.datetime "last_seen_at"
    t.bigint "service_credential_type_id"
    t.index ["archived_at"], name: "index_service_credentials_on_archived_at"
    t.index ["last_seen_at"], name: "index_service_credentials_on_last_seen_at"
    t.index ["service_credential_type_id"], name: "index_service_credentials_on_service_credential_type_id"
    t.index ["source_id", "source_ref"], name: "index_service_credentials_on_source_id_and_source_ref", unique: true
    t.index ["tenant_id"], name: "index_service_credentials_on_tenant_id"
  end

  create_table "service_instance_node_service_credentials", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "service_credential_id", null: false
    t.bigint "service_instance_node_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_seen_at"
    t.index ["last_seen_at"], name: "index_service_instance_node_service_credentials_on_last_seen_at"
    t.index ["service_credential_id", "service_instance_node_id"], name: "index_service_instance_node_credential_id", unique: true
    t.index ["service_instance_node_id"], name: "index_instance_node_credentials_on_service_offering_id"
    t.index ["tenant_id"], name: "index_service_instance_node_service_credentials_on_tenant_id"
  end

  create_table "service_instance_nodes", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "source_id", null: false
    t.bigint "service_inventory_id"
    t.bigint "service_instance_id"
    t.bigint "root_service_instance_id"
    t.string "source_ref", null: false
    t.string "name"
    t.jsonb "extra"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.datetime "source_created_at"
    t.datetime "source_updated_at"
    t.datetime "last_seen_at"
    t.index ["archived_at"], name: "index_service_instance_nodes_on_archived_at"
    t.index ["last_seen_at"], name: "index_service_instance_nodes_on_last_seen_at"
    t.index ["root_service_instance_id"], name: "index_service_instance_nodes_on_root_service_instance_id"
    t.index ["service_instance_id"], name: "index_service_instance_nodes_on_service_instance_id"
    t.index ["service_inventory_id"], name: "index_service_instance_nodes_on_service_inventory_id"
    t.index ["tenant_id"], name: "index_service_instance_nodes_on_tenant_id"
  end

  create_table "service_instance_service_credentials", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "service_credential_id", null: false
    t.bigint "service_instance_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_seen_at"
    t.index ["last_seen_at"], name: "index_service_instance_service_credentials_on_last_seen_at"
    t.index ["service_credential_id", "service_instance_id"], name: "index_service_instance_credential_id", unique: true
    t.index ["service_instance_id"], name: "index_service_instance_credentials_on_service_instance_id"
    t.index ["tenant_id"], name: "index_service_instance_service_credentials_on_tenant_id"
  end

  create_table "service_instances", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "source_id"
    t.string "source_ref", null: false
    t.string "name"
    t.bigint "service_offering_id"
    t.bigint "service_plan_id"
    t.jsonb "extra"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "source_deleted_at"
    t.datetime "source_created_at"
    t.datetime "archived_at"
    t.datetime "last_seen_at"
    t.string "external_url"
    t.bigint "service_inventory_id"
    t.bigint "root_service_instance_id"
    t.index ["archived_at"], name: "index_service_instances_on_archived_at"
    t.index ["last_seen_at"], name: "index_service_instances_on_last_seen_at"
    t.index ["root_service_instance_id"], name: "index_service_instances_on_root_service_instance_id"
    t.index ["service_inventory_id"], name: "index_service_instances_on_service_inventory_id"
    t.index ["service_offering_id"], name: "index_service_instances_on_service_offering_id"
    t.index ["service_plan_id"], name: "index_service_instances_on_service_plan_id"
    t.index ["source_deleted_at"], name: "index_service_instances_on_source_deleted_at"
    t.index ["source_id", "source_ref"], name: "index_service_instances_on_source_id_and_source_ref", unique: true
    t.index ["source_id"], name: "index_service_instances_on_source_id"
    t.index ["tenant_id"], name: "index_service_instances_on_tenant_id"
  end

  create_table "service_inventories", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "source_id"
    t.string "source_ref", null: false
    t.string "name"
    t.text "description"
    t.jsonb "extra"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.datetime "source_created_at"
    t.datetime "source_updated_at"
    t.datetime "last_seen_at"
    t.index ["archived_at"], name: "index_service_inventories_on_archived_at"
    t.index ["last_seen_at"], name: "index_service_inventories_on_last_seen_at"
    t.index ["source_id", "source_ref"], name: "index_service_inventories_on_source_id_and_source_ref", unique: true
    t.index ["tenant_id"], name: "index_service_inventories_on_tenant_id"
  end

  create_table "service_inventory_tags", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "tag_id", null: false
    t.bigint "service_inventory_id", null: false
    t.datetime "last_seen_at"
    t.index ["last_seen_at"], name: "index_service_inventory_tags_on_last_seen_at"
    t.index ["service_inventory_id"], name: "index_service_inventory_tags_on_service_inventory_id"
    t.index ["tag_id", "service_inventory_id"], name: "service_inventories_tags_unique_index", unique: true
    t.index ["tenant_id"], name: "index_service_inventory_tags_on_tenant_id"
  end

  create_table "service_offering_icons", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "source_id", null: false
    t.string "source_ref", null: false
    t.binary "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.datetime "last_seen_at"
    t.index ["archived_at"], name: "index_service_offering_icons_on_archived_at"
    t.index ["last_seen_at"], name: "index_service_offering_icons_on_last_seen_at"
    t.index ["tenant_id"], name: "index_service_offering_icons_on_tenant_id"
  end

  create_table "service_offering_node_service_credentials", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "service_credential_id", null: false
    t.bigint "service_offering_node_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_seen_at"
    t.index ["last_seen_at"], name: "index_service_offering_node_service_credentials_on_last_seen_at"
    t.index ["service_credential_id", "service_offering_node_id"], name: "index_service_offering_node_credential_id", unique: true
    t.index ["service_offering_node_id"], name: "index_offering_node_credentials_on_service_offering_id"
    t.index ["tenant_id"], name: "index_service_offering_node_service_credentials_on_tenant_id"
  end

  create_table "service_offering_nodes", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "source_id", null: false
    t.bigint "service_inventory_id"
    t.bigint "service_offering_id"
    t.bigint "root_service_offering_id"
    t.string "source_ref", null: false
    t.string "name"
    t.jsonb "extra"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.datetime "source_created_at"
    t.datetime "source_updated_at"
    t.datetime "last_seen_at"
    t.index ["archived_at"], name: "index_service_offering_nodes_on_archived_at"
    t.index ["last_seen_at"], name: "index_service_offering_nodes_on_last_seen_at"
    t.index ["root_service_offering_id"], name: "index_service_offering_nodes_on_root_service_offering_id"
    t.index ["service_inventory_id"], name: "index_service_offering_nodes_on_service_inventory_id"
    t.index ["service_offering_id"], name: "index_service_offering_nodes_on_service_offering_id"
    t.index ["source_id", "source_ref"], name: "index_service_offering_nodes_on_source_id_and_source_ref", unique: true
    t.index ["tenant_id"], name: "index_service_offering_nodes_on_tenant_id"
  end

  create_table "service_offering_service_credentials", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "service_credential_id", null: false
    t.bigint "service_offering_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_seen_at"
    t.index ["last_seen_at"], name: "index_service_offering_service_credentials_on_last_seen_at"
    t.index ["service_credential_id", "service_offering_id"], name: "index_service_offering_credential_id", unique: true
    t.index ["service_offering_id"], name: "index_service_offering_credentials_on_service_offering_id"
    t.index ["tenant_id"], name: "index_service_offering_service_credentials_on_tenant_id"
  end

  create_table "service_offering_tags", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "last_seen_at"
    t.bigint "service_offering_id", null: false
    t.index ["last_seen_at"], name: "index_service_offering_tags_on_last_seen_at"
    t.index ["service_offering_id", "tag_id"], name: "uniq_index_on_service_offering_id_tag_id", unique: true
    t.index ["tag_id"], name: "index_service_offering_tags_on_tag_id"
    t.index ["tenant_id"], name: "index_service_offering_tags_on_tenant_id"
  end

  create_table "service_offerings", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "source_id"
    t.string "source_ref"
    t.string "name"
    t.text "description"
    t.jsonb "extra"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "source_deleted_at"
    t.datetime "source_created_at"
    t.datetime "archived_at"
    t.datetime "last_seen_at"
    t.string "display_name"
    t.string "documentation_url"
    t.text "long_description"
    t.string "distributor"
    t.string "support_url"
    t.bigint "service_offering_icon_id"
    t.bigint "service_inventory_id"
    t.index ["archived_at"], name: "index_service_offerings_on_archived_at"
    t.index ["last_seen_at"], name: "index_service_offerings_on_last_seen_at"
    t.index ["service_inventory_id"], name: "index_service_offerings_on_service_inventory_id"
    t.index ["service_offering_icon_id"], name: "index_service_offerings_on_service_offering_icon_id"
    t.index ["source_deleted_at"], name: "index_service_offerings_on_source_deleted_at"
    t.index ["tenant_id"], name: "index_service_offerings_on_tenant_id"
  end

  create_table "service_plans", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "source_id", null: false
    t.string "source_ref", null: false
    t.string "name"
    t.text "description"
    t.bigint "service_offering_id"
    t.jsonb "extra"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "source_deleted_at"
    t.datetime "source_created_at"
    t.jsonb "create_json_schema"
    t.jsonb "update_json_schema"
    t.datetime "archived_at"
    t.datetime "last_seen_at"
    t.index ["archived_at"], name: "index_service_plans_on_archived_at"
    t.index ["last_seen_at"], name: "index_service_plans_on_last_seen_at"
    t.index ["service_offering_id"], name: "index_service_plans_on_service_offering_id"
    t.index ["source_deleted_at"], name: "index_service_plans_on_source_deleted_at"
    t.index ["source_id", "source_ref"], name: "index_service_plans_on_source_id_and_source_ref", unique: true
    t.index ["tenant_id"], name: "index_service_plans_on_tenant_id"
  end

  create_table "sources", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "uid", null: false
    t.bigint "tenant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "refresh_state"
    t.datetime "refresh_started_at"
    t.datetime "refresh_finished_at"
    t.datetime "last_successful_refresh_at"
    t.jsonb "info"
    t.string "cloud_connector_id"
    t.string "availability_status"
    t.datetime "last_checked_at"
    t.datetime "last_available_at"
    t.boolean "enabled", default: false
    t.string "refresh_task_id"
    t.string "last_refresh_message"
    t.string "previous_sha"
    t.integer "previous_size"
    t.string "availability_message"
    t.index ["tenant_id", "uid"], name: "index_sources_on_tenant_id_and_uid", unique: true
  end

  create_table "tags", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.string "name", null: false
    t.string "namespace", default: "", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.string "value", default: "", null: false
    t.datetime "last_seen_at"
    t.index ["last_seen_at"], name: "index_tags_on_last_seen_at"
    t.index ["tenant_id", "namespace", "name", "value"], name: "index_tags_on_tenant_id_and_namespace_and_name_and_value", unique: true
  end

  create_table "tasks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "source_id"
    t.string "name"
    t.string "status"
    t.string "state"
    t.string "message"
    t.string "type"
    t.jsonb "input"
    t.jsonb "output"
    t.datetime "completed_at"
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "target_source_ref"
    t.string "target_type"
    t.jsonb "forwardable_headers"
    t.string "child_task_id"
    t.string "controller_message_id"
    t.index ["archived_at"], name: "index_tasks_on_archived_at"
    t.index ["source_id"], name: "index_tasks_on_source_id"
    t.index ["target_source_ref", "target_type"], name: "index_tasks_on_target_source_ref_and_target_type"
    t.index ["tenant_id"], name: "index_tasks_on_tenant_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "external_tenant", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_tenant"], name: "index_tenants_on_external_tenant", unique: true
  end

  add_foreign_key "service_credential_types", "sources", on_delete: :cascade
  add_foreign_key "service_credential_types", "tenants", on_delete: :cascade
  add_foreign_key "service_credentials", "sources", on_delete: :cascade
  add_foreign_key "service_credentials", "tenants", on_delete: :cascade
  add_foreign_key "service_instance_node_service_credentials", "service_credentials", on_delete: :cascade
  add_foreign_key "service_instance_node_service_credentials", "service_instance_nodes", on_delete: :cascade
  add_foreign_key "service_instance_node_service_credentials", "tenants", on_delete: :cascade
  add_foreign_key "service_instance_nodes", "service_instances", column: "root_service_instance_id", on_delete: :nullify
  add_foreign_key "service_instance_nodes", "service_instances", on_delete: :nullify
  add_foreign_key "service_instance_nodes", "service_inventories", on_delete: :nullify
  add_foreign_key "service_instance_nodes", "sources", on_delete: :cascade
  add_foreign_key "service_instance_nodes", "tenants", on_delete: :cascade
  add_foreign_key "service_instance_service_credentials", "service_credentials", on_delete: :cascade
  add_foreign_key "service_instance_service_credentials", "service_instances", on_delete: :cascade
  add_foreign_key "service_instance_service_credentials", "tenants", on_delete: :cascade
  add_foreign_key "service_instances", "service_instances", column: "root_service_instance_id", on_delete: :nullify
  add_foreign_key "service_instances", "service_inventories", on_delete: :nullify
  add_foreign_key "service_instances", "sources", on_delete: :cascade
  add_foreign_key "service_instances", "tenants", on_delete: :cascade
  add_foreign_key "service_inventories", "sources", on_delete: :cascade
  add_foreign_key "service_inventories", "tenants", on_delete: :cascade
  add_foreign_key "service_inventory_tags", "service_inventories", on_delete: :cascade
  add_foreign_key "service_inventory_tags", "tags", on_delete: :cascade
  add_foreign_key "service_inventory_tags", "tenants", on_delete: :cascade
  add_foreign_key "service_offering_icons", "sources", on_delete: :cascade
  add_foreign_key "service_offering_icons", "tenants", on_delete: :cascade
  add_foreign_key "service_offering_node_service_credentials", "service_credentials", on_delete: :cascade
  add_foreign_key "service_offering_node_service_credentials", "service_offering_nodes", on_delete: :cascade
  add_foreign_key "service_offering_node_service_credentials", "tenants", on_delete: :cascade
  add_foreign_key "service_offering_nodes", "service_inventories", on_delete: :nullify
  add_foreign_key "service_offering_nodes", "service_offerings", column: "root_service_offering_id", on_delete: :nullify
  add_foreign_key "service_offering_nodes", "service_offerings", on_delete: :nullify
  add_foreign_key "service_offering_nodes", "sources", on_delete: :cascade
  add_foreign_key "service_offering_nodes", "tenants", on_delete: :cascade
  add_foreign_key "service_offering_service_credentials", "service_credentials", on_delete: :cascade
  add_foreign_key "service_offering_service_credentials", "service_offerings", on_delete: :cascade
  add_foreign_key "service_offering_service_credentials", "tenants", on_delete: :cascade
  add_foreign_key "service_offering_tags", "service_offerings", on_delete: :cascade
  add_foreign_key "service_offering_tags", "tags", on_delete: :cascade
  add_foreign_key "service_offering_tags", "tenants", on_delete: :cascade
  add_foreign_key "service_offerings", "service_inventories", on_delete: :nullify
  add_foreign_key "service_offerings", "service_offering_icons", on_delete: :nullify
  add_foreign_key "service_offerings", "sources", on_delete: :cascade
  add_foreign_key "service_offerings", "tenants", on_delete: :cascade
  add_foreign_key "service_plans", "sources", on_delete: :cascade
  add_foreign_key "service_plans", "tenants", on_delete: :cascade
  add_foreign_key "tags", "tenants", on_delete: :cascade
  add_foreign_key "tasks", "sources", on_delete: :nullify
end
