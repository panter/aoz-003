namespace :gettext do
  def files_to_translate
    Dir.glob('{app,config,locale}/**/*.{rb,slim,rhtml}')
  end
end
