class Certificate < ApplicationRecord
  belongs_to :volunteer
  belongs_to :user
end
