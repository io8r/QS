module ApplicationHelper

	#displays a page title
	def full_title(page_title = '')
		
		base_title = "RoR"
		
		if page_title.empty?
			base_title
		else
			page_title + " | " + base_title
		end
		
	end

end
