xml.instruct!
xml.topfindresults do
	if @count.present? 
		xml.matches @count
		xml.pages @pages
	else
		xml.proteins do
			@proteins.each do |p|
			  xml.protein do
				  xml.ac p.ac
				  xml.name p.name
				  xml.fullname p.recname 
				  xml.species p.species
			  end
			end
		end
	end
end

