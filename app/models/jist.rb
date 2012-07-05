class Jist < ActiveRecord::Base

  JIST_REPO = "#{Rails.root}/tmp/gists/"
  
  after_create :initialize_repo

  def after_initialize
    @repo = nil
  end

  def paste=(paste)
    
  end

  def paste
    @repo.commits if @repo.present?
  end

  private
  
  def initialize_repo
    @repo ||= Grit::Repo.init_bare("#{JIST_REPO}#{id}.git")
  end

end
