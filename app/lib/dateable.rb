# frozen_string_literal: true

# fix date ranges if the initially parsed start date is < the initially parsed end date
module Dateable
  def broken_range?
    end_at && start_at > end_at
  end

  def fix_end_year(_start_date, _end_date)
    return unless start_at && end_at

    end_date.additional_date_values.first.update(date: end_at.to_date.change(year: end_at.year + 1)) if broken_range?
    # if broken_range?
    #   start_date.additional_date_values.first.update(date: start_at.to_date.change(year: end_at.year - 1))
    # end
  end
end
