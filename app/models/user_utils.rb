
class UserUtils

  def self.get_day_to_show(datetime, offset)
    if !offset.nil?
      datetime = datetime - (offset.to_i.minutes)
    end
    return datetime
  end

  def self.get_begin_of_day_offset(datetime, offset)
    datetime = datetime.beginning_of_day
    if !offset.nil?
      datetime = datetime - (offset.to_i.minutes)
    end
    return datetime
  end

  def self.get_end_of_day_offset(datetime, offset)
    datetime = datetime.end_of_day
    if !offset.nil?
      datetime = datetime - (offset.to_i.minutes)
    end
    return datetime
  end

  def self.get_date_to_store_offset(datetime, offset)
    if !offset.nil?
      datetime = datetime.utc + (offset.to_i.minutes)
    end
    return datetime
  end

end