class Jist < ActiveRecord::Base

  JIST_REPO = "#{Rails.root}/tmp/gists/"

  after_save :update_repo

  # The first file's contents "saved" for when repo is set up
  def paste=(paste)
    @paste = paste
  end

  # Return first file's contents for edit box
  # TODO: wont need this soon hopefuly
  def paste
    head.commit.tree.blobs.first.data.to_s if repo.present? && head
  end

  # Each file's data including filename and contents
  def files
    files = []
    head.commit.tree.contents.map do |blob|
      files << { :name => blob.name, :data => blob.data }
    end
    files
  end

  def head
    debug __method__, "head: #{repo.head}"
    repo.head if repo.present?
  end

  # List of commits
  # Don't know why HEAD is commits.last - file an issue?
  def commits
    debug __method__, "commits: #{repo.commits}"
    repo.commits if repo.present?
  end



  # def repo
  #   # @repo ||= Grit::Repo.init_bare_or_open("#{JIST_REPO}#{id}.git")
  #   # Rails.logger.info "REPO: #{@repo.inspect}"
  # end

  def repo
      @repo = Grit::Repo.new("#{JIST_REPO}#{id}.git") unless self.new_record?
      debug __method__, "@repo: #{@repo.inspect}"
      return @repo
  
    # @repo ||= Grit::Repo.init_bare("#{JIST_REPO}#{id}.git")
  end


  private

  def update_repo
    @repo = Grit::Repo.init_bare_or_open("#{JIST_REPO}#{id}.git")
    i = repo.index
    i.read_tree 'master'
    i.add 'gistfile.txt', @paste.to_s

    if @repo.commits.size == 0
      i.commit 'Initial Commit'
    else
      i.commit '', [repo.commits.first]
    end
  end

  def debug(caller_name = nil, msg = nil)
    Rails.logger.debug "\n#== #{self.class}##{caller_name} >> #{msg}\n"
  end

end
