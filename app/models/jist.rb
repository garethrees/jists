class Jist < ActiveRecord::Base

  JIST_REPO = "#{Rails.root}/tmp/gists/"
  
  after_create :init_repo
  after_save   :update_paste


  # def after_initialize
  #   @repo = nil
  # end

  # The first file's contents "saved" for when repo is set up
  def paste=(paste)
    @paste = paste
  end

  # Return first file's contents for edit box
  # TODO: wont need this soon hopefuly
  def paste
    head.tree.blobs.first.data.to_s if repo.present?
  end

  # Each file's data including filename and contents
  def files
    files = []
    head.tree.contents.map do |blob|
      files << { :name => blob.name, :data => blob.data }
    end
    files
  end

  def head
    commits.first if repo.present?
  end

  # List of commits
  # Don't know why HEAD is commits.last - file issue?
  def commits
    repo.commits.reverse if repo.present?
  end

  def update_paste
    Rails.logger.info "UPDATING PASTE WITH: #{@paste}"
    i = repo.index
    i.read_tree("master")
    i.add("gistfile.txt", @paste.to_s)
    i.commit('', [repo.commits.first])
  end

  def repo
      @repo = Grit::Repo.new("#{JIST_REPO}#{id}.git") unless self.new_record?
      Rails.logger.info "REPO: #{@repo.inspect}"
      return @repo

    # @repo ||= Grit::Repo.init_bare("#{JIST_REPO}#{id}.git")
  end

  def init_repo
    repo = Grit::Repo.init_bare("#{JIST_REPO}#{id}.git")
    Rails.logger.info "INIT REPO: #{repo.inspect}"
    repo.index.add('gistfile.txt', 'initial commit')
    repo.index.commit('initial')
    return repo
  end

end
