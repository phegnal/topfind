desc "terministats"
task :export_terministats => :environment do
  
  require 'fastercsv'

  filename = '101006-1-all-nterm-stats'

  #path = '/Users/PhilippLange/Documents/science/data/data-analysis/'
  path = '/Volumes/MMPfileserver/lab/Documents/Philipp/topcat_analysis/'
  date = Date::today.to_s
  Dir.chdir(path)
  Dir.mkdir(date) unless  File.exists?(date)
  Dir.chdir(date)

  cls =  [["P16015", "2"], ["", "22"], ["P03953", "26"], ["P19001", "53"], ["Q91WS0", "2"], ["O09165", "29"], ["", "23"], ["P37804", "2"], ["P12787", "38"], ["Q05920", "21"], ["Q05920", "20"], ["Q9ET01", "2"], ["P04117", "17"], ["P19096", "362"], ["P19096", "430"], ["Q16762", "2"], ["P07356", "25"], ["Q8BFR5", "240"], ["Q8QZS1", "30"], ["Q8BMS1", "30"], ["Q8BH95", "117"], ["P58252", "112"], ["P48774", "2"], ["P31786", "2"], ["P30115", "2"], ["P61978", "139"], ["P07724", "445"], ["P49817", "2"], ["Q9CR68", "79"], ["P04117", "14"], ["Q61805", "26"], ["Q7TMF3", "1"], ["P03953", "26"], ["P07724", "25"], ["", "2"], ["P31725", "12"], ["Q3UIU2", "2"], ["", "43"], ["P56480", "48"], ["P07910", "108"], ["Q8VEK3", "234"], ["P29699", "19"], ["O09164", "23"], ["Q60932", "15"], ["O88696", "53"], ["Q00839", "197"], ["P31725", "15"], ["P10649", "2"], ["", "34"], ["", "1"], ["P01791", "1"], ["Q8R1I1", "2"], ["P01027", "671"], ["Q8VEK3", "190"], ["", "2"], ["", "75"], ["", "32"], ["P49945", "169"], ["", "71"], ["Q80W21", "2"], ["Q9CPQ1", "2"], ["P53996", "40"], ["P01873", "249"], ["Q8NC51", "2"], ["O88569", "1"], ["O35955", "40"], ["Q9CQA3", "31"], ["P31725", "4"], ["", "20"], ["Q9WTP6", "2"], ["P84090", "2"], ["Q91Z53", "7"], ["Q8BG05", "1"], ["O35737", "363"], ["P70404", "39"], ["O08709", "2"], ["", "48"], ["P28063", "205"], ["Q91X72", "93"], ["O89086", "28"], ["P07724", "592"], ["Q91X72", "155"], ["Q92945", "100"], ["P10605", "78"], ["Q8BH97", "21"], ["P07724", "473"], ["P07724", "444"], ["Q8QZT1", "31"], ["P07724", "363"], ["Q14498", "139"], ["P20029", "89"], ["Q00839", "729"], ["P56480", "47"], ["P01746", "20"], ["P07724", "155"], ["", "567"], ["O09164", "21"], ["Q9WVK4", "1"], ["", "2"], ["Q8BIJ6", "45"], ["P00558", "2"], ["", "16"], ["P61978", "39"], ["P07724", "443"], ["P62631", "257"], ["P68134", "21"], ["P08249", "163"], ["Q99NB9", "2"], ["", "111"], ["", "236"], ["O35215", "2"], ["P02089", "21"], ["P01027", "25"], ["Q9CYR0", "18"], ["Q9CQQ7", "43"], ["Q5SW19", "2"], ["P07724", "438"], ["Q9Z0J0", "70"], ["P10853", "65"], ["P19157", "2"], ["Q9R0P3", "2"], ["O88844", "329"], ["Q61171", "151"], ["P02089", "17"], ["Q60710", "1"], ["Q8CI94", "2"], ["O08583", "144"], ["O89086", "27"], ["", "17"], ["O08795", "80"], ["", "32"], ["Q9HB40", "36"], ["Q91WQ3", "2"], ["P04406", "4"], ["", "20"], ["Q9Y5R8", "2"], ["", "22"], ["P01887", "21"], ["", "21"], ["Q03265", "44"], ["Q9Y493", "1162"], ["Q9Z0N1", "2"], ["O35639", "20"], ["P08758", "189"], ["P63017", "63"], ["", "82"], ["Q9D211", "2"], ["P02088", "21"], ["Q9ERE7", "30"], ["P01027", "749"], ["", "32"], ["Q8CB59", "452"], ["P08228", "88"], ["Q16740", "57"], ["", "142"], ["Q9D8N0", "368"], ["O35639", "11"], ["", "2"], ["P08249", "179"], ["Q61838", "1366"], ["P08670", "258"], ["Q05816", "2"], ["Q8BG05", "1"], ["P19783", "23"], ["Q9DBG6", "23"], ["O35129", "2"], ["Q9DBJ1", "2"], ["", "29"], ["P08228", "108"], ["P07356", "184"], ["Q91YQ5", "26"], ["P19096", "1257"], ["P29401", "464"], ["P68134", "23"], ["Q9CZY3", "2"], ["P62137", "2"], ["P19253", "2"], ["P26883", "2"], ["P46471", "2"], ["Q9QUH0", "54"], ["P97821", "228"], ["P10605", "79"], ["Q99KJ8", "2"], ["", "90"], ["Q99798", "635"], ["", "395"], ["P68134", "44"], ["Q9D1A2", "2"], ["P83731", "7"], ["", "2"], ["Q61792", "99"], ["Q9Y6R7", "478"], ["Q9CQV8", "2"], ["", "71"], ["O14556", "312"], ["P68134", "91"], ["P02088", "15"], ["P19387", "2"], ["Q01853", "717"], ["", "1"], ["P15954", "17"], ["P21981", "309"], ["Q99JI4", "2"], ["Q9NR45", "2"], ["P68134", "235"], ["", "441"], ["P10126", "412"], ["P61161", "285"], ["A8MW06", "28"], ["O15144", "1"], ["Q86UX7", "499"], ["P63017", "163"], ["", "206"], ["", "31"], ["Q9D2M8", "2"], ["Q9CR51", "2"], ["", "243"], ["P61981", "2"], ["", "462"], ["P07355", "284"], ["", "132"], ["P06745", "109"], ["P63101", "1"], ["P48036", "6"], ["Q9CQV8", "3"], ["Q562R1", "54"], ["P97379", "3"], ["Q9Z2X1", "2"], ["Q9CYR0", "17"], ["P14618", "425"], ["O15428", "2"], ["Q562R1", "149"], ["P35564", "392"], ["P48036", "2"], ["P62736", "303"], ["P60867", "2"], ["", "41"], ["", "2"], ["P13639", "829"], ["P27773", "25"], ["Q9CYG7", "2"], ["P03958", "212"], ["", "63"], ["P08113", "22"], ["P08238", "630"], ["P61513", "73"], ["P10126", "83"], ["P60710", "297"], ["P60709", "15"], ["Q9CZX8", "2"], ["P68134", "20"], ["Q9CWF2", "142"], ["P62259", "178"], ["P49591", "2"], ["P62631", "258"], ["P49962", "2"], ["P54071", "368"], ["Q923D2", "2"], ["P62736", "302"], ["P51410", "157"], ["P68134", "241"], ["O75190", "2"], ["Q8CDN6", "2"], ["P48036", "275"], ["P60709", "148"], ["", "46"], ["Q7Z7H5", "30"], ["P24452", "330"], ["P23528", "23"], ["Q9QZD9", "1"], ["P21107", "2"], ["", "2"], ["P62736", "304"], ["Q9D8E6", "87"], ["P67812", "1"], ["Q91YI0", "2"], ["P97351", "203"], ["P63087", "2"], ["", "157"], ["P17742", "2"], ["", "2"], ["P80314", "2"], ["P63272", "2"], ["P20152", "51"], ["P07901", "52"], ["", "1"], ["Q14677", "1"], ["P68371", "35"], ["P68134", "31"], ["Q9JII6", "84"], ["", "64"], ["Q9DAU1", "38"], ["Q8BJZ4", "23"], ["Q9CWF2", "115"], ["", "170"], ["P50395", "43"], ["O15511", "2"], ["P97379", "2"], ["", "1"], ["P14618", "45"], ["P24452", "8"], ["Q9CR21", "69"], ["", "147"], ["Q62093", "2"], ["Q9CXW4", "2"], ["Q99PT1", "34"], ["P68134", "234"], ["P60709", "199"], ["P08030", "2"], ["P17742", "4"], ["", "41"], ["Q9CZM2", "97"], ["P70195", "44"], ["P68134", "237"], ["O95456", "2"], ["P62259", "1"], ["P67936", "2"], ["Q9D8T7", "2"], ["P47756", "103"], ["Q9R0Q7", "1"], ["P68369", "381"], ["P13639", "828"], ["", "33"], ["Q92945", "132"], ["P80317", "2"], ["P09104", "39"], ["Q15084", "72"], ["Q9R1T2", "2"], ["", "61"], ["Q9WTM5", "2"], ["", "2"], ["P47753", "2"], ["P68134", "236"], ["P47199", "2"], ["", "2"], ["P68254", "1"], ["P20152", "54"], ["O75832", "174"], ["Q9CWF2", "145"], ["P60709", "13"], ["Q9CQ71", "1"], ["Q9D0F3", "33"], ["P02463", "1439"], ["O08586", "2"], ["", "65"], ["Q9CWF2", "110"], ["P60709", "14"], ["", "54"], ["P68371", "53"], ["P58252", "2"], ["Q9EQQ9", "40"], ["P60710", "2"], ["O89023", "195"], ["Q9CWF2", "143"], ["", "2"], ["", "2"], ["P68369", "51"], ["P62937", "77"], ["P10107", "2"], ["Q61792", "186"], ["P52565", "101"], ["P47754", "2"], ["P17182", "310"], ["Q9CWF2", "109"], ["P70349", "2"], ["Q60972", "2"], ["Q99JW2", "2"], ["P68369", "147"], ["P60710", "358"], ["Q9JL62", "2"], ["", "666"], ["Q8JZQ9", "7"], ["P97493", "60"], ["Q01768", "2"], ["Q91YR1", "2"], ["P31230", "2"], ["P68036", "114"], ["P28656", "46"], ["", "107"], ["", "38"], ["Q8BJW6", "2"], ["P02042", "96"], ["Q9D8Y0", "2"], ["", "2"], ["Q9CZM2", "2"], ["O54782", "686"], ["O88342", "2"], ["P34884", "2"], ["P62158", "114"], ["", "364"], ["Q9HB71", "199"], ["Q08209", "2"], ["P07901", "675"], ["Q60973", "2"], ["P20152", "55"], ["P16045", "63"], ["P14069", "43"], ["P08670", "205"], ["Q06830", "53"], ["P08670", "325"], ["", "36"], ["", "32"], ["P48024", "14"], ["P61979", "306"], ["B2RPK0", "17"], ["Q8BGD9", "357"]]
  ident_total = 0
  annotated_total = 0 
  overlap_total = 0
  new_total = 0
  missed_total = 0
  
  
  
  FasterCSV.open("#{filename}.csv", "w") do |csv|
  csv << ['ac','name','nterms-identified','n-terms annotated','overlap','# nterms-identified','# annotated n-terms','# overlap','# new','# missed']  

    prots = Hash.new
    cls.each do |cl|
      prots[cl[0]] ? prots[cl[0]] << cl[1].to_i : prots[cl[0]] = [cl[1].to_i]
    end
    
    prots.each_pair do |ac,ident|
      puts ac
      ident.uniq!
      p = Protein.ac_is(ac).first
      if p
        annotated = p.nterms.*.pos
        overlap = ident & annotated
        new = ident - overlap
        missed = annotated - ident
        
        ident_total = ident_total+ ident.count
        annotated_total = annotated_total + annotated.count 
        overlap_total = overlap_total + overlap.count 
        new_total = new_total + new.count
        missed_total = missed_total + missed.count       
      
        csv << [ac,p.recname,ident.join(','),annotated.join(','),overlap.join(','),ident.count,annotated.count,overlap.count,new.count,missed.count]   
      end
    end
    csv << ['total','','','','',ident_total,annotated_total,overlap_total,new_total,missed_total]
  end
