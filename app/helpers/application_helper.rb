module ApplicationHelper
  def formatDate(value)
    return value.strftime('%m/%d/%Y %l:%M %p') if !value.nil?
    return '';
  end
end
