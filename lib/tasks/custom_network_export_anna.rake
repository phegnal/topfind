desc "export cleavages and inhibitions to csv for cytoscape"
task :export_cleavage_network_anna, [:filename] => :environment do |t, args|
  
  require 'fastercsv'

  file = 'protein'

  path = '/Volumes/MMPfileserver/lab/Documents/Philipp/data/analysis/'
  date = Date::today.to_s
  Dir.chdir(path)
  Dir.mkdir(date) unless  File.exists?(date)
  Dir.chdir(date)




  terms = {}
  termnodes = {}
  termids = []
  FasterCSV.foreach(args[:filename],{:col_sep => ';'}) do |l| 
    entry = l
    termids << entry[0]
    termnodes["#{entry[0]}-#{entry[1]}"] = {:ac => entry[0], :pos => entry[1], :name => "#{entry[2]}@#{entry[1]}", :quant1 => entry[3], :quant2 => entry[4], :quant3 => entry[5]}
  end
  termids.uniq!

  nodeproperties = {}
  network = []


  # ntermids = ["Q8R081", "Q3UMT7", nil, "P56480", "Q6S9I0", "Q7M084", "Q91X72", "Q99N96", "Q9CUL8", "Q8BIJ6", "Q8BGD9", "Q922K6", "P10922", "P10126", "O08553", "P26350", "Q3U8X6", "Q8CAQ5", "Q3UA54", "Q9D0J8", "Q66JR8", "Q9CWJ9", "P60710", "P62737", "P63268", "Q3UCF8", "P08228", "Q80UG5", "A2A6U3", "Q3UZ39", "Q921F2", "O88844", "Q0QER9", "Q8BFZ3", "P57776", "Q91VK2", "D3YZT9", "D3Z7N2", "Q8CI51", "Q8CB59", "Q9ET01", "O88569", "B7ZP22", "Q64520", "Q564G0", "Q9CXW3", "P35505", "D3Z2R9", "P04117", "P68372", "Q9CVR0", "P62264", "Q58E70", "P49312", "Q9CQI6", "A1E281", "Q6PHZ2", "O70459", "Q3V1X9", "Q8C8X9", "Q61074", "P01029", "Q9EQQ9", "Q54AH9", "P02088", "Q923T9", "Q6ZWS7", "P52196", "P13439", "Q61205", "P01942", "P14069", "P51174", "Q02053", "Q61792", "A2A6H2", "A2A6H0", "Q9CQV8", "P68510", "P63101", "A2A5N2", "P07901", "P03987", "Q6PJA7", "Q505N9", "Q6PJB2", "Q6PF95", "Q66K04", "Q6KAM2", "P01863", "P01865", "Q5R3X4", "P02089", "P62754", "A2AJK6", "P11499", "Q811H6", "Q80YC2", "P58771", "Q6IRU2", "Q61233", "P47757", "A2AMW0", "A2AMV7", "P97856", "P31786", "P83882", "P07356", "Q61526", "Q9WTP6", "Q69ZN8", "Q6PDJ2", "O35887", "P54071", "P53810", "Q3TGI6", "Q3TIQ3", "P01887", "P17182", "Q6PHC1", "Q5I2A0", "P07759", "Q03734", "Q62259", "Q5EBP8", "P35980", "Q0QEW9", "Q6P1B1", "Q3UE92", "Q8VDD5", "Q9R0Q7", "P54227", "Q9CQJ6", "P16858", "Q64467", "Q3TUZ9", "D3YU05", "D3YYI5", "D3Z0Z9", "Q3V2I5", "D3Z1B7", "P84089", "P07091", "Q3U0V1", "P40142", "Q9CZX8", "D3YUG3", "Q5M9P3", "D3Z5R8", "P10107", "Q9QUR7", "Q99KQ4", "P19096", "Q9CY58", "P06151", "D3YZQ9", "B0V2N5", "Q99KH3", "Q8BFQ4", "Q8C3L3", "P60867", "P61255", "P53811", "P08074", "P35700", "Q9QYJ3", "P63017", "Q3UXU1", "P50516", "P07724", "Q99PT1", "P17665", "Q8BH61", "P06728", "Q9EQI5", "P14131", "Q641N3", "Q5CZY9", "P27784", "Q61598", "Q3UC72", "Q3UPA3", "Q60605", "P08030", "Q9CQQ7", "Q7TMM9", "Q9DCR1", "Q3U9U3", "Q9CUN8", "Q6ZWV3", "P08113", "Q91WP0", "P26443", "Q3TSQ7", "Q9JJI8", "Q05816", "O08529", "P42567", "A2A8Z5", "P12787", "Q8BH64", "Q8CGP5", "A0AUV1", "P31266", "Q3UM17", "Q3U6F1", "Q9D1Q6", "P27773", "Q99M87", "Q9D8N0", "Q8R1N8", "Q99M00", "Q8C4G4", "Q920A5", "Q0VGB7", "A4QMV1", "Q9DBP5", "Q60972", "Q60973", "Q3UX53", "A2AFJ1", "P34884", "Q99JI4", "P17751", "Q9WUU7", "Q922A0", "P08249", "Q9CZM2", "P31725", "Q9DBT1", "Q8C878", "Q66JT6", "Q922R8", "Q3THH1", "A2AKG8", "A2AKL9", "Q80T90", "B2RXT5", "Q05D44", "Q99020", "Q3TMZ8", "P67984", "P50543", "P40124", "Q00623", "O09042", "Q58EV2", "Q8C5Q6", "Q569Z6", "Q3U503", "Q91VL2", "Q9Z247", "Q62233", "O08795", "Q6IFZ6", "A2AN08", "Q8BWR4", "Q4VA61", "Q91ZY7", "Q3V3B0", "Q8CHB2", "P61979", "B2M1R6", "P30416", "Q8CBS1", "P20029", "Q9CQF3", "P14211", "Q8C2R2", "P63242", "Q8C7R4", "D3Z061", "O89017", "P20065", "Q6ZWX2", "Q3UD30", "O55125", "Q5SVG6", "Q3UGS1", "Q9Z2L5", "Q8JZZ7", "Q99NB9", "Q3UIB4", "P26883", "O89086", "P32261", "P19783", "Q8VEE4", "Q5SWN2", "P10639", "Q3TUD6", "Q8CCY5", "P80314", "D3Z2Q7", "P68254", "P34022", "P48024", "P46935", "Q61656", "Q5U222", "Q9CSD9", "Q3V0Z8", "Q8K558", "O70310", "Q8BP92", "Q8BP39", "Q6ZQ18", "P62274", "Q61696", "P16627", "Q9QZD9", "Q9QWK4", "Q9JII6", "P68037", "Q9QUN8", "P16045", "P68369", "O89052", "Q9DBG6", "Q61833", "Q3U505", "O08677", "D3Z2B2", "P59325", "Q05CH7", "Q3TKY2", "P13020", "Q6PAC1", "P35564", "Q03311", "O09159", "Q3TB95", "P06745", "P51410", "Q9CR68", "Q99P72", "Q78NS1", "Q8BH78", "Q8BHF5", "Q8K3G7", "P20152", "Q3UD36", "Q8R1V4", "Q99KK7", "P84078", "P17742", "Q9CZK9", "Q61171", "Q61207", "O35479", "P12970", "Q80UT7", "Q08535", "Q8BH97", "P18760", "P47934", "A2AWE5", "Q61081", "Q91WA6", "Q6P8I4", "P63038", "Q8BP67", "P26041", "P97372", "Q99LN3", "Q99JJ3", "Q3UFT0", "Q811J9", "Q7TQJ6", "P48678", "Q3U733", "P16015", "Q9Z2I8", "C6EQH3", "P05064", "A6ZI44", "A6ZI46", "Q6ZWY8", "P21550", "Q9CY27", "Q4VWZ5", "Q8BH95", "Q62009", "Q923D2", "Q01730", "O88342", "Q80ZI9", "O35099", "Q8CC79", "Q14AY4", "O54951", "P52480", "Q9CWS5", "Q9CZ52", "P27048", "Q6ZWU9", "P35486", "P09411", "Q9WVP9", "Q61925", "P48036", "Q6PFZ1", "Q6P5F9", "Q9Z0S1", "Q3UBR0", "Q504P4", "Q8C1B7", "Q3TRM8", "Q9Z0N1", "Q9CPZ8", "Q60604", "Q69Z71", "P70202", "Q3UFF7", "A1L3T7", "P97311", "Q8BFS6", "Q9D357", "Q61035", "Q9R111", "Q69ZN0", "Q9CR00", "Q9QUM9", "Q9CZ44", "Q3KQQ1", "O35344", "Q99LS3", "Q6QD59", "Q9D2N9", "A2AAN5", "Q9WVA4", "Q9QXS6", "Q9JHL1", "P58137", "Q9QZM0", "P47811", "Q3TZX8", "A8DUK4", "Q62203", "Q9DBU5", "Q9CWS0", "A2AP28", "P35283", "Q9CQX2", "Q9JHH9", "D3YWG1", "D3Z5X4", "Q6PE01", "Q64737", "Q9Z2U1", "Q99NC5", "Q5DTM8", "O54724", "P41216", "P05531", "Q3TNN7", "Q9DAE1", "Q8VDJ3", "P41105", "P29699", "Q9CXK3", "P01654", "P63260", "A2RT91", "P01027", "P68134", "Q8BJZ4", "O35643", "Q6NXY3", "Q5SVG5", "Q8CC13", "Q5SVG4", "Q05920", "Q3UFS6", "Q9ERE7", "D3YVR4", "P59178", "Q52KI8", "A2A8V8", "A2A8V9", "A2A8W1", "P47941", "Q5DTN6", "B9EJV3", "O70318", "Q8C928", "Q8VEK3", "O88568", "Q3TS50", "Q8C854", "Q62318", "Q3UDN8", "Q9JIY5", "Q3TXN0", "Q6PE62", "Q62084", "P03953", "B7ZNS9", "Q9DAW9", "Q99JN5", "Q9DCS3", "Q3U1J4", "Q9QYR9", "P26039", "Q3TBC3", "Q80TM2", "Q0V930", "Q8JZQ9", "O09131", "P19536", "Q9D881", "P61161", "A2A6H1", "Q99K47", "P98078", "Q3TN55", "Q3TRI2", "P24452", "Q99LB4", "Q9DCM0", "Q9QUR6", "O89060", "Q8CIH5", "P29391", "Q68FG2", "Q6A087", "Q80ZK2", "Q68FM2", "Q3UX10", "Q9D9Y2", "Q9D8S9", "Q9QXT0", "P21460", "P33622", "Q8C5L1", "Q9R1T2", "Q8CIM3", "P27612", "O09164", "Q9CX80", "Q8CAY6", "Q8CDN6", "P97855", "P97379", "Q571F9", "Q3U6B1", "Q9Z2I2", "P58252", "P10605", "P97493", "Q6PD26", "Q3V5L4", "O54796", "P01746", "P11032", "Q60932", "Q3TIG8", "Q9CYR0", "Q99KA2", "P97825", "Q9WTM5", "P19253", "Q99KI0", "Q8BJW6", "Q9CVB6", "P54818", "P28063", "Q3TUS1", "Q7TMN5", "P02468", "Q3URV4", "Q9D8Y0", "Q91YR1", "P47754", "P27546", "Q01514", "Q9CQ65", "Q501J6", "Q99KJ8", "Q921H8", "Q8R343", "Q8BLD7", "Q3TUU3", "P62267", "Q00896", "P17225", "Q4FZE5", "Q9Z2X1", "Q922I7", "Q8CB58", "Q3T984", "P15105", "O09165", "P62196", "Q9D8T7", "P06801", "Q61829", "Q3TQP6", "Q99LF5", "O54946", "P62137", "Q9D9V3", "E0CXS3", "Q922R1", "Q8BMJ3", "P62311", "Q9D051", "Q9DBJ1", "Q8BFR5", "Q9CZE7", "Q8R344", "O35955", "P19157", "Q9D753", "Q571G2", "Q9CQ71", "Q9CQR2", "Q61937", "Q9D0D5", "P63087", "Q61176", "Q99J77", "P62259", "Q3V453", "Q3U5N9", "P11679", "Q62432", "Q6LAF6", "Q8VEH8", "Q9CWA6", "Q9WU42", "Q80ZV7", "P16546", "Q9QUH0", "Q8BJY1", "Q921U5", "B0R0S3", "Q9Z110", "Q9JK23", "P48774", "Q9DBC7", "Q3UBA7", "Q3TYK4", "P99029", "Q91YU9", "Q9D6X2", "Q3U7H9", "Q3UWS9", "Q8BUN5", "P42208", "D3Z1S1", "Q8BZM1", "P42669", "O35295", "Q5XJY5", "O08586", "P63028", "D3YU75", "P26638", "Q9Z2D0", "Q9D1A2", "Q6KAT3", "Q3TNG9", "Q8R582", "Q8BM39", "Q06890", "Q9JK98", "Q91YP2", "Q3TB65", "Q9R0P6", "P16254", "Q6PHU5", "Q91VA7", "Q91W67", "Q922J3", "D3Z2Z1", "Q9QZF4", "D3Z3K6", "D3Z3M7", "Q9CPW4", "Q8R2L7", "P26645", "Q9CQA3", "Q0QEZ4", "Q91YD9", "Q3UQ99", "Q3UGK7", "Q8K0U4", "Q8VIJ6", "Q810V5", "Q7TMH7", "Q9Z1Q5", "Q3TGN5", "Q3V3R1", "Q8QZV4", "Q8BG05", "Q03147", "Q8CI94", "Q9CXW4", "Q9DAR7", "P37804", "Q60710", "Q61805", "O35381", "P31230", "Q8C2U7", "Q9CZY3", "Q9R0P3", "P06684", "Q99KX9", "P62627", "A2AVR9", "O08807", "O08738", "Q9D2M8", "Q3UIU2", "Q3UP94", "P14824", "Q9D125", "Q6KAU3", "Q3TSA9", "Q8JZM0", "P62204", "Q3UKW2", "P07309", "Q91YI0", "Q08093", "Q922F8", "D3Z7R6", "P68033", "P63158", "Q62264", "Q7TN29", "O35129", "Q9JHU2", "Q60787", "P12382", "P63271", "Q9CQ60", "D3Z4X1", "Q3U939", "Q01853", "Q8BNF8", "P45376", "Q8K274", "Q9CQ49", "O35215", "P28656", "Q9Z204", "Q3U7R1", "P99025", "O88696", "Q3UGW4", "Q9JHU4", "Q64475", "Q8CGP2", "Q61211", "P27005", "Q9WVK4", "Q6P9P6", "O08709", "Q6A0D0", "P97821", "D3Z220", "Q3U9B7", "P07758", "Q5SUH6", "Q4KML4", "Q7TMF3", "Q8BME2", "Q5M9K5", "Q8C166", "B7ZCP6", "Q571A1", "Q3UVB0", "Q3TBI0", "Q9ESE5", "O70493", "O70492", "Q9CSC2", "Q9JIG4", "B9EHL3", "P97760", "Q62018", "P46471", "Q8BVQ9", "Q9D0F3", "P14206", "Q99LI5", "Q64311", "P04186", "B8JJN0", "B8JJM8", "Q3UAS8", "Q9CR84", "P56383", "P56384", "O35841", "P80315", "Q3V1N9", "B2KGX5", "Q61264", "P21956", "Q3TDU5", "P43024", "Q9DCW5", "Q99JW2", "P01872", "P19324", "O08692", "Q3U136", "Q91VI7", "P49817", "P23927", "P61164", "P70296", "P47791", "Q3TXK9", "Q3TWI5", "Q3U9P5", "Q3UAS7", "Q91Z57", "Q3U9R7", "Q3U925", "Q3U9W1", "Q64442", "Q62093", "Q06477", "Q78ZA7", "O89023", "Q9Z0F7", "Q91WQ3", "A2A7S7", "Q01768", "Q9DCT8", "Q9Z1F9", "A2BH29", "Q9D8U8", "P49962", "Q6P1H6", "P26516", "Q8BW10", "Q9EQU5", "Q9JL62", "O55131", "Q5DTS3", "Q3UNN1", "P10649", "P15626", "Q7M0F4", "Q14CH7", "A2RT62", "Q0VG47", "Q52KG4", "Q9CRB1", "P60335", "Q61990", "Q8BJT9", "Q9CYG7", "P03958", "P17156", "Q9EQH2", "Q8C9W5", "Q3TJU7", "Q9Z2X2", "Q9WU56", "D3Z092", "Q9CQU3", "P53026", "P47753", "Q3THS6", "Q8VHM5", "Q3UKV5", "Q8BL32", "Q99KG1", "Q3UZI0", "P02463", "Q8QZS1", "Q8R010", "P62858", "P97429", "Q64514", "Q99JX3", "O88572", "P30115", "Q7TMA2", "Q8CGC7", "P01786", "Q91ZX7", "Q3U454", "Q3TCJ1", "P17918", "Q9CZD6", "P70245", "O35639", "Q99LH2", "Q6A0E5", "Q61704", "Q91XX1", "Q3UIC3", "Q99K20", "Q99K85", "Q8BH69", "P97351", "P99028", "Q8C2I2", "P51125", "Q8C281", "Q8CE04", "Q8CE80", "P16675", "Q9Z0J0", "O55126", "Q8BG32", "Q7TMI0", "Q8C0Z6", "Q8K2N7", "Q91ZA3", "D3YZC0", "Q5NCX5", "P70195", "Q5D098", "P14901", "P62500", "Q3UXU0", "D3Z0V7", "A7LCN1", "Q6PE86", "Q9CVK3", "Q148S0", "D3YW86", "Q3U1C5", "P70349", "Q9JLI2", "Q8K3Z9", "Q6A036", "O35737", "Q9WUB3", "P35441", "Q8CGB2", "Q3TPD3", "Q3TP59", "Q8R086", "Q3TPG2", "Q99LT6", "P61965", "Q8R097", "Q9QYB1", "B2KGW3", "B2KGW0", "Q9CPU2", "Q80X50", "Q6PDM2", "P47809", "B1ATL6", "Q78PY7", "Q61166", "Q9ESY9", "Q8BRB8", "Q3UYW8", "Q9WVJ2", "P61514", "A2AFS0", "A2AFS1", "P61982", "P99024", "P70404", "Q684I8", "Q91YQ5", "Q5RKP4", "O35309", "Q9D6J6", "Q62523", "Q6VY05", "O54782", "Q9QY84", "Q8VH51", "B7ZD63", "Q3UXT6", "B7ZD61", "P05784", "P01837", "A2NHM3", "Q52L95", "Q5XFY8", "A0A5E3", "Q66JS7", "Q58EU8", "Q52L64", "P63328", "Q505F5", "Q4G0B8", "Q61206", "P80317", "Q9JJW6", "O08583", "Q8BT60", "Q9CXU9", "P62806", "Q9D2R0", "Q8K3J7", "D3Z6E4", "Q9D0E1", "Q3THB3", "Q3UCL9", "Q3TQ66", "Q570Z0", "Q3TDR9", "Q3TG17", "Q9DBR7", "Q3TS88", "Q9CW12", "Q62043", "Q8BP54", "Q9CR21", "Q7TQK5", "Q91Z53", "D6REG4", "P70372", "Q3TT05", "Q8BTQ1", "P54728", "P08071", "Q3UM67", "P14115", "P45952", "Q8BJT5", "Q9CQH7", "Q810I2", "A1L3C6", "Q99MR8", "Q9CS42", "Q5NCF2", "P59999", "P54923", "Q9CTF5", "P56382", "Q8QZT1", "Q99LJ6", "P50396", "P62962", "P56399", "D3YYA5", "Q921I1", "P70460", "D3YYR8", "D3Z6Z0", "D3Z789", "Q9WV95", "P42225", "Q3TXT4", "Q9CQR6", "P05201", "Q60854", "P14869", "P09103", "Q3TIQ5", "Q9D211", "P62322", "Q06770", "Q9JHI7", "Q8VCM8", "Q9CZB0", "Q9QXX4", "P15379", "Q99KN2", "Q9DCS9", "Q03265", "P60843", "Q3U8I0", "Q4FZL1", "Q9CQN1", "Q922R9", "P31938", "Q91V92", "Q8BMA6", "P17426", "Q69ZW4", "Q9CQ43", "Q9CZU6", "Q9DCT2", "P83870", "P97873", "Q8BXZ1", "B1Q450", "P02104", "Q9WV54", "D3Z015", "Q91YT0", "P54822", "Q5QNQ9", "P63154", "Q9CQS8", "Q3UKP2", "Q9CQW0", "P53996", "O35382", "Q69ZD1", "Q60960", "P47199", "Q9ERR7", "Q9D8E6", "Q9Z160", "Q5DTY3", "Q8K310", "Q6ZQ61", "D3Z0H4", "Q9DCV7", "Q64521", "Q3TYS2", "Q91WC1", "Q91XD6", "Q3UBB2", "Q921M7", "Q3U935", "Q9JLI6", "Q9CYR6", "Q920B9", "Q6P2B1", "Q571K5", "Q9JHH6", "Q8BP47", "Q61191", "Q9QXS1", "Q99KI3", "Q9ESW4", "Q99LF4", "Q8BKU8", "Q8CGN5", "P28665", "Q9CQC8", "Q8K2C7", "Q80VQ0", "Q9DB05", "Q91WS0", "Q9CQM1", "Q9CWK8", "O54965", "Q9WUR2", "Q3TCD4", "Q6PHP4", "Q6ZPW1", "B7ZCR6", "Q5SWZ9", "Q7TPV4", "A0JLT5", "Q9CQW9", "Q8K0C9", "P23116", "Q6A0B9", "Q9CXI5", "A8C1V1", "Q8VCH0", "Q8BJ03", "Q9Z239", "Q8BK72", "Q8CH25", "Q8C522", "Q3UQH3", "Q69ZY2", "Q7TMU5"]
  proteaseids = Protein.with_substrates.map {|p| p.id}.flatten.uniq

     # FasterCSV.open("#{file}-cleavageedgeattributes.csv", 'w',{:headers => true, :col_sep => "\t"}) do |csv|
     #   csv << ['Protein','type','weight']
     #   Protein.with_substrates.each do |p|
     #     p.cleavages.each do |c|
     #       if c.substrate.present? && (termids.include?(c.substrate.ac) || proteaseids.include?(c.substrate.id))
     #         csv << ["#{p.ac} (cleavage) #{c.substrate.ac}-#{c.pos}",'cleaves',100000]
     #         csv << ["#{c.substrate.ac} (terminus) #{c.substrate.ac}-#{c.pos}",'has-terminus',50]
     #       end
     #     end
     #   end
     #   termnodes.each do |k,t|
     #   		csv << ["#{t[:ac]} (terminus) #{t[:ac]}-#{t[:pos]}",'has-terminus',50]
     #   end
     # end

   Protein.with_substrates.each do |p|
     p.cleavages.each do |c|
