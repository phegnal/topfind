xml.instruct!
xml.topfindresults do
	if @count.present? 
		xml.matches @count
		xml.pages @pages
	else
		xml.ntermini do
			@results.each do |r|
			  xml.nterminus do
				  xml.id r.id
				  xml.protein r.protein.ac
				  xml.position r.pos 
				  xml.sequence r.protein.sequence[r.pos-1..r.pos+9]
				  xml.modification r.terminusmodification.name
			  end
			end
		end
	end
end
