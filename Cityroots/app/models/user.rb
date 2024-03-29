# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      not null
#  username               :string(50)
#  encrypted_password     :string(500)      not null
#  type                   :string(255)
#  serviceid              :text
#  language_id            :integer
#  country_id             :integer
#  reset_password_token   :string(150)
#  reset_password_sent_at :date
#  remember_created_at    :date
#  sign_in_count          :integer
#  current_sign_in_at     :date
#  last_sign_in_at        :date
#  current_sign_in_ip     :string(50)
#  last_sign_in_ip        :string(50)
#  confirmation_token     :string(150)
#  confirmed_at           :date
#  confirmation_sent_at   :date
#  unconfirmed_email      :string(50)
#  failed_attempts        :integer
#  unlock_token           :string(50)
#  locked_at              :date
#


class User < ActiveRecord::Base
	validates :email , presence: true, uniqueness: true
	validates :encrypted_password , presence: true
  validates :username, uniqueness: { message: "Este username já se encontra registado, escolha outro" }
	validates :city_id , presence: false
	validates :language_id , presence: true
	belongs_to :city
  belongs_to :country
	belongs_to :language
  has_one :web_user, :foreign_key => "id", dependent: :destroy
  has_many :itineraries, dependent: :destroy
  has_one :mobile_user, :foreign_key => "id", dependent: :destroy
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook]
  accepts_nested_attributes_for :web_user , :reject_if => :all_blank, :allow_destroy => true


  after_initialize :init_variables

  def init_variables
    @list_roles = Array.new
  end

  def create_list_roles
    @list_roles=Array.new
    if self.web_user && !self.id.nil?
      puts " INFO : Cria lista de roles." 
      if self.web_user.web_user_type.name == "Entidade"
        if self.web_user.active 
          @list_roles.push "entidade" 
        else
          @list_roles.push "entidade_nao_activa" 
        end
      end
      @list_roles.push "admin" if self.web_user.web_user_type.name == "Admin"
      unless self.web_user.web_user_packs.nil? 
        self.web_user.web_user_packs.each do |web_user_pack|
          if Date.today < web_user_pack.validity && web_user_pack.active
            @list_roles.push "restauracao_gold" 
          end
        end
      end
      if self.web_user.web_user_type.name == "Comércio" &&  !(@list_roles.include? "restauracao_gold")
          @list_roles.push "restauracao" 
      end 
    end

    if self.web_user.nil? && !self.id.nil?
      @list_roles.push "new_user" if self.web_user.blank?
    end

  end


  def role?(arg)
    create_list_roles if @list_roles.blank? 
    puts "INFO: Roles= " + @list_roles.inspect
    @list_roles.include? arg.to_s
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end


  def self.find_for_facebook_oauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email
      user.country_id = 188
      user.language_id = 1
      user.password = Devise.friendly_token[0,20]
      user.username = auth.info.name   # assuming the user model has a name
    #  user.image = auth.info.image # assuming the user model has an image
      user.save
    end
  end


end

