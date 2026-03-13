class AddVerificationToTatoueurs < ActiveRecord::Migration[8.1]
  def change
    add_column :tatoueurs, :verified,                    :boolean, default: false, null: false
    add_column :tatoueurs, :verification_status,         :string,  default: "unsubmitted"
    add_column :tatoueurs, :verification_submitted_at,   :datetime
    add_column :tatoueurs, :verification_reviewed_at,    :datetime
    add_column :tatoueurs, :verification_rejected_reason, :text

    # SIREN
    add_column :tatoueurs, :siren, :string

    # Infos déjà présentes : iban, bic ✓
  end
end