#           
       if c.substrate.present? && (termids.include?(c.substrate.ac) || proteaseids.include?(c.substrate.id))
         nodeproperties[c.substrate.ac] = [c.substrate.ac,'protein',c.substrate.name,0,0,0]
         nodeproperties[p.ac] = [p.ac,'protease',p.name,0,0,0]
         nodeproperties["#{c.substrate.ac}-#{c.pos}"] = ["#{c.substrate.ac}-#{c.pos}",'terminus',"#{c.substrate.name}@#{c.pos}",0,0,0]
         network << [c.substrate.ac,'terminus',"#{c.substrate.ac}-#{c.pos}",'has-terminus',20]
         network << [p.ac,'cleavage',"#{c.substrate.ac}-#{c.pos}",'cleaves',100000]
       end
     end
   end
   termnodes.each do |k,t|
   		network << [t[:ac],'terminus',"#{t[:ac]}-#{t[:pos]}",'has-terminus',20]
   		nodeproperties[t[:ac]] = [t[:ac],'protein',t[:name],0,0,0] unless nodeproperties.has_key?(t[:ac])
   		nodeproperties["#{t[:ac]}-#{t[:pos]}"] = ["#{t[:ac]}-#{t[:pos]}",'terminus',t[:name],t[:quant1],t[:quant2],t[:quant3]]
   end
  
   puts network.count
   network.uniq!

   puts network.count

     FasterCSV.open("#{file}-network.csv", 'w',{:headers => true, :col_sep => "\t"}) do |csv|
       csv << ['Protein','interaction','Proteinpos','type','weight']
       network.each do |n|
       	csv << n
       end
     end  
     
     FasterCSV.open("#{file}-nodeattributes.csv", 'w',{:headers => true, :col_sep => "\t"}) do |csv|
       csv << ['Node','type','name','wt_CatB','wt_CatS','wt_CatBS']
       nodeproperties.each do |k,v|
       	csv << v
       end       	
     end      
end