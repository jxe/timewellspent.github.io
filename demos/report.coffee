@Report =
	best_bet_text: (want, profile) ->
		most_likely = Recommender.best_kind_of_rec want,profile;
		if most_likely == 'group_activity'
			"Plan a group activity w/ cohost #{Recommender.best_cohost(want, profile)}"
		else if most_likely == 'event'
			"Attend an existing event w/ #{Recommender.best_tagalong(want, profile)}"
		else if most_likely == 'venue'
			"Visit a venue.  Look on yelp."
		else if most_likely == 'solo_activity'
			"Do something by yourself: recommend an app or some content."
		else
		    "..."

	for_Recommender: (profile) ->
		lines = for want, hrs of profile.wants_hours
			"<b>#{want}</b>: <br><i>#{Report.best_bet_text want, profile}</i>"
		lines.join '<br>'

	generate: (Recommenders) -> 
		lines = for name, profile of Recommenders
			"<u>#{name}</u><br><br> #{Report.for_Recommender profile}<br><br>"
		lines.join ''