end


desc ""
task :export_cleavagestats => :environment do
  
  require 'fastercsv'

  filename = '101006-1-all-cleavage-stats'

  #path = '/Users/PhilippLange/Documents/science/data/data-analysis/'
  path = '/Volumes/MMPfileserver/lab/Documents/Philipp/topcat_analysis/'
  date = Date::today.to_s
  Dir.chdir(path)
  Dir.mkdir(date) unless  File.exists?(date)
  Dir.chdir(date)

  cls =  [["P16015", "2"], ["", "22"], ["P03953", "26"], ["P19001", "53"], ["Q91WS0", "2"], ["O09165", "29"], ["", "23"], ["P37804", "2"], ["P12787", "38"], ["Q05920", "21"], ["Q05920", "20"], ["Q9ET01", "2"], ["P04117", "17"], ["P19096", "362"], ["P19096", "430"], ["Q16762", "2"], ["P07356", "25"], ["Q8BFR5", "240"], ["Q8QZS1", "30"], ["Q8BMS1", "30"], ["Q8BH95", "117"], ["P58252", "112"], ["P48774", "2"], ["P31786", "2"], ["P30115", "2"], ["P61978", "139"], ["P07724", "445"], ["P49817", "2"], ["Q9CR68", "79"], ["P04117", "14"], ["Q61805", "26"], ["Q7TMF3", "1"], ["P03953", "26"], ["P07724", "25"], ["", "2"], ["P31725", "12"], ["Q3UIU2", "2"], ["", "43"], ["P56480", "48"], ["P07910", "108"], ["Q8VEK3", "234"], ["P29699", "19"], ["O09164", "23"], ["Q60932", "15"], ["O88696", "53"], ["Q00839", "197"], ["P31725", "15"], ["P10649", "2"], ["", "34"], ["", "1"], ["P01791", "1"], ["Q8R1I1", "2"], ["P01027", "671"], ["Q8VEK3", "190"], ["", "2"], ["", "75"], ["", "32"], ["P49945", "169"], ["", "71"], ["Q80W21", "2"], ["Q9CPQ1", "2"], ["P53996", "40"], ["P01873", "249"], ["Q8NC51", "2"], ["O88569", "1"], ["O35955", "40"], ["Q9CQA3", "31"], ["P31725", "4"], ["", "20"], ["Q9WTP6", "2"], ["P84090", "2"], ["Q91Z53", "7"], ["Q8BG05", "1"], ["O35737", "363"], ["P70404", "39"], ["O08709", "2"], ["", "48"], ["P28063", "205"], ["Q91X72", "93"], ["O89086", "28"], ["P07724", "592"], ["Q91X72", "155"], ["Q92945", "100"], ["P10605", "78"], ["Q8BH97", "21"], ["P07724", "473"], ["P07724", "444"], ["Q8QZT1", "31"], ["P07724", "363"], ["Q14498", "139"], ["P20029", "89"], ["Q00839", "729"], ["P56480", "47"], ["P01746", "20"], ["P07724", "155"], ["", "567"], ["O09164", "21"], ["Q9WVK4", "1"], ["", "2"], ["Q8BIJ6", "45"], ["P00558", "2"], ["", "16"], ["P61978", "39"], ["P07724", "443"], ["P62631", "257"], ["P68134", "21"], ["P08249", "163"], ["Q99NB9", "2"], ["", "111"], ["", "236"], ["O35215", "2"], ["P02089", "21"], ["P01027", "25"], ["Q9CYR0", "18"], ["Q9CQQ7", "43"], ["Q5SW19", "2"], ["P07724", "438"], ["Q9Z0J0", "70"], ["P10853", "65"], ["P19157", "2"], ["Q9R0P3", "2"], ["O88844", "329"], ["Q61171", "151"], ["P02089", "17"], ["Q60710", "1"], ["Q8CI94", "2"], ["O08583", "144"], ["O89086", "27"], ["", "17"], ["O08795", "80"], ["", "32"], ["Q9HB40", "36"], ["Q91WQ3", "2"], ["P04406", "4"], ["", "20"], ["Q9Y5R8", "2"], ["", "22"], ["P01887", "21"], ["", "21"], ["Q03265", "44"], ["Q9Y493", "1162"], ["Q9Z0N1", "2"], ["O35639", "20"], ["P08758", "189"], ["P63017", "63"], ["", "82"], ["Q9D211", "2"], ["P02088", "21"], ["Q9ERE7", "30"], ["P01027", "749"], ["", "32"], ["Q8CB59", "452"], ["P08228", "88"], ["Q16740", "57"], ["", "142"], ["Q9D8N0", "368"], ["O35639", "11"], ["", "2"], ["P08249", "179"], ["Q61838", "1366"], ["P08670", "258"], ["Q05816", "2"], ["Q8BG05", "1"], ["P19783", "23"], ["Q9DBG6", "23"], ["O35129", "2"], ["Q9DBJ1", "2"], ["", "29"], ["P08228", "108"], ["P07356", "184"], ["Q91YQ5", "26"], ["P19096", "1257"], ["P29401", "464"], ["P68134", "23"], ["Q9CZY3", "2"], ["P62137", "2"], ["P19253", "2"], ["P26883", "2"], ["P46471", "2"], ["Q9QUH0", "54"], ["P97821", "228"], ["P10605", "79"], ["Q99KJ8", "2"], ["", "90"], ["Q99798", "635"], ["", "395"], ["P68134", "44"], ["Q9D1A2", "2"], ["P83731", "7"], ["", "2"], ["Q61792", "99"], ["Q9Y6R7", "478"], ["Q9CQV8", "2"], ["", "71"], ["O14556", "312"], ["P68134", "91"], ["P02088", "15"], ["P19387", "2"], ["Q01853", "717"], ["", "1"], ["P15954", "17"], ["P21981", "309"], ["Q99JI4", "2"], ["Q9NR45", "2"], ["P68134", "235"], ["", "441"], ["P10126", "412"], ["P61161", "285"], ["A8MW06", "28"], ["O15144", "1"], ["Q86UX7", "499"], ["P63017", "163"], ["", "206"], ["", "31"], ["Q9D2M8", "2"], ["Q9CR51", "2"], ["", "243"], ["P61981", "2"], ["", "462"], ["P07355", "284"], ["", "132"], ["P06745", "109"], ["P63101", "1"], ["P48036", "6"], ["Q9CQV8", "3"], ["Q562R1", "54"], ["P97379", "3"], ["Q9Z2X1", "2"], ["Q9CYR0", "17"], ["P14618", "425"], ["O15428", "2"], ["Q562R1", "149"], ["P35564", "392"], ["P48036", "2"], ["P62736", "303"], ["P60867", "2"], ["", "41"], ["", "2"], ["P13639", "829"], ["P27773", "25"], ["Q9CYG7", "2"], ["P03958", "212"], ["", "63"], ["P08113", "22"], ["P08238", "630"], ["P61513", "73"], ["P10126", "83"], ["P60710", "297"], ["P60709", "15"], ["Q9CZX8", "2"], ["P68134", "20"], ["Q9CWF2", "142"], ["P62259", "178"], ["P49591", "2"], ["P62631", "258"], ["P49962", "2"], ["P54071", "368"], ["Q923D2", "2"], ["P62736", "302"], ["P51410", "157"], ["P68134", "241"], ["O75190", "2"], ["Q8CDN6", "2"], ["P48036", "275"], ["P60709", "148"], ["", "46"], ["Q7Z7H5", "30"], ["P24452", "330"], ["P23528", "23"], ["Q9QZD9", "1"], ["P21107", "2"], ["", "2"], ["P62736", "304"], ["Q9D8E6", "87"], ["P67812", "1"], ["Q91YI0", "2"], ["P97351", "203"], ["P63087", "2"], ["", "157"], ["P17742", "2"], ["", "2"], ["P80314", "2"], ["P63272", "2"], ["P20152", "51"], ["P07901", "52"], ["", "1"], ["Q14677", "1"], ["P68371", "35"], ["P68134", "31"], ["Q9JII6", "84"], ["", "64"], ["Q9DAU1", "38"], ["Q8BJZ4", "23"], ["Q9CWF2", "115"], ["", "170"], ["P50395", "43"], ["O15511", "2"], ["P97379", "2"], ["", "1"], ["P14618", "45"], ["P24452", "8"], ["Q9CR21", "69"], ["", "147"], ["Q62093", "2"], ["Q9CXW4", "2"], ["Q99PT1", "34"], ["P68134", "234"], ["P60709", "199"], ["P08030", "2"], ["P17742", "4"], ["", "41"], ["Q9CZM2", "97"], ["P70195", "44"], ["P68134", "237"], ["O95456", "2"], ["P62259", "1"], ["P67936", "2"], ["Q9D8T7", "2"], ["P47756", "103"], ["Q9R0Q7", "1"], ["P68369", "381"], ["P13639", "828"], ["", "33"], ["Q92945", "132"], ["P80317", "2"], ["P09104", "39"], ["Q15084", "72"], ["Q9R1T2", "2"], ["", "61"], ["Q9WTM5", "2"], ["", "2"], ["P47753", "2"], ["P68134", "236"], ["P47199", "2"], ["", "2"], ["P68254", "1"], ["P20152", "54"], ["O75832", "174"], ["Q9CWF2", "145"], ["P60709", "13"], ["Q9CQ71", "1"], ["Q9D0F3", "33"], ["P02463", "1439"], ["O08586", "2"], ["", "65"], ["Q9CWF2", "110"], ["P60709", "14"], ["", "54"], ["P68371", "53"], ["P58252", "2"], ["Q9EQQ9", "40"], ["P60710", "2"], ["O89023", "195"], ["Q9CWF2", "143"], ["", "2"], ["", "2"], ["P68369", "51"], ["P62937", "77"], ["P10107", "2"], ["Q61792", "186"], ["P52565", "101"], ["P47754", "2"], ["P17182", "310"], ["Q9CWF2", "109"], ["P70349", "2"], ["Q60972", "2"], ["Q99JW2", "2"], ["P68369", "147"], ["P60710", "358"], ["Q9JL62", "2"], ["", "666"], ["Q8JZQ9", "7"], ["P97493", "60"], ["Q01768", "2"], ["Q91YR1", "2"], ["P31230", "2"], ["P68036", "114"], ["P28656", "46"], ["", "107"], ["", "38"], ["Q8BJW6", "2"], ["P02042", "96"], ["Q9D8Y0", "2"], ["", "2"], ["Q9CZM2", "2"], ["O54782", "686"], ["O88342", "2"], ["P34884", "2"], ["P62158", "114"], ["", "364"], ["Q9HB71", "199"], ["Q08209", "2"], ["P07901", "675"], ["Q60973", "2"], ["P20152", "55"], ["P16045", "63"], ["P14069", "43"], ["P08670", "205"], ["Q06830", "53"], ["P08670", "325"], ["", "36"], ["", "32"], ["P48024", "14"], ["P61979", "306"], ["B2RPK0", "17"], ["Q8BGD9", "357"]]  
  FasterCSV.open("#{filename}.csv", "w") do |csv|
    csv << ['ac','substrate name','position','proteases','protease names','relevance','known']  

    cls.each do |cl|
      ac = cl[0]
      start = cl[1].to_i
      range = start..start
      seen = ''
      species = 'Mus musculus'
      @traces = []
      @proteases = []
      @proteasenames = []
        
      unless ac == ""
        puts ac
        p = Protein.ac_is(ac).first
        if p 
          knowncls = p.inverse_cleavages.pos_in(range)
          knowncls.each do |knowncl|          
            if ac+start.to_s+knowncl.protease.ac != seen && p.oss.*.name.include?(species)
              @traces << knowncl.traces.*.phys_relevance
              @proteases << knowncl.protease.ac
              @proteasenames << knowncl.protease.recname
              seen = ac+start.to_s+knowncl.protease.ac
            end
          end
          p.nterms.include?(start) ? known = 'yes': known = 'no'
          
          csv << [ac,p.recname,start,@proteases.join(','),@proteasenames.join(','),@traces.join('|'),known]
        end   
      end
    end
  end
