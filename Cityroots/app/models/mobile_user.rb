# == Schema Information
#
# Table name: mobile_users
#
#  id          :integer          not null, primary key
#  firstname   :string(100)
#  surname     :string(100)
#  gender      :string(1)
#  dateofbirth :date
#  active      :boolean          not null
#

class MobileUser < ActiveRecord::Base
	belongs_to :user, :foreign_key => "id"
	has_many :comment_events, dependent: :destroy
	has_many :comment_services, dependent: :destroy
	has_many :comment_attractions, dependent: :destroy
	has_many :comment_itineraries, dependent: :destroy
	has_many :rating_events, dependent: :destroy
	has_many :rating_services, dependent: :destroy
	has_many :rating_attractions, dependent: :destroy
	has_many :rating_itineraries, dependent: :destroy
end
