FactoryBot.define do
  factory :task do
    source

    state { :pending }
    status { :ok }
    owner { "Fred" }
  end
end