end



desc "report on saved cleavages"
task :cleavagestats => :environment do
  
  require 'fastercsv'

  filename = 'saved-cleavage-stats'

  #path = '/Users/PhilippLange/Documents/science/data/data-analysis/'
  path = '/Volumes/MMPfileserver/lab/Documents/Philipp/topcat_analysis/'
  date = Date::today.to_s
  Dir.chdir(path)
  Dir.mkdir(date) unless  File.exists?(date)
  Dir.chdir(date)

  wantedfts = ['CONFLICT','MOD-RES','MUTAGEN','SITE','VARIANT']

  cls = Cleavage.all

  FasterCSV.open("#{filename}.csv", "w") do |csv|
    csv << ['protease','substrate','position','feature-name','fature-desc']  
     
    cls.each do |c|
      c.targeted_boundaries.each do |f|
        if wantedfts.include?(f.name)
          csv << [c.protease.name,c.substrate.name,c.pos,f.name,f.description]
        end  
      end
    end
  end
  
end


desc "report on saved termini"
task :terministats => :environment do
  
  require 'fastercsv'

  filename = 'termini-stats'

  # path = '/Users/philipp/Documents/science/data/data-analysis/'
  path = '/Volumes/MMPfileserver/lab/Documents/Philipp/topcat_analysis/'
  date = Date::today.to_s
  Dir.chdir(path)
  Dir.mkdir(date) unless  File.exists?(date)
  Dir.chdir(date)

  wantedfts = ['CONFLICT','MOD-RES','MUTAGEN','SITE','VARIANT','PROPEP','TRANSMEM']
  terms = Array.new
  evidences = Evidence.evidencecodes_name_is('inferred from experiment').all
  # evidences = Evidence.lab_like('Overall').all

  FasterCSV.open("#{filename}.csv", "w") do |csv|
    csv << ['#','protein','position','term','modification','type','feature-name','feature-pos','feature-desc','evidence','lab']  
  
  
    evidences.each_with_index do |e,i|
    
    e.nterms.each_with_index do |t,j|
      t.protein.fts.before(t.pos).each do |f|
        if wantedfts.include?(f.name)
        csv << ["#{i}-#{j}",t.protein.recname,t.pos,'N',t.terminusmodification.name,'before',f.name,"#{f.from}-#{f.to}",f.description,e.name,e.lab]
        end  
      end
      
      t.protein.fts.after(t.pos).each do |f|
        if wantedfts.include?(f.name)
        csv << ["#{i}-#{j}",t.protein.recname,t.pos,'N',t.terminusmodification.name,'after',f.name,"#{f.from}-#{f.to}",f.description,e.name,e.lab]
        end  
      end

      t.protein.fts.spanning(t.pos,t.pos).each do |f|
        if wantedfts.include?(f.name)
        csv << ["#{i}-#{j}",t.protein.recname,t.pos,'N',t.terminusmodification.name,'spanning',f.name,"#{f.from}-#{f.to}",f.description,e.name,e.lab]
        end  
      end

      t.protein.fts.matching(t.pos).each do |f|
        if wantedfts.include?(f.name)
        csv << ["#{i}-#{j}",t.protein.recname,t.pos,'N',t.terminusmodification.name,'matching',f.name,"#{f.from}-#{f.to}",f.description,e.name,e.lab]
        end  
      end
      
      #simple shedding check
      
      before = t.protein.fts.before(t.pos).map {|f| f.name}
      spanning = t.protein.fts.spanning(t.pos,t.pos).map {|f| f.name}
      after = t.protein.fts.after(t.pos).map {|f| f.name}
      if before.include?('TRANSMEM') && !spanning.include?('TRANSMEM') && !after.include?('TRANSMEM')
        csv << ["#{i}-#{j}",t.protein.recname,t.pos,'N','','shed','',"",'',e.name]
        end
      

      t.protein.inverse_cleavages.each do |c|
         if (t.pos-2..t.pos+2).include?(c.pos)
        csv << ["#{i}-#{j}",t.protein.recname,t.pos,'','','cleavage',c.protease.recname,c.pos,c.try.cleavagesite.try.short_seq,c.evidences.first.name,c.evidences.first.lab]
         end  
      end
    end
      end
  end
  
end

