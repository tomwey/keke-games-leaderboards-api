class Score < ActiveRecord::Base
  attr_accessible :leaderboard_id, :user_id, :value
  
  belongs_to :user
  belongs_to :leaderboard
  
  PER_PAGE = 10
  
  scope :sort_by_value, lambda { order('value desc') }
  
  def self.page(page, size)
    offset = (page - 1) * size
    offset(offset).limit(size)
  end
  
  def rank
    Score.where('value > ? and leaderboard_id = ?', value, self.leaderboard.id).count + 1
  end
  
  def as_json(options)
    {
      id: self.id,
      score: self.value,
      uid: self.user.try(:udid),
      uname: self.user.try(:name)
    }
  end
  
end
