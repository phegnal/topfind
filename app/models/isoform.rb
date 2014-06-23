class Isoform < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    ac       :string
    name     :string
    sequence :text
    status         enum_string('created','pruned','updated','unknown'), :default => 'unknown'    
    timestamps
  end

  belongs_to :protein


#Cleavage, Substrate, Inhibition related
  has_many :cleavages, :foreign_key => 'protease_id'
  has_many :substrates, :through => :cleavages
  has_many :inverse_cleavages, :class_name => "Cleavage", :foreign_key => "substrate_id"
  has_many :proteases, :through => :inverse_cleavages  
 
  has_many :inhibitions, :foreign_key => 'protease_id'
  has_many :inhibitors, :through => :inhibitions 
  has_many :inverse_inhibitions, :class_name => "Inhibition", :foreign_key => "inhibitor_id"
  has_many :inhibited_proteases, :through => :inverse_inhibitions 

  has_many :chains
  has_many :cterms
  has_many :nterms
  
  # def htmlsequence
    # self.sequence.gsub(/(.{5})/,'\1 ')
  # end
  
  def htmlsequence
    numbering = ''
    blocks = (self.sequence.length/10).to_i + 1 # +1 added by nik to correct a bug (eg P63104)
    number=10
    blocks.times do |i|
      number = ((i+1)*10).to_s  # current digit
      if(i + 1 != blocks) then
        numbering = numbering.concat(' '*(10-number.length))  # adds empty space between digits
        numbering = numbering.concat(number)  # adds digits (0, 10, 20, 30,...)
      else # last block (the block that's not full, all full blocks get a number)
        numbering = numbering.concat('   ') # Nik added this, this is not superpretty (makes empty new line if the sequence is x*60 length)
      end
    end
    # break numbering string and sequence string into arrays (elements length 60) and add spaces in elements
    # Nik had to replace regexpr from /.{1,59}./ to /.{1,60}/ because otherwise a block with one element wouldn't be recognized (eg P04731)
    numberstrings = numbering.to_s.scan(/.{1,60}/).map {|s| s.gsub(/(.{10})/,'\1 ')} 
    seqstrings = self.sequence.scan(/.{1,60}/).map {|s| s.gsub(/(.{10})/,'\1 ')}
    # merge arrays alternating one by one (zip) and then join with new space (<br>)
    numberstrings.zip(seqstrings).flatten.join('<br/>').gsub(/ /,'&nbsp;').html_safe 
  end

  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

end