desc "report on saved termini"
task :terminicounts => :environment do
  
  require 'fastercsv'

  filename = 'termini-counts'

  # path = '/Users/philipp/Documents/science/data/data-analysis/'
  path = '/Volumes/MMPfileserver/lab/Documents/Philipp/topcat_analysis/'
  date = Date::today.to_s
  Dir.chdir(path)
  Dir.mkdir(date) unless  File.exists?(date)
  Dir.chdir(date)
  
  terms = Array.new
  evidencesets = Hash.new
  evidencesets['uniprot'] =  Evidence.name_is('inferred from uniprot').all
  evidencesets['new_phys'] =  Evidence.evidencecodes_name_is('inferred from experiment').*.id

  FasterCSV.open("#{filename}.csv", "w") do |csv|
    csv << ['set','label','count']  
    
    evidencesets.each do |s,es|
    es.each do |e|
      nall =e.nterms.count
      
      ncounts = {'INIT_MET' => 0, 'SIGNAL' => 0, 'PROPEP' => 0}
      e.nterms.each_with_index do |t,i|
        a = t.targeted_boundaries('lost').*.name
        ncounts['INIT_MET']+=1 if a.include?('INIT_MET')
        ncounts['SIGNAL']+=1 if a.include?('SIGNAL')
        ncounts['PROPEP']+=1 if a.include?('PROPEP')
        puts "#{i}/#{nall}" 
      end
      

        puts "all nterms: #{nall}"
      methint = e.nterms.map {|t| t.pos == 1 && t.protein.sequence.first == 'M'}.count(true)
        puts "met intact: #{methint}"
      methintnannot = e.nterms.map {|t| t.pos == 1 && t.protein.sequence.first == 'M' && t.targeted_boundaries.*.name.include?('INIT_MET')}.count(true)
        puts "met intact but removed annotated: #{methintnannot}"
      methrem = e.nterms.map {|t| t.pos == 2 && t.protein.sequence.first == 'M'}.count(true)
        puts "met removed: #{methrem}"  
      annot_meth = ncounts['INIT_MET']
        puts "annotated meth removed: #{annot_meth}"
      signal = ncounts['SIGNAL']
        puts "signal removed: #{signal}"
      prop = ncounts['PROPEP']
        puts "propep removed#{prop}"
      nchain = e.nterms.map {|t| t.targeted_boundaries.*.name.include?('CHAIN')}.count(true)
        puts "chain: #{nchain}"
      ninternal = nall - methrem - signal - prop - nchain
        puts "internal: #{ninternal}"
      ncleavage = e.nterms.map {|t| t.protein.inverse_cleavages.*.pos.include?(t.pos+1)}.count(true)
        puts "potential cleavage: #{ncleavage}" 
      call = e.cterms.count
        puts "all cterms: #{call}"
      cchain = e.cterms.map {|t| t.targeted_boundaries.*.name.include?('CHAIN')}.count(true)
        puts "chain cterms: #{cchain}"
      ccleavage = e.nterms.map {|t| t.protein.inverse_cleavages.*.pos.include?(t.pos)}.count(true)
        puts "potential c-cleavage: #{ccleavage}"
      
      csv << [s,'nterm-all',nall]
      csv << [s,'nterm-meth-intact',methint]
      csv << [s,'nterm-meth-intact-but-removed-annotaed',methintnannot]
      csv << [s,'nterm-meth-removed',methrem]
      csv << [s,'nterm-meth-removed-annotated',annot_meth]
      csv << [s,'nterm-signal',signal]
      csv << [s,'nterm-prop',prop]
      csv << [s,'nterm-chain',nchain]
      csv << [s,'nterm-internal',ninternal]
      csv << [s,'nterm-cleavage',ncleavage]
      csv << [s,'cterm-all',call]
      csv << [s,'cterm-chain',cchain]
      csv << [s,'cterm-cleavage',ccleavage]
      end
    end
  end
end


desc "report on saved termini"
task :terminicounts2 => :environment do
  
  require 'fastercsv'

  filename = 'termini-counts2'

  # path = '/Users/philipp/Documents/science/data/data-analysis/'
  path = '/Volumes/MMPfileserver/lab/Documents/Philipp/topcat_analysis/'
  date = Date::today.to_s
  Dir.chdir(path)
  Dir.mkdir(date) unless  File.exists?(date)
  Dir.chdir(date)
  
  uniprot =  Evidence.name_like('inferred from uniprot').*.id
  new_phys =  Evidence.evidencecodes_name_is('inferred from experiment').*.id

  y new_phys
  
  FasterCSV.open("#{filename}.csv", "w") do |csv|
    csv << ['set','label','count','ref']  
      proteins = Protein.all
    pall = proteins.count
    # evidencesets.each do |s,es|
      @u_nall = Array.new
      @u_nabs = Array.new
      @u_nmetint = Array.new
      @u_nmetrem = Array.new
      @u_nmetremnew = Array.new
      @u_nsigrem = Array.new
      @u_nproint = Array.new
      @u_nprorem = Array.new
      @u_nchain = Array.new
      @u_nchaincleavage = Array.new
      @u_nnew = Array.new
      @u_ncleavage = Array.new
      
      @u_call = Array.new
      @u_cabs = Array.new
      @u_cchain = Array.new
      @u_cnew = Array.new
      @u_ccleavage = Array.new
      @u_cchaincleavage = Array.new
        
      
      
      @n_nall = Array.new
      @n_nabs = Array.new
      @n_nmetint = Array.new
      @n_nmetrem = Array.new
      @n_nmetremnew = Array.new
      @n_nsigrem = Array.new
      @n_nproint = Array.new
      @n_nprorem = Array.new
      @n_nchain = Array.new
      @n_nchaincleavage = Array.new
      @n_nnew = Array.new
      @n_ncleavage = Array.new
      
      @n_call = Array.new
      @n_cabs = Array.new
      @n_cchain = Array.new
      @n_cchaincleavage = Array.new
      @n_cnew = Array.new
      @n_ccleavage = Array.new
              
      proteins.each_with_index do |p,pi|
        
        fts = {'INIT_MET'=>[],'SIGNAL' =>[],'PROPEPFROM' => [],'PROPEPTO' => [],'CHAINFROM' => [],'CHAINTO' => []}
        p.fts.each do |f| 
          case f.name
            when 'INIT_MET'
              fts['INIT_MET'].push(f.from.to_i)
              when 'SIGNAL'
                fts['SIGNAL'].push(f.to.to_i)
              when 'PROPEP'
                fts['PROPEPFROM'].push(f.from.to_i)
                fts['PROPEPTO'].push(f.to.to_i) 
              when 'CHAIN'
                fts['CHAINFROM'].push(f.from.to_i) 
                fts['CHAINTO'].push(f.to.to_i) 
            end
          end
        cleavages = p.inverse_cleavages.*.pos
        
        p.nterms.each do |n|
          id = "#{p.id}-#{n.id}-#{n.pos}"
          pos = n.pos.to_i
          evidences = n.evidences.*.id
          if evidences.map {|x| uniprot.include?(x)}.include?(true)
            @u_nall.push(id)
            if pos == 1
              @u_nabs.push(id)
              @u_nmetint.push(id) if p.sequence.first == 'M'    
            elsif pos == 2   
              @u_nmetrem.push(id) if fts['INIT_MET'].include?(1)
              @u_nmetremnew.push(id) if (p.sequence.first == 'M' && !fts['INIT_MET'].include?(1))
            elsif fts['SIGNAL'].include?(pos-1)
              @u_nsigrem.push(id)
            elsif fts['PROPEPFROM'].include?(pos)
              @u_nproint.push(id) 
            elsif fts['PROPEPTO'].include?(pos-1)
              @u_nprorem.push(id)
            elsif (fts['CHAINFROM'].include?(pos) && cleavages.include?(pos-1))
              @u_nchaincleavage.push(id)
            elsif fts['CHAINFROM'].include?(pos)
              @u_nchain.push(id)
            elsif cleavages.include?(pos-1)
              @u_ncleavage.push(id) 
            else  
              @u_nnew.push(id)
            end
          end
          
          if evidences.map {|x| new_phys.include?(x)}.include?(true)
            @u_nall.push(id)
            if pos == 1
              @n_nabs.push(id)
              @n_nmetint.push(id) if p.sequence.first == 'M'    
            elsif pos == 2   
              @n_nmetrem.push(id) if fts['INIT_MET'].include?(1)
              @n_nmetremnew.push(id) if (p.sequence.first == 'M' && !fts['INIT_MET'].include?(1))
            elsif fts['SIGNAL'].include?(pos-1)
              @n_nsigrem.push(id)
            elsif fts['PROPEPFROM'].include?(pos)
              @n_nproint.push(id) 
            elsif fts['PROPEPTO'].include?(pos-1)
              @n_nprorem.push(id)
            elsif (fts['CHAINFROM'].include?(pos) && cleavages.include?(pos-1))
              @n_nchaincleavage.push(id)
            elsif fts['CHAINFROM'].include?(pos)
              @n_nchain.push(id)
            elsif cleavages.include?(pos-1)
              @n_ncleavage.push(id) 
            else  
              @n_nnew.push(id)
            end
          end
        end
        
        p.cterms.each do |c|
          id = "#{p.id}-#{c.id}-#{c.pos}"
          pos = c.pos.to_i
          evidences = c.evidences.*.id
          if evidences.map {|x| uniprot.include?(x)}.include?(true)
            @u_call.push(id)
            if pos == p.aalen.to_i
              @u_cabs.push(id) 
            elsif (fts['CHAINTO'].include?(pos) && cleavages.include?(pos)) 
              @u_cchaincleavage.push(id)
            elsif fts['CHAINTO'].include?(pos)  
              @u_cchain.push(id)
            elsif cleavages.include?(pos)  
              @u_ccleavage.push(id)
            else
              @u_cnew.push(id)
            end 
          end
          
          if evidences.map {|x| new_phys.include?(x)}.include?(true)  
            @n_call.push(id)
            if pos == p.aalen.to_i
              @n_cabs.push(id) 
            elsif (fts['CHAINTO'].include?(pos) && cleavages.include?(pos)) 
              @n_cchaincleavage.push(id)
            elsif fts['CHAINTO'].include?(pos)  
              @n_cchain.push(id)
            elsif cleavages.include?(pos)  
              @n_ccleavage.push(id)
            else
              @n_cnew.push(id)
            end             
        end
        end
       puts "#{pi}/#{pall}" 
      end  
      
        csv << ['uniprot','nterm-all',@u_nall.uniq.count,'']
        csv << ['uniprot','nterm-1',@u_nabs.uniq.count,'']
        csv << ['uniprot','nterm-met-intact',@u_nmetint.uniq.count,@u_nmetint.uniq.join('|')]
        csv << ['uniprot','nterm-met-removed',@u_nmetrem.uniq.count,@u_nmetrem.uniq.join('|')]
        csv << ['uniprot','nterm-met-removed-new',@u_nmetremnew.uniq.count,@u_nmetremnew.uniq.join('|')]
        csv << ['uniprot','nterm-signal-rem',@u_nsigrem.uniq.count,@u_nsigrem.uniq.join('|')]
        csv << ['uniprot','nterm-pro-int',@u_nproint.uniq.count,@u_nproint.uniq.join('|')]
        csv << ['uniprot','nterm-pro-rem',@u_nprorem.uniq.count,@u_nprorem.uniq.join('|')]
        csv << ['uniprot','nterm-chain',@u_nchain.uniq.count,'']
        csv << ['uniprot','nterm-cleavage',@u_ncleavage.uniq.count,'']
        csv << ['uniprot','nterm-cleavage-chain',@u_nchaincleavage.uniq.count,'']
        csv << ['uniprot','nterm-new',@u_nnew.uniq.count,@u_nnew.uniq.join('|')]
        csv << ['uniprot','cterm-all',@u_call.uniq.count,'']
        csv << ['uniprot','cterm-abs',@u_cabs.uniq.count,'']
        csv << ['uniprot','cterm-cleavage-chain',@u_cchaincleavage.uniq.count,'']
        csv << ['uniprot','cterm-chain',@u_cchain.uniq.count,'']
        csv << ['uniprot','cterm-cleavage',@u_ccleavage.uniq.count,'']    
        csv << ['uniprot','cterm-new',@u_cnew.uniq.count,'']
        
        csv << ['new','nterm-all',@n_nall.uniq.count,'']
        csv << ['new','nterm-1',@n_nabs.uniq.count,'']
        csv << ['new','nterm-met-intact',@n_nmetint.uniq.count,@n_nmetint.uniq.join('|')]
        csv << ['new','nterm-met-removed',@n_nmetrem.uniq.count,@n_nmetrem.uniq.join('|')]
        csv << ['new','nterm-met-removed-new',@n_nmetremnew.uniq.count,@n_nmetremnew.uniq.join('|')]
        csv << ['new','nterm-signal-rem',@n_nsigrem.uniq.count,@n_nsigrem.uniq.join('|')]
        csv << ['new','nterm-pro-int',@n_nproint.uniq.count,@n_nproint.uniq.join('|')]
        csv << ['new','nterm-pro-rem',@n_nprorem.uniq.count,@n_nprorem.uniq.join('|')]
        csv << ['new','nterm-chain',@n_nchain.uniq.count,'']
        csv << ['new','nterm-cleavage',@n_ncleavage.uniq.count,'']
        csv << ['new','nterm-cleavage-chain',@n_nchaincleavage.uniq.count,'']
        csv << ['new','nterm-new',@n_nnew.uniq.count,@n_nnew.uniq.join('|')]
        csv << ['new','cterm-all',@n_call.uniq.count,'']
        csv << ['new','cterm-abs',@n_cabs.uniq.count,'']
        csv << ['new','cterm-cleavage-chain',@n_cchaincleavage.uniq.count,''] 
        csv << ['new','cterm-chain',@n_cchain.uniq.count,'']
        csv << ['new','cterm-cleavage',@n_ccleavage.uniq.count,'']  
        csv << ['new','cterm-new',@n_cnew.uniq.count,'']          
  
  end
