class IceLogo
  
  def initialize()
  end
  
  
  # calls icelogo below but first gets the sequences in the right format
  # make sure the location of the terminus is marked with an ":"
  def terminusIcelogo(species, seqs, filepath, length)
    seqs2 = seqs.collect{|s|
      getNonPrimeSeq(s.split(":")[0], length) + getPrimeSeq(s.split(":")[1], length)
    }
    return icelogo('', species, seqs2, filepath)
  end


  ## filter = ?
  ## species (species ID) used for getting amino acid background i guess
  ## seqs: Sequences to be used - HAVE TO ALL BE OF SAME LENGTH
  ## filename - filename. Filepath is: #{RAILS_ROOT}/public/images/dynamic/#{filename}
  def icelogo(filter, species, seqs, filepath)
    require 'soap/wsdlDriver'
    # get icelogo and print it
    wsdl = 'http://iomics.ugent.be/icelogoserver/IceLogo.wsdl'
    @dbfetchSrv = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    resp =  @dbfetchSrv.getStaticIceLogo({'lExperimentalSet' => seqs,'lSpecies' => species,'lScoringType' => 'percentage', 'lYaxis' => 30,'lStartPosition'=>"-#{seqs[0].length/2}",'lPvalue' => 0.05,'lHeight'=>450,'lWidth'=>450})
        open(filepath, "w") do |file|
          file.write(resp.getStaticIceLogoReturn)
        end
   return  filepath
  end


  # gets sequence of required length and appends "X"s to the left
  def getPrimeSeq(seq, length)
    if seq.length >= length
      return seq[0,length]
    else
      return seq + "X"*(length - seq.length)
    end
  end


  # gets sequence of required length and appends "X"s to the right
  def getNonPrimeSeq(seq, length)
    if seq.length >= length
      return seq[seq.length-length,seq.length]
    else
      return "X"*(length - seq.length) + seq
    end  
  end

end
  