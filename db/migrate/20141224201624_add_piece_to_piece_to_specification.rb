class AddPieceToPieceToSpecification < ActiveRecord::Migration
  def change
    add_column :specifications, :piece_to_piece, :boolean
  end
end