end


desc "report on saved termini"
task :terminidistri => :environment do
  
  require 'fastercsv'

  filename = 'termini-distri'

  # path = '/Users/philipp/Documents/science/data/data-analysis/'
  path = '/Volumes/MMPfileserver/lab/Documents/Philipp/topcat_analysis/'
  date = Date::today.to_s
  Dir.chdir(path)
  Dir.mkdir(date) unless  File.exists?(date)
  Dir.chdir(date)
  
  uniprot =  Evidence.name_like('inferred from uniprot').*.id
  new =  Evidence.evidencecodes_name_is('inferred from experiment').*.id
  cleavage = Evidence.evidencecodes_name_is('inferred from cleavage').*.id

  FasterCSV.open("#{filename}.csv", "w") do |csv|
      @u_ntotal = Nterm.evidences_id_in(uniprot).uniq.count+1
      @n_ntotal = Nterm.evidences_id_in(new).uniq.count+1
      @c_ntotal = Nterm.evidences_id_in(cleavage).uniq.count+1
      @u_ctotal = Cterm.evidences_id_in(uniprot).uniq.count+1
      @n_ctotal = Cterm.evidences_id_in(new).uniq.count+1
      @u_nabs = Nterm.evidences_id_in(uniprot).count(:group => 'pos')
      @n_nabs = Nterm.evidences_id_in(new).count(:group => 'pos')
      @c_nabs = Nterm.evidences_id_in(cleavage).count(:group => 'pos')
      @u_cabs = Cterm.evidences_id_in(uniprot).count(:group => 'pos')
      @n_cabs = Cterm.evidences_id_in(new).count(:group => 'pos')
      puts 'abs done'
  
      @u_np = Hash.new
      (0..100).each {|i| @u_np[i] = 0}
      Nterm.evidences_id_in(uniprot).uniq.map { |n| pos = (n.pos/n.protein.aalen*100).round; @u_np[pos] +=1  }
      puts 'u_n_per done'

      @n_np = Hash.new
      (0..100).each {|i| @n_np[i] = 0}
      Nterm.evidences_id_in(new).uniq.map { |n| pos = (n.pos/n.protein.aalen*100).round; @n_np[pos] +=1  }
      puts 'n_n_per done'

      @c_np = Hash.new
      (0..100).each {|i| @c_np[i] = 0}
      Nterm.evidences_id_in(cleavage).uniq.map { |n| pos = (n.pos/n.protein.aalen*100).round; @c_np[pos] +=1 if @c_np[pos] }
      puts 'c_n_per done'

      @u_cp = Hash.new
      (0..100).each {|i| @u_cp[i] = 0}
      Cterm.evidences_id_in(uniprot).uniq.map { |n| pos = (n.pos/n.protein.aalen*100).round; @u_cp[pos] +=1  }
      puts 'u_c_per done'
      
      @n_cp = Hash.new
      (0..100).each {|i| @n_cp[i] = 0}
      Cterm.evidences_id_in(new).uniq.map { |n| pos = (n.pos/n.protein.aalen*100).round; @n_cp[pos] +=1 if  @n_cp[pos] }
      puts 'n_c_per done' 
                        

    csv << ['uniprot nterms-abs-pos',@u_nabs.map {|x,y| x}.join(';')]
    csv << ['uniprot nterms-abs-count',@u_nabs.map {|x,y| y}.join(';')]
    csv << ['uniprot nterms-abs-percent',@u_nabs.map {|x,y| (y/@u_ntotal*100).to_f.round(1)}.join(';')]
    
    csv << ['new nterms-abs-pos',@n_nabs.map {|x,y| x}.join(';')]
    csv << ['new nterms-abs-count',@n_nabs.map {|x,y| y}.join(';')] 
    csv << ['new nterms-abs-percent',@n_nabs.map {|x,y| (y/@n_ntotal*100).to_f.round(1)}.join(';')]
    
    csv << ['cl nterms-abs-pos',@c_nabs.map {|x,y| x}.join(';')]
    csv << ['cl nterms-abs-count',@c_nabs.map {|x,y| y}.join(';')] 
    csv << ['cl nterms-abs-percent',@c_nabs.map {|x,y| (y/@c_ntotal*100).to_f.round(1)}.join(';')]
    
    csv << ['uniprot cterms-abs-pos',@u_cabs.map {|x,y| x}.join(';')]
    csv << ['uniprot cterms-abs-count',@u_cabs.map {|x,y| y}.join(';')]
    csv << ['uniprot cterms-abs-percent',@u_cabs.map {|x,y| (y/@u_ctotal*100).to_f.round(1)}.join(';')]
     
    csv << ['new cterms-abs-pos',@n_cabs.map {|x,y| x}.join(';')]
    csv << ['new cterms-abs-count',@n_cabs.map {|x,y| y}.join(';')]
    csv << ['new cterms-abs-percent',@n_cabs.map {|x,y| (y/@n_ctotal*100).to_f.round(1)}.join(';')]
     
    csv << ['uniprot nterms-rel-pos',@u_np.map {|x,y| x}.join(';')]
    csv << ['uniprot nterms-rel-count',@u_np.map {|x,y| y}.join(';')]
    csv << ['uniprot nterms-rel-percent',@u_np.map {|x,y| (y/@u_ntotal*100).to_f.round(1)}.join(';')]
    
    csv << ['new nterms-rel-pos',@n_np.map {|x,y| x}.join(';')]
    csv << ['new nterms-rel-count',@n_np.map {|x,y| y}.join(';')]
    csv << ['new nterms-rel-percent',@n_np.map {|x,y| (y/@n_ntotal*100).to_f.round(1)}.join(';')]
    
    csv << ['cl nterms-rel-pos',@c_np.map {|x,y| x}.join(';')]
    csv << ['cl nterms-rel-count',@c_np.map {|x,y| y}.join(';')]
    csv << ['cl nterms-rel-percent',@c_np.map {|x,y| (y/@c_ntotal*100).to_f.round(1)}.join(';')]
    
    csv << ['uniprot cterms-rel-pos',@u_cp.map {|x,y| x}.join(';')]
    csv << ['uniprot cterms-rel-count',@u_cp.map {|x,y| y}.join(';')]
    csv << ['uniprot cterms-rel-percent',@u_cp.map {|x,y| (y/@u_ctotal*100).to_f.round(1)}.join(';')]
    
    csv << ['new cterms-rel-pos',@n_cp.map {|x,y| x}.join(';')]
    csv << ['new cterms-rel-count',@n_cp.map {|x,y| y}.join(';')] 
    csv << ['new cterms-rel-percent',@n_cp.map {|x,y| (y/@n_ctotal*100).to_f.round(1)}.join(';')]             
  
  end
