class AddPieceToPieceToRelationships < ActiveRecord::Migration
  def change
    add_column :relationships, :piece_to_piece, :boolean, default: false
  end
end
