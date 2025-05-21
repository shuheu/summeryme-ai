# == Schema Information
#
# Table name: todos
#
#  id          :bigint           not null, primary key
#  title       :string(255)      not null
#  description :text(65535)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Todo < ApplicationRecord
  validates :title, presence: true
end