end

desc "report modifications"
task :modstats => :environment do
  
  require 'fastercsv'
  oss = {'all' => [1,2,3,4]}
  Os.all.each do |s|
    species = s.common_name
  oss[species] = [s.id]
  end
  
  oss.each_pair do |spec,ids|
    filename = "modstats-#{spec}"

  
  
    # path = '/Users/philipp/Documents/science/data/data-analysis/'
    path = '/Volumes/MMPfileserver/lab/Documents/Philipp/topcat_analysis/'
    date = Date::today.to_s
    Dir.chdir(path)
    Dir.mkdir(date) unless  File.exists?(date)
    Dir.chdir(date)
    sets = Hash.new  
    sets['uniprot'] = Evidence.name_like('inferred from uniprot').*.id
    sets['experimental'] = Evidence.evidencecodes_name_is('inferred from experiment').*.id
    # sets['cleavage'] = Evidence.evidencecodes_name_is('inferred from cleavage').*.id
    # sets['biolrel'] = Evidence.phys_relevance_in(['yes','likely']).*.id
    sets['all'] = Evidence.all.*.id
   
  
    
    FasterCSV.open("#{filename}.csv", "w") do |csv|
        
        @nterms = Hash.new
        @n1terms = Hash.new
        @n2terms = Hash.new
        @n3terms = Hash.new
        Terminusmodification.with_nterms.each do |t|
          puts "nterm - #{t.kw}"
          sets.each_pair do |k,v|
          @nterms.has_key?("#{k}-#{t.kw}") ? @nterms["#{k}-#{t.kw}"] += t.nterms.protein_oss_id_in(ids).evidences_id_in(v).count :  @nterms["#{k}-#{t.kw}"] = t.nterms.protein_oss_id_in(ids).evidences_id_in(v).count 
          @n1terms.has_key?("#{k}-#{t.kw}1") ? @n1terms["#{k}-#{t.kw}1"] += t.nterms.protein_oss_id_in(ids).evidences_id_in(v).map{|n| n if n.pos == 1}.compact.count :  @n1terms["#{k}-#{t.kw}1"] = t.nterms.protein_oss_id_in(ids).evidences_id_in(v).map{|n| n if n.pos == 1}.compact.count 
          @n2terms.has_key?("#{k}-#{t.kw}2") ? @n2terms["#{k}-#{t.kw}2"] += t.nterms.protein_oss_id_in(ids).evidences_id_in(v).map{|n| n if n.pos == 2}.compact.count :  @n2terms["#{k}-#{t.kw}2"] = t.nterms.protein_oss_id_in(ids).evidences_id_in(v).map{|n| n if n.pos == 2}.compact.count   
          @n3terms.has_key?("#{k}-#{t.kw}3") ? @n3terms["#{k}-#{t.kw}3"] += t.nterms.protein_oss_id_in(ids).evidences_id_in(v).map{|n| n if n.pos > 2}.compact.count :  @n3terms["#{k}-#{t.kw}3"] = t.nterms.protein_oss_id_in(ids).evidences_id_in(v).map{|n| n if n.pos>2}.compact.count  
          end
        end   
  
        @cterms = Hash.new
        Terminusmodification.with_cterms.each do |t|
          puts "cterm - #{t.kw}"
          sets.each_pair do |k,v|
          @cterms.has_key?("#{k}-#{t.kw}") ? @cterms["#{k}-#{t.kw}"] += t.cterms.protein_oss_id_in(ids).evidences_id_in(v).count :  @cterms["#{k}-#{t.kw}"] = t.cterms.protein_oss_id_in(ids).evidences_id_in(v).count  
          end
        end   
                      
  
      csv << ['term','kw','count']
      @nterms.each_pair do |kw,count|
        csv << ['nterm',kw,count]
      end 
      @n1terms.each_pair do |kw,count|
        csv << ['nterm',kw,count]
      end
      @n2terms.each_pair do |kw,count|
        csv << ['nterm',kw,count]
      end
      @n3terms.each_pair do |kw,count|
        csv << ['nterm',kw,count]
      end
      @cterms.each_pair do |kw,count|
        csv << ['cterm',kw,count]
      end             
    
    end
  end
end


