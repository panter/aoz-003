namespace :convert do
  desc 'Convert erb views to slim'
  task erb2slim: :environment do
    html2haml_opts = '-e --unix-newlines --html-attributes --ruby19-attributes'
    Dir.glob('app/views/**/*.erb').each do |v|
      system("html2haml #{html2haml_opts} #{v} #{v.sub(/\.erb$/, '.haml')} && rm #{v}")
    end
    Dir.glob('app/views/**/*.haml').each do |h|
      system("haml2slim #{h} #{h.sub(/\.haml$/, '.slim')} && rm #{h}")
    end
  end
end
