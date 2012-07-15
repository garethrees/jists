class Jist < ActiveRecord::Base

  # TODO: include / extend Grit::Repo?

  # The path to the repos are saved
  # TODO: Move to environment config
  REPO_PATH = Jists::Application.config.repo_path

  after_save :update_repo

  # The first file's contents "saved" for when repo is set up
  def paste=(paste)
    @paste = paste
  end

  # Returns first file's contents for new/edit textarea
  def paste
    head.tree.blobs.first.data.to_s if repo.present?
  end

  # Public: Each file's data including filename and contents
  #
  # commit_ref - A String SHA of the files at the time of the commit
  #
  # Returns an Array
  def files(commit_ref = nil)
    files = []
    sha = commit_ref.present? ? commit_ref : head.id

    repo.commit(sha).tree.contents.map do |blob|
      files << { name: blob.name, data: blob.data }
    end

    return files
  end

  # Public: The latest commit in the repo
  #
  # Returns a Grit::Commit?
  def head
    debug __method__, "head: #{repo.head}"
    repo.head.commit
  end

  # Public: List of commits
  #
  # Returns an Array of ...
  def commits
    debug __method__, "commits: #{repo.commits}"
    repo.commits
  end

  # Find or create a Grit::Repo unless self is not persisted
  #
  # Returns a Grit::Repo
  def repo
    @repo ||= Grit::Repo.init_bare_or_open("#{REPO_PATH}#{id}.git") unless self.new_record?
  end

  #============================================================================
  # PRIVATE
  #============================================================================

  private

  # Update the Grit::Repo with the paste data
  #
  # TODO: Accept a custom commit message
  # TODO: Accept a filename
  # TODO: Accept multiple files
  def update_repo
    r = repo
    i = r.index
    i.read_tree 'master'
    i.add 'gistfile.txt', @paste.to_s

    if r.commit_count.zero?
      i.commit 'Initial Commit'
    else
      i.commit '', [repo.commits.first]
    end
    touch :updated_at
  end

  def debug(caller_name = nil, msg = nil)
    Rails.logger.debug "\n#== #{self.class}##{caller_name} >> #{msg}\n"
  end

end
