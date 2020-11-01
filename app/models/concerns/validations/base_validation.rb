module Validations
  module BaseValidation
    def errors?
      !errors[:base].empty?
    end
  end
end
