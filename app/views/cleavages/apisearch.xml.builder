xml.instruct!
xml.topfindresults do
	if @count.present? 
		xml.matches @count
		xml.pages @pages
	else
		xml.cleavages do
			@results.each do |r|
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
			  end
			end
		end
	end
end

