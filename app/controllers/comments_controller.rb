class CommentsController < ApplicationController
  authorize_resource :only => [:destroy]

  def show
  end
  
  def create
    @comment = Comment.new(comment_params)
    @comment.event = Event.find(params[:event_id])
    unless comment_params[:parent_id].nil?
      Comment.find(comment_params[:parent_id]).new_comment @comment
    end
    @comment.save
    render action: 'show', status: :created, location: @comment 
  end

  def destroy
    Comment.find(params[:id]).destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def comment_params
      params.permit(:message,
                    :event_id,
                    :parent_id
      ).merge(authored_by: current_user)
  end

end
