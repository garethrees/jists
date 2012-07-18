module JistsHelper

  def file_language(file)
    case File.extname(file)
    when '.coffee'
      'coffeescript'
    when '.css'
      'css'
    when '.html'
      'html'
    when '.js'
      'javascript'
    when '.php'
      'php'
    when '.py'
      'python'
    when '.rb'
      'ruby'
    when '.sh'
      'shell'
    end
  end

end
