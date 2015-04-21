module MasterCache
  # Gets a user type, this avoids trips to the db, only done once
  def self.getUserType(typeId)
    if @userTypes.nil?
      @userTypes = Role.all.order(:id).to_ary
    end
    idx = @userTypes.index do |element|
      element.id == typeId
    end
    if idx.nil?
      ''
    else
      @userTypes[idx].name
    end
  end
end