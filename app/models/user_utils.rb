
class UserUtils

  def self.get_begin_of_day_offset(datetime, offset)
    datetime = datetime.beginning_of_day
    datetime = datetime - (offset.to_i.minutes)
    return datetime
    end

  def self.get_end_of_day_offset(datetime, offset)
    datetime = datetime.end_of_day
    datetime = datetime - (offset.to_i.minutes)
    return datetime
  end

  def self.get_date_to_store_offset(datetime, offset)
    datetime = datetime.utc + (offset.to_i.minutes)
    return datetime
  end

end