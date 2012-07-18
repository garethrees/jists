class Jist < ActiveRecord::Base

  # TODO: include / extend Grit::Repo?

  # The path to where the repos are saved
  REPO_PATH = Jists::Application.config.repo_path

  after_save :update_repo

  # The first file's contents "saved" for when repo is set up
  def paste=(paste)
    @paste = paste
  end

  def files=(jistfiles)
    debug __method__, jistfiles.inspect
    @files = jistfiles
  end

  # Returns first file's contents for new/edit textarea
  def paste
    head.tree.blobs.first.data.to_s if repo.present?
  end

  # Public: Each file's data including filename and contents
  #
  # commit_ref - A String SHA of the files at the time of the commit 
  #              (default - "HEAD")
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
  # TODO: Accept a filename and extension
  # TODO: Accept multiple files
  def update_repo
    r = repo
    i = r.index
    i.read_tree 'master'

    @files.each do |file, data|
      if data['filename'].present?
        i.add data['filename'], @paste.to_s
      else
        i.add "#{ file }.txt", @paste.to_s
      end
    end

    if r.commit_count.zero?
      i.commit 'Initial Commit'
    else
      i.commit '', [repo.commits.first]
    end
    touch :updated_at
  end

  # Replace non-word characters with underscores
  #
  # Returns a String
  def sanitize_filename(filename)
    # http://devblog.muziboo.com/2008/06/17/attachment-fu-sanitize-filename-regex-and-unicode-gotcha/
    # filename.strip!
    # TODO: Check for and sanitize extension
    # Replace all non alphanumeric, underscore or periods with underscore
    # filename.gsub!(/[^0-9A-Za-z.\-]/, '_')
    # TODO: Replace multiple underscores with a single underscore
    # filename.gsub!(/_{2,}/, '_')
    # TODO: Remove any trailing underscores before file extension
    # filename.gsub!(/(_.)/, '.')
  end

  def debug(caller_name = nil, msg = nil)
    Rails.logger.debug "\n#== #{self.class}##{caller_name} >> #{msg}\n"
  end

end
