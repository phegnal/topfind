namespace :fileImport do


  # TEST TASK
  #
  #
  #
  desc "test that this file is read"
  task :test do
    puts "test works"
  end

  
  # EXPORT EVIDENCES AND IMPORTS
  #
  # => This takes existing imports and extracts evidences and writes those information to files
  #
  desc "Export and save imports and their evidences"
  task :export do
    require "#{RAILS_ROOT}/config/environment"
        
    Import.find_each do |import|
      Rake::Task["fileImport:export_one"].execute(:import_id => import.id)
    end
  end
  
  desc "Export and save one import"
  task :export_one , :import_id do |t, args|
    require "#{RAILS_ROOT}/config/environment"
    
    sep = "\t"
    
    import_id = args[:import_id]
    import = Import.find(import_id)
    
    if !File.exist?("#{RAILS_ROOT}/public/system/csvfiles/#{import_id}") then
      Dir.mkdir("#{RAILS_ROOT}/public/system/csvfiles/#{import_id}/")
    end
    
    importInfoFile = File.open("#{RAILS_ROOT}/public/system/csvfiles/#{import.id}/ImportInfoFile.txt", "w")
    import.attributes.each_pair{|key, value|
      importInfoFile << "#{key}#{sep}#{value.to_s.gsub(/\r\n/, "newLine")}\n"
    }
    importInfoFile.close
    
    evidence = Evidence.find(import.evidence_id)
    evidenceInfoFile = File.open("#{RAILS_ROOT}/public/system/csvfiles/#{import.id}/EvidenceInfoFile.txt", "w")
    evidence.attributes.each_pair{|key, value|
      evidenceInfoFile << "#{key}#{sep}#{value.to_s.gsub(/\r\n/, "newLine")}\n"
    }
    evidenceInfoFile.close
  end
  
  
  
  # LOAD IMPORTS FROM EXPORTED FILES
  #
  #
  #
  desc "Add saved Imports to the database"
  task :load_imports do
      require "#{RAILS_ROOT}/config/environment"
      Dir.entries("#{RAILS_ROOT}/public/system/csvfiles/").each{ |f| 
        if f.match(/^\d+$/) then
          Rake::Task["fileImport:load_one_import"].execute(:import_id => import.id)
        end
      }
  end
  
  desc "Add one saved Import to the database"
  task :load_one_import, :import_id do |t, args|
      require "#{RAILS_ROOT}/config/environment"

      import_id = args[:import_id]

      importInfoFile = File.open("#{RAILS_ROOT}/public/system/csvfiles/#{import_id}/ImportInfoFile.txt", "r")
      evidenceInfoFile = File.open("#{RAILS_ROOT}/public/system/csvfiles/#{import_id}/EvidenceInfoFile.txt", "r")
      
      i = {}
      e = {}
      
      importInfoFile.each_line do |line|
        l = line.gsub(/\n/, "").split("\t")
        i[l[0]] = l[1].gsub(/newLine/, "\r\n")
      end
      
      evidenceInfoFile.each_line do |line|
        l = line.gsub(/\n/, "").split("\t")
        e[l[0]] = l[1].gsub(/newLine/, "\r\n")
      end
        
      require 'time'
        
      def toTime(x)
        return x.nil? ? nil : Time.parse(x)
      end
      
      def toInt(x)
        return x.nil? ? nil : x.to_i
      end
      
      def toFloat(x)
        return x.nil? ? nil : x.to_f
      end
        
      evidence = Evidence.find_or_create_by_name(
      # :id => e.id,
      :updated_at => toTime(e["updated_at"]),
      :evidencefile_file_size => toInt(e["evidencefile_file_size"]),
      :evidencesource_id => toInt(e["evidencesource_id"]),
      :method_system => e["method_system"],
      :protease_inhibitors_used => e["protease_inhibitors_used"],
      :confidence => toFloat(e["confidence"]),
      :lab => e["lab"],
      :method_protease_source => e["method_protease_source"],
      :name => e["name"],
      :repository => e["repository"],
      :phys_relevance => e["phys_relevance"],
      :proteaseassignment_confidence => e["proteaseassignment_confidence"],
      :evidencefile_updated_at => toTime(e["evidencefile_updated_at"]),
      :method_perturbation => e["method_perturbation"],
      :directness => e["directness"],
      :methodology => e["methodology"],
      :created_at => toTime(e["created_at"]),
      :idstring => e["idstring"],
      :evidencefile_file_name => e["evidencefile_file_name"],
      :confidence_type => e["confidence_type"],
      :evidencefile_content_type => e["evidencefile_content_type"],
      :method => e["method"],
      :owner_id => toInt(e["owner_id"]),
      :description => e["description"]
      )
      evidence.save
        
      import = Import.find_or_create_by_name(
      # :id => i.id,
      :name => i["name"],
      :evidence_id => evidence.id,
      :nterms_imported => toInt(i["nterms_imported"]),
      :csvfile_updated_at => toTime(i["csvfile_updated_at"]),
      :inhibitions_imported => toInt(i["inhibitions_imported"]),
      :inhibitions_listed => toInt(i["inhibitions_listed"]),
      :csvfile_file_name => i["csvfile_file_name"],
      :updated_at => toTime(i["updated_at"]),
      :csvfile_content_type => i["csvfile_content_type"],
      :cterms_imported => toInt(i["cterms_imported"]),
      :created_at => toTime(i["created_at"]),
      :cterms_listed => toInt(i["cterms_listed"]),
      :cleavagesites_listed => toInt(i["cleavagesites_listed"]),
      :cleavagesites_imported => toInt(i["cleavagesites_imported"]),
      :csvfile_file_size => toInt(i["csvfile_file_size"]),
      :description => i["description"],
      :nterms_listed => toInt(i["nterms_listed"]),
      :cleavages_listed => toInt(i["cleavages_listed"]),
      :datatype => i["datatype"],
      :cleavages_imported => toInt(i["cleavages_imported"]),
      :owner_id => toInt(i["owner_id"])
      )
      import.save

      
      importInfoFile.close
      evidenceInfoFile.close
  end
  

end