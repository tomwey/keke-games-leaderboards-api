# coding: utf-8
module KeKeGameLeaderboard
  class UsersAPI < Grape::API
    format :json
    
    resources 'leaderboards' do
      segment ':leaderboard_id' do
        resources 'users' do
          get '/' do
            @leaderboard = Leaderboard.find(params[:leaderboard_id])
            page = params[:page] ? params[:page].to_i : 1
            @scores = @leaderboard.scores.sort_by_value.page(page)
            { code: 0, message: 'ok', data: @scores }
          end # end get '/'
          
          get ':id' do
            @leaderboard =  Leaderboard.find(params[:leaderboard_id])
            @user = User.find_by_udid(params[:id])
            unless @user
              return { code: 404, message: 'Not Found User' }
            end
            @score = @leaderboard.scores.where(user_id: @user.id).first
            { code: 0, message: 'ok', data: { score: @score.value, rank: @score.rank } }
          end #end get '/users/1.json'
          
          # 上传分数
          params do
            requires :score, type: Integer
            requires :uid, type: String
            requires :uname, type: String
          end
          
          post '/' do
            @leaderboard = Leaderboard.find(params[:leaderboard_id])
            @user = User.find_by_udid(params[:uid])
            if @user.blank?
              @user = User.create!(udid: params[:uid], name: params[:uname])
            else
              @user.update_attributes(name: params[:uname])
            end
            
            @score = @leaderboard.scores.where(:user_id => @user.try(:id)).first
            if @score.blank?
              @score = Score.create!(value: params[:score].to_i, user_id: @user.id, leaderboard_id: @leaderboard.id)
            else
              @score.update_attributes(:value => params[:score].to_i)
            end
            
            if @score
              { code: 0, message: 'ok', data: @score }
            else
              { code: 21001, message: 'created failure.' }
            end
            
          end # end post
          
        end # end users resources
      end # end segment
    end # end resources
  end # end class
end # end module