class LabelDelegate
  def initialize (filename, path, content)
    @filename = filename
    @path = path
    @content = content
  end

  def write_file
    # puts "#{File.join(Rails.root, @path, @filename)}"
    f=File.open(File.join(Rails.root, @path, @filename), 'w')
    f.write(@content)
    f.close
  end


end
