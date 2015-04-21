module DeleteableModel
  def not_deleted
    self.where(deleted: false)
  end
end