require 'yaml'

namespace :active_storage do
  desc 'ActiveStorage actions'
  task move_paperclip_files: :environment do
    ActiveStorage::Attachment.find_each do |attachment|
      name = attachment.name
      filename = attachment.blob.filename
      record_type = attachment.record_type.tableize
      folder = ("%09d" % attachment.record_id).scan(/\d{3}/).join("/")
      source = "#{Rails.root}/public/system/#{record_type}/#{ActiveSupport::Inflector.pluralize(name)}/#{folder}/original/#{filename}"
      dest_dir = File.join(
        'storage',
        attachment.blob.key.first(2),
        attachment.blob.key.first(4).last(2)
      )
      dest = File.join(dest_dir, attachment.blob.key)

      FileUtils.mkdir_p(dest_dir)
      puts "Moving #{source} to #{dest}"
      FileUtils.cp(source, dest)
    end
  end

  def migrate(from, to)
    config_file = Pathname.new(Rails.root.join('config/storage.yml'))
    configs = YAML.safe_load(ERB.new(config_file.read).result) || {}

    from_service = ActiveStorage::Service.configure from, configs
    to_service   = ActiveStorage::Service.configure to, configs

    ActiveStorage::Blob.service = from_service

    puts "#{ActiveStorage::Blob.count} Blobs to go..."

    @failed_files = { failed: [] }

    ActiveStorage::Blob.find_each do |blob|
      print '.'
      file = Tempfile.new("file#{Time.now.to_f}")
      file.binmode
      file << blob.download
      file.rewind
      checksum = blob.checksum
      to_service.upload(blob.key, file, checksum: checksum)
      file.close
      file.unlink
    rescue ActiveStorage::IntegrityError
      puts "Rescued by ActiveStorage::IntegrityError statement. ID: #{blob.id} / Key: #{blob.key}"
      @failed_files[:failed] << { id: blob.id, key: blob.key, checksum: blob.checksum, error: 'ActiveStorage::IntegrityError'  }
      File.open('failed_files.yml', 'w') {|f| f.write(@failed_files.to_yaml ) } #Store
      next
    rescue Google::Cloud::InvalidArgumentError
      puts "Rescued by Google::Cloud::InvalidArgumentError statement. ID: #{blob.id} / Key: #{blob.key}"
      @failed_files[:failed] << { id: blob.id, key: blob.key, checksum: blob.checksum, error: 'Google::Cloud::InvalidArgumentError'  }
      File.open('failed_files.yml', 'w') {|f| f.write(@failed_files.to_yaml ) } #Store
      next
    rescue Google::Apis::ClientError
      puts "Rescued by Google::Apis::ClientError statement. ID: #{blob.id} / Key: #{blob.key}"
      @failed_files[:failed] << { id: blob.id, key: blob.key, checksum: blob.checksum, error: 'Google::Apis::ClientError'  }
      File.open('failed_files.yml', 'w') {|f| f.write(@failed_files.to_yaml ) } #Store
      next
    rescue Errno::ENOENT
      puts "Rescued by Errno::ENOENT statement. ID: #{blob.id} / Key: #{blob.key}"
      @failed_files[:failed] << { id: blob.id, key: blob.key, checksum: blob.checksum, error: 'Errno::ENOENT'  }
      File.open('failed_files.yml', 'w') {|f| f.write(@failed_files.to_yaml ) } #Store
      next
    rescue ActiveStorage::FileNotFoundError
      puts "Rescued by FileNotFoundError. ID: #{blob.id} / Key: #{blob.key}"
      @failed_files[:failed] << { id: blob.id, key: blob.key, checksum: blob.checksum, error: 'ActiveStorage::FileNotFoundError'  }
      File.open('failed_files.yml', 'w') {|f| f.write(@failed_files.to_yaml ) } #Store
      next
    end
    File.open('failed_files.yml', 'w') {|f| f.write(@failed_files.to_yaml ) } #Store
  end

  task migrate_to_s3: :environment do
    migrate(:local, :google)
  end
end