desc "report amino acids at terminus"
task :termas => :environment do
  
  require 'fastercsv'

  
 
  filename = "termas-2"

  # path = '/Users/philipp/Documents/science/data/data-analysis/'
  path = '/Volumes/MMPfileserver/lab/Documents/Philipp/topfind_analysis/'
  date = Date::today.to_s
  Dir.chdir(path)
  Dir.mkdir(date) unless  File.exists?(date)
  Dir.chdir(date)
  
  sets = Hash.new
  nascount = Hash.new
  n1ascount = Hash.new
  n2ascount = Hash.new
  n3ascount = Hash.new
  nacetascount = Hash.new
  n1acetascount = Hash.new
  n2acetascount = Hash.new
  n3acetascount = Hash.new
  npyroascount = Hash.new
  cascount = Hash.new
      nlogo = {}
      n1logo = {}
      n2logo = {}
      n3logo = {}
      nacetlogo = {}
      n1acetlogo = {}
      n2acetlogo = {}
      n3acetlogo = {}
      npyrologo = {}
      n1pyrologo = {}
      n2pyrologo = {}
      clogo = {}   
  
  
  # sets['uniprot'] = Evidence.name_like('inferred from uniprot').*.id.uniq
  sets['experimental'] = Evidence.evidencecodes_name_is('inferred from experiment').*.id.uniq
  # sets['cleavage'] = Evidence.evidencecodes_name_is('inferred from cleavage').*.id.uniq
  # sets['biolrel'] = Evidence.phys_relevance_in(['yes','likely']).*.id.uniq
  # sets['all'] = Evidence.all.*.id.uniq

  as = ['A','C','D','E','F','G','H','I','K','L','M','N','P','Q','R','S','T','V','W','Y']
  
  sets.each_pair do |k,v| 
      nterms = Nterm.evidences_id_in(v).uniq
      cterms = Cterm.evidences_id_in(v).uniq 
      
       
    Os.all.each do |species|
      puts "#{species.name}\n"
      nas = []
      n1as = []
      n2as = []
      n3as = []
      nacetas = []
      n1acetas = []
      n2acetas = []
      n3acetas = []
      npyroas = []
      cas = []  
      nlogo["#{species.common_name}-#{k}"] = []
      n1logo["#{species.common_name}-#{k}"] = []
      n2logo["#{species.common_name}-#{k}"] = []
      n3logo["#{species.common_name}-#{k}"] = []
      nacetlogo["#{species.common_name}-#{k}"] = []
      n1acetlogo["#{species.common_name}-#{k}"] = []
      n2acetlogo["#{species.common_name}-#{k}"] = []
      n3acetlogo["#{species.common_name}-#{k}"] = []
      npyrologo["#{species.common_name}-#{k}"] = []
      n1pyrologo["#{species.common_name}-#{k}"] = []
      n2pyrologo["#{species.common_name}-#{k}"] = []
      clogo["#{species.common_name}-#{k}"] = []  
        
      nterms.each do |x|
      print "." 
        if x.protein.species == species.name
          nas <<  x.protein.sequence.split('')[x.pos-1]
          n1as <<  x.protein.sequence.split('')[x.pos-1] if x.pos == 1
          n2as <<  x.protein.sequence.split('')[x.pos-1] if x.pos == 2 && x.protein.sequence.first == 'M'
          n3as <<  x.protein.sequence.split('')[x.pos-1] if x.pos > 2 
          nlogo["#{species.common_name}-#{k}"] << x.protein.sequence.slice(x.pos-1,10)
          n1logo["#{species.common_name}-#{k}"] << x.protein.sequence.slice(x.pos-1,10) if x.pos == 1 
          n2logo["#{species.common_name}-#{k}"] << x.protein.sequence.slice(x.pos-1,10) if x.pos == 2 
          n3logo["#{species.common_name}-#{k}"] << x.protein.sequence.slice(x.pos-1,10) if x.pos > 2 
          if x.terminusmodification && x.terminusmodification.kw && x.terminusmodification.kw.name == 'Acetylation'
            nacetas <<  x.protein.sequence.split('')[x.pos-1]
            n1acetas <<  x.protein.sequence.split('')[x.pos-1] if x.pos == 1
            n2acetas <<  x.protein.sequence.split('')[x.pos-1] if x.pos == 2
            n3acetas <<  x.protein.sequence.split('')[x.pos-1] if x.pos > 2
            
              nacetlogo["#{species.common_name}-#{k}"] << x.protein.sequence.slice(x.pos-1,10) 
              n1acetlogo["#{species.common_name}-#{k}"] << x.protein.sequence.slice(x.pos-1,10) if x.pos == 1 
              n2acetlogo["#{species.common_name}-#{k}"] << x.protein.sequence.slice(x.pos-1,10) if x.pos == 2 
              n3acetlogo["#{species.common_name}-#{k}"] << x.protein.sequence.slice(x.pos-1,10) if x.pos > 2
          end
          if x.terminusmodification && x.terminusmodification.kw && x.terminusmodification.kw.name == 'Pyrrolidone carboxylic acid'
            npyroas <<  x.protein.sequence.split('')[x.pos-1]
              npyrologo["#{species.common_name}-#{k}"] << x.protein.sequence.slice(x.pos-1,10) 
              n1pyrologo["#{species.common_name}-#{k}"] << x.protein.sequence.slice(x.pos-1,10) if x.pos == 1
              n2pyrologo["#{species.common_name}-#{k}"] << x.protein.sequence.slice(x.pos-1,10) if x.pos > 1 
          end
        end 
      end    
      cterms.each do |x|
      print ";" 
        if x.protein.species == species.name
                      cas <<  x.protein.sequence.split('')[x.pos-1]
                      pos = x.pos-1
                      pos >= 10 ? prepos = pos-10 : prepos = 0
                      clogo["#{species.common_name}-#{k}"] << x.protein.sequence.slice(prepos,pos-prepos) 
        end 
      end

      nascount["#{species.common_name}-#{k}"] = as.map {|a| nas.count(a)}
      n1ascount["#{species.common_name}-#{k}"] = as.map {|a| n1as.count(a)}
      n2ascount["#{species.common_name}-#{k}"] = as.map {|a| n2as.count(a)}
      n3ascount["#{species.common_name}-#{k}"] = as.map {|a| n3as.count(a)}
      nacetascount["#{species.common_name}-#{k}"] = as.map {|a| nacetas.count(a)}
      n1acetascount["#{species.common_name}-#{k}"] = as.map {|a| n1acetas.count(a)}
      n2acetascount["#{species.common_name}-#{k}"] = as.map {|a| n2acetas.count(a)}
      n3acetascount["#{species.common_name}-#{k}"] = as.map {|a| n3acetas.count(a)}
      npyroascount["#{species.common_name}-#{k}"] = as.map {|a| npyroas.count(a)}
      cascount["#{species.common_name}-#{k}"] = as.map {|a| cas.count(a)}
    end       
 end     

  FasterCSV.open("#{filename}.csv", "w") do |csv|
    csv << as.unshift('')
    nascount.each_pair do |k,v|
      csv << v.unshift("#{k}-nterm")
      end
    n1ascount.each_pair do |k,v|
      csv << v.unshift("#{k}-nterm-1")
      end
    n2ascount.each_pair do |k,v|
      csv << v.unshift("#{k}-nterm-2")
      end
    n3ascount.each_pair do |k,v|
      csv << v.unshift("#{k}-nterm>=3")
      end
    nacetascount.each_pair do |k,v|
      csv << v.unshift("#{k}-acet-nterm")
      end
    n1acetascount.each_pair do |k,v|
      csv << v.unshift("#{k}-acet-nterm-1")
      end
    n2acetascount.each_pair do |k,v|
      csv << v.unshift("#{k}-acet-nterm-2")
      end
    n3acetascount.each_pair do |k,v|
      csv << v.unshift("#{k}-acet-nterm>=3")
      end
    npyroascount.each_pair do |k,v|
      csv << v.unshift("#{k}-pyro-nterm")
      end
    cascount.each_pair do |k,v|
      csv << v.unshift("#{k}-cterm")
      end          
  end
  
  FasterCSV.open("#{filename}-logos.csv", "w") do |csv|
    nlogo.each_pair do |k,v|
      csv << v.uniq.unshift("#{k}-nterm")
      end
    n1logo.each_pair do |k,v|
      csv << v.uniq.unshift("#{k}-nterm-1")
      end
    n2logo.each_pair do |k,v|
      csv << v.uniq.unshift("#{k}-nterm-2")
      end
    n3logo.each_pair do |k,v|
      csv << v.uniq.unshift("#{k}-nterm>=3")
      end
    nacetlogo.each_pair do |k,v|
      csv << v.uniq.unshift("#{k}-acet-nterm")
      end
    n1acetlogo.each_pair do |k,v|
      csv << v.uniq.unshift("#{k}-acet-nterm-1")
      end
    n2acetlogo.each_pair do |k,v|
      csv << v.uniq.unshift("#{k}-acet-nterm-2")
      end
    n3acetlogo.each_pair do |k,v|
      csv << v.uniq.unshift("#{k}-acet-nterm>=3")
      end
    npyrologo.each_pair do |k,v|
      csv << v.uniq.unshift("#{k}-pyro-nterm")
      end
    n1pyrologo.each_pair do |k,v|
      csv << v.uniq.unshift("#{k}-pyro-nterm-1")
      end 
    n2pyrologo.each_pair do |k,v|
      csv << v.uniq.unshift("#{k}-pyro-nterm>=2")
      end   
    clogo.each_pair do |k,v|
      csv << v.uniq.unshift("#{k}-cterm")
      end              
  end  
end

desc "report amino acids at terminus depending on subcell location (in progress)"
task :gotermas => :environment do
  
  require 'fastercsv'

  
 
  filename = "go-termas3"

  # path = '/Users/philipp/Documents/science/data/data-analysis/'
  path = '/Volumes/MMPfileserver/lab/Documents/Philipp/topfind_analysis/'
  date = Date::today.to_s
  Dir.chdir(path)
  Dir.mkdir(date) unless  File.exists?(date)
  Dir.chdir(date)
  
  sets = Hash.new
  nascount = Hash.new
  n1ascount = Hash.new
  n2ascount = Hash.new
  n3ascount = Hash.new
  n1iascount = Hash.new
  n2iascount = Hash.new
  n3iascount = Hash.new
  n1eascount = Hash.new
  n2eascount = Hash.new
  n3eascount = Hash.new
  # nacetascount = Hash.new
  # n1acetascount = Hash.new
  # n2acetascount = Hash.new
  # n3acetascount = Hash.new
  # npyroascount = Hash.new
  
  
  
  # sets['uniprot'] = Evidence.name_like('inferred from uniprot').*.id.uniq
  sets['experimental'] = Evidence.evidencecodes_name_is('inferred from experiment').*.id.uniq
  # sets['cleavage'] = Evidence.evidencecodes_name_is('inferred from cleavage').*.id.uniq
  # sets['biolrel'] = Evidence.phys_relevance_in(['yes','likely']).*.id.uniq
  # sets['all'] = Evidence.all.*.id.uniq

  as = ['A','C','D','E','F','G','H','I','K','L','M','N','P','Q','R','S','T','V','W','Y']
  
  sets.each_pair do |k,v| 
      nterms = Nterm.evidences_id_in(v).uniq
      cterms = Cterm.evidences_id_in(v).uniq 
      
       
    Species.all.each do |species|
      puts "#{species.name}\n"
      nas = []
      n1as = []
      n2as = []
      n3as = []
      n1ias = []
      n2ias = []
      n3ias = []
      n1eas = []
      n2eas = []
      n3eas = []
      # nacetas = []
      # n1acetas = []
      # n2acetas = []
      # n3acetas = []
      # npyroas = []
      # cas = []  
      # nlogo["#{species.common_name}-#{k}"] = []
      # n1logo["#{species.common_name}-#{k}"] = []
      # n2logo["#{species.common_name}-#{k}"] = []
      # n3logo["#{species.common_name}-#{k}"] = []
      # nacetlogo["#{species.common_name}-#{k}"] = []
      # n1acetlogo["#{species.common_name}-#{k}"] = []
      # n2acetlogo["#{species.common_name}-#{k}"] = []
      # n3acetlogo["#{species.common_name}-#{k}"] = []
      # npyrologo["#{species.common_name}-#{k}"] = []
      # n1pyrologo["#{species.common_name}-#{k}"] = []
      # n2pyrologo["#{species.common_name}-#{k}"] = []
      # clogo["#{species.common_name}-#{k}"] = []  
#         
      nterms.each do |x|
      print "." 
        if x.protein.species.name == species.name
          nas <<  x.protein.sequence.split('')[x.pos-1]
          n1as <<  x.protein.sequence.split('')[x.pos-1] if x.pos == 1
          n2as <<  x.protein.sequence.split('')[x.pos-1] if x.pos == 2 && x.protein.sequence.first == 'M'
          n3as <<  x.protein.sequence.split('')[x.pos-1] if x.pos > 2 
          
          goterm = x.protein.drs.db_name_is('GO').all
          goterm = goterm.map { |t| Go.acc_is(t.protein_name).first}.flatten.uniq.compact if goterm.present?
          parents = []
          parents = goterm.map {|t| t.inverse_gopaths.map {|p| Go.find(p.term1_id).name} if t.present?}.flatten.uniq.compact if goterm.present?
          if parents.map {|t| t.include?('intracellular')}.flatten.include?(true)
            puts 'i'
            n1ias <<  x.protein.sequence.split('')[x.pos-1] if x.pos == 1
            n2ias <<  x.protein.sequence.split('')[x.pos-1] if x.pos == 2 && x.protein.sequence.first == 'M'
            n3ias <<  x.protein.sequence.split('')[x.pos-1] if x.pos > 2 
          elsif parents.map {|t| t.include?('extracellular')}.flatten.include?(true)
            puts 'e'
            n1eas <<  x.protein.sequence.split('')[x.pos-1] if x.pos == 1
            n2eas <<  x.protein.sequence.split('')[x.pos-1] if x.pos == 2 && x.protein.sequence.first == 'M'
            n3eas <<  x.protein.sequence.split('')[x.pos-1] if x.pos > 2
          else
            puts parents.join('|')
          end   
          # nlogo["#{species.common_name}-#{k}"] << x.protein.sequence.slice(x.pos-1,10)
          # n1logo["#{species.common_name}-#{k}"] << x.protein.sequence.slice(x.pos-1,10) if x.pos == 1 
          # n2logo["#{species.common_name}-#{k}"] << x.protein.sequence.slice(x.pos-1,10) if x.pos == 2 
          # n3logo["#{species.common_name}-#{k}"] << x.protein.sequence.slice(x.pos-1,10) if x.pos > 2 
          # if x.terminusmodification && x.terminusmodification.kw && x.terminusmodification.kw.name == 'Acetylation'
            # nacetas <<  x.protein.sequence.split('')[x.pos-1]
            # n1acetas <<  x.protein.sequence.split('')[x.pos-1] if x.pos == 1
            # n2acetas <<  x.protein.sequence.split('')[x.pos-1] if x.pos == 2
            # n3acetas <<  x.protein.sequence.split('')[x.pos-1] if x.pos > 2
