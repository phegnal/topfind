xml.instruct!
xml.topfindresults do
xml.proteins do
p = @protein
  xml.protein do
	  xml.ac p.ac
	  xml.name p.name
	  xml.ntermini do
	    @nterms.each do |nt|
		  xml.nterminus do
			  xml.id nt.id
			  xml.position nt.pos 
			  xml.sequence nt.protein.sequence[nt.pos-1..nt.pos+9]
			  xml.modification nt.terminusmodification.name
              if @getevidences
				  xml.evidences do
				  	nt.evidences.each do |r|
						xml.evidence do
							xml.id r.id
							xml.name r.name
							xml.description r.description
							xml.directness r.directness
							xml.physiological_relevance r.phys_relevance
							xml.confidence do
								xml.value r.confidence
								xml.type r.confidence_type
							end
							xml.protease_inhibitors_used r.protease_inhibitors_used
							xml.method r.method
							xml.pmid r.publications.map {|p|p.pmid}.join(',')
						end
					end
			  	  end
			  end
			  if @getfeatures
			  	  xml.affected_feature_boundaries do
					nt.targeted_boundaries.each do |f|
						xml.feature do
							xml.name f.name
							xml.from f.from
							xml.to f.to
						end
					end
				  end
			  	  xml.affected_features do
					nt.targeted_features.each do |f|
						xml.feature do
							xml.name f.name
							xml.from f.from
							xml.to f.to
						end
					end
				  end
				end
		  end
	    end
	  end
	  xml.ctermini do
	    @cterms.each do |ct|
		  xml.nterminus do
			  xml.id ct.id
			  xml.position ct.pos 
			  xml.sequence ct.protein.sequence[ct.pos-1..ct.pos+9]
			  xml.modification ct.terminusmodification.name
			  if @features
			  	  xml.affected_feature_boundaries do
					ct.targeted_boundaries.each do |f|
						xml.feature do
							xml.name f.name
							xml.from f.from
							xml.to f.to
						end
					end
				  end
			  	  xml.affected_features do
					ct.targeted_features.each do |f|
						xml.feature do
							xml.name f.name
							xml.from f.from
							xml.to f.to
						end
					end
				  end
			   end
		  end
	    end
	  end
	  xml.cleavages do
		@cleavages.each do |r|
		  xml.cleavage do
			  xml.id r.id
              xml.name r.name
			  xml.position r.pos
			  xml.protease do
				xml.ac r.protease.ac
				xml.name r.protease.name
			  end
			  xml.substrate do
				xml.ac r.substrate.ac
				xml.name r.substrate.name
			  end 
			  xml.sequence r.cleavagesite.piped_seq
			  if @features
			  	  xml.affected_feature_boundaries do
					r.targeted_boundaries.each do |f|
						xml.feature do
							xml.name f.name
							xml.from f.from
							xml.to f.to
						end
					end
				  end
			  	  xml.affected_features do
					r.targeted_features.each do |f|
						xml.feature do
							xml.name f.name
							xml.from f.from
							xml.to f.to
						end
					end
				  end
			  end
		  end
		end
	  end
  end
end
end

