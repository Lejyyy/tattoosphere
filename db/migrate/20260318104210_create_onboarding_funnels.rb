class CreateOnboardingFunnels < ActiveRecord::Migration[8.1]
  def change
    create_table :onboarding_funnels do |t|
      t.references :user,         null: false, foreign_key: true
      t.string     :kind,         null: false  # "tatoueur" ou "shop"
      t.string     :step,         null: false, default: "clicked"
      # "clicked" > "form_completed" > "subscription_page_visited" > "plan_selected" > "subscribed"
      t.string     :plan_selected                # quel plan a été cliqué
      t.datetime   :form_completed_at
      t.datetime   :subscription_page_visited_at
      t.datetime   :plan_selected_at
      t.datetime   :subscribed_at

      # Relances
      t.datetime   :reminder_1_sent_at   # +1h
      t.datetime   :reminder_2_sent_at   # +24h
      t.datetime   :reminder_3_sent_at   # +5j

      t.timestamps
    end

    add_index :onboarding_funnels, [ :user_id, :kind ], unique: true
  end
end
