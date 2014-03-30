# -*- encoding : utf-8 -*-
class UsernameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /[a-z][a-z0-9_]+/i
      record.errors[attribute] << (options[:message] || "invalid username")
    end
  end
end

class MobileValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless KA.correct_mobile?(value.to_s)
      record.errors[attribute] << (options[:message] || "is not mobile")
    end
  end
end