#             
              # nacetlogo["#{species.common_name}-#{k}"] << x.protein.sequence.slice(x.pos-1,10) 
              # n1acetlogo["#{species.common_name}-#{k}"] << x.protein.sequence.slice(x.pos-1,10) if x.pos == 1 
              # n2acetlogo["#{species.common_name}-#{k}"] << x.protein.sequence.slice(x.pos-1,10) if x.pos == 2 
              # n3acetlogo["#{species.common_name}-#{k}"] << x.protein.sequence.slice(x.pos-1,10) if x.pos > 2
          # end
          # if x.terminusmodification && x.terminusmodification.kw && x.terminusmodification.kw.name == 'Pyrrolidone carboxylic acid'
            # npyroas <<  x.protein.sequence.split('')[x.pos-1]
              # npyrologo["#{species.common_name}-#{k}"] << x.protein.sequence.slice(x.pos-1,10) 
              # n1pyrologo["#{species.common_name}-#{k}"] << x.protein.sequence.slice(x.pos-1,10) if x.pos == 1
              # n2pyrologo["#{species.common_name}-#{k}"] << x.protein.sequence.slice(x.pos-1,10) if x.pos > 1 
          # end
        end 
      end    
      # cterms.each do |x|
      # print ";" 
        # if x.protein.species == species.name
                      # cas <<  x.protein.sequence.split('')[x.pos-1]
                      # pos = x.pos-1
                      # pos >= 10 ? prepos = pos-10 : prepos = 0
                      # clogo["#{species.common_name}-#{k}"] << x.protein.sequence.slice(prepos,pos-prepos) 
        # end 
      # end
# 
      nascount["#{species.common_name}-#{k}"] = as.map {|a| nas.count(a)}
      n1ascount["#{species.common_name}-#{k}"] = as.map {|a| n1as.count(a)}
      n2ascount["#{species.common_name}-#{k}"] = as.map {|a| n2as.count(a)}
      n3ascount["#{species.common_name}-#{k}"] = as.map {|a| n3as.count(a)}
      
      n1iascount["#{species.common_name}-#{k}"] = as.map {|a| n1ias.count(a)}
      n2iascount["#{species.common_name}-#{k}"] = as.map {|a| n2ias.count(a)}
      n3iascount["#{species.common_name}-#{k}"] = as.map {|a| n3ias.count(a)}
      
      n1eascount["#{species.common_name}-#{k}"] = as.map {|a| n1eas.count(a)}
      n2eascount["#{species.common_name}-#{k}"] = as.map {|a| n2eas.count(a)}
      n3eascount["#{species.common_name}-#{k}"] = as.map {|a| n3eas.count(a)}
      # nacetascount["#{species.common_name}-#{k}"] = as.map {|a| nacetas.count(a)}
      # n1acetascount["#{species.common_name}-#{k}"] = as.map {|a| n1acetas.count(a)}
      # n2acetascount["#{species.common_name}-#{k}"] = as.map {|a| n2acetas.count(a)}
      # n3acetascount["#{species.common_name}-#{k}"] = as.map {|a| n3acetas.count(a)}
      # npyroascount["#{species.common_name}-#{k}"] = as.map {|a| npyroas.count(a)}
      # cascount["#{species.common_name}-#{k}"] = as.map {|a| cas.count(a)}
    end       
 end     

  FasterCSV.open("#{filename}.csv", "w") do |csv|
    csv << as.unshift('')
    nascount.each_pair do |k,v|
      csv << v.unshift("#{k}-nterm")
      end
    n1ascount.each_pair do |k,v|
      csv << v.unshift("#{k}-nterm-1")
      end
    n2ascount.each_pair do |k,v|
      csv << v.unshift("#{k}-nterm-2")
      end
    n3ascount.each_pair do |k,v|
      csv << v.unshift("#{k}-nterm>=3")
      end
    n1iascount.each_pair do |k,v|
      csv << v.unshift("#{k}-nterm-1-intra")
      end
    n2iascount.each_pair do |k,v|
      csv << v.unshift("#{k}-nterm-2-intra")
      end
    n3iascount.each_pair do |k,v|
      csv << v.unshift("#{k}-nterm>=3-intra")
      end
    n1eascount.each_pair do |k,v|
      csv << v.unshift("#{k}-nterm-1-ex")
      end
    n2eascount.each_pair do |k,v|
      csv << v.unshift("#{k}-nterm-2-ex")
      end
    n3eascount.each_pair do |k,v|
      csv << v.unshift("#{k}-nterm>=3-ex")
      end
    # nacetascount.each_pair do |k,v|
      # csv << v.unshift("#{k}-acet-nterm")
      # end
    # n1acetascount.each_pair do |k,v|
      # csv << v.unshift("#{k}-acet-nterm-1")
      # end
    # n2acetascount.each_pair do |k,v|
      # csv << v.unshift("#{k}-acet-nterm-2")
      # end
    # n3acetascount.each_pair do |k,v|
      # csv << v.unshift("#{k}-acet-nterm>=3")
      # end
    # npyroascount.each_pair do |k,v|
      # csv << v.unshift("#{k}-pyro-nterm")
      # end
    # cascount.each_pair do |k,v|
      # csv << v.unshift("#{k}-cterm")
      # end          
  end
  
  # FasterCSV.open("#{filename}-logos.csv", "w") do |csv|
    # nlogo.each_pair do |k,v|
      # csv << v.uniq.unshift("#{k}-nterm")
      # end
    # n1logo.each_pair do |k,v|
      # csv << v.uniq.unshift("#{k}-nterm-1")
      # end
    # n2logo.each_pair do |k,v|
      # csv << v.uniq.unshift("#{k}-nterm-2")
      # end
    # n3logo.each_pair do |k,v|
      # csv << v.uniq.unshift("#{k}-nterm>=3")
      # end
    # nacetlogo.each_pair do |k,v|
      # csv << v.uniq.unshift("#{k}-acet-nterm")
      # end
    # n1acetlogo.each_pair do |k,v|
      # csv << v.uniq.unshift("#{k}-acet-nterm-1")
      # end
    # n2acetlogo.each_pair do |k,v|
      # csv << v.uniq.unshift("#{k}-acet-nterm-2")
      # end
    # n3acetlogo.each_pair do |k,v|
      # csv << v.uniq.unshift("#{k}-acet-nterm>=3")
      # end
    # npyrologo.each_pair do |k,v|
      # csv << v.uniq.unshift("#{k}-pyro-nterm")
      # end
    # n1pyrologo.each_pair do |k,v|
      # csv << v.uniq.unshift("#{k}-pyro-nterm-1")
      # end 
    # n2pyrologo.each_pair do |k,v|
      # csv << v.uniq.unshift("#{k}-pyro-nterm>=2")
      # end   
    # clogo.each_pair do |k,v|
      # csv << v.uniq.unshift("#{k}-cterm")
      # end              
  # end  
end



desc "cleavage inferred termini for supp table"
task :supptable => :environment do
  
  require 'fastercsv'

  filename = 'supplemantary_table-1'
  
  # path = '/Users/philipp/Documents/science/data/data-analysis/'
  path = '/Volumes/MMPfileserver/lab/Documents/Philipp/topcat_analysis/'
  date = Date::today.to_s
  Dir.chdir(path)
  Dir.mkdir(date) unless  File.exists?(date)
  Dir.chdir(date)  
  nterms = Nterm.evidences_evidencecodes_name_is('inferred from cleavage').uniq
  cterms = Cterm.evidences_evidencecodes_name_is('inferred from cleavage').uniq 
  
  FasterCSV.open("#{filename}.csv", "w") do |csv|
    
    csv << ['Protein (UniProt Acc)','Name','Species','Type','Position','Protease (UniProtAcc)']
    count = 0
    nterms.each do |n|
      next if n.pos == 1 || n.pos == 2
      count +=1
      proteases = []
      n.evidences.each do |e|
        cleavage = Cleavage.find(e.name.split('-')[1]) if e.name.match(/(Inferred from cleavage-).*/)
          proteases << cleavage.protease.ac if cleavage.present?
      end
      csv << [n.protein.ac,n.protein.recname,n.protein.oss.first.name,'N-terminus',n.pos,proteases.join('|')]
    end
    puts "#{count} Nterms"
    count = 0
    cterms.each do |c|
      next if c.pos == c.protein.sequence.length || c.pos <= 10
      proteases = []
      count +=1
      c.evidences.each do |e|
        cleavage = Cleavage.find(e.name.split('-')[1]) if e.name.match(/(Inferred from cleavage-).*/)
          proteases << cleavage.protease.ac if cleavage.present?
      end
      csv << [c.protein.ac,c.protein.recname,c.protein.oss.first.name,'C-terminus',c.pos,proteases.join('|')]
    end
    puts "#{count} Cterms"    

  end
end
