# this is for cities.... see p_event_exists and p_venue_exists for noncity modifier
broad_likelihood =
	group_activity:
		crafty: 0.9
		smart: 0.4
		active: 0.9
		simple: 0.9
		sweet: 0.9
		crunk: 0.1
		unconventional: 0.5
		fresh_air: 0.9
	solo_activity:
		crafty: 0.1
		smart: 0.3
		active: 0.1
		simple: 0.0
		sweet: 0.0
		crunk: 0.0
		unconventional: 0.1
		fresh_air: 0.4
	venue:
		crafty: 0.4
		smart: 0.5
		active: 0.4
		simple: 0.05
		sweet: 0.1
		crunk: 0.5
		unconventional: 0.05
		fresh_air: 0.2
	event:
		crafty: 0.9
		smart: 0.9
		active: 0.7
		simple: 0.0
		sweet: 0.1
		crunk: 0.9
		unconventional: 0.3
		fresh_air: 0.6


@Recommender =

	best_kind_of_rec: (want, profile) ->
		likelihoods = {
			group_activity: Recommender.p_fulfilling_group_activity(want, profile)
			solo_activity:  Recommender.p_fulfilling_solo_activity(want, profile)
			venue:          Recommender.p_fulfilling_venue(want, profile)
			event:          Recommender.p_fulfilling_event(want, profile)
		}
		_.max(Object.keys(likelihoods), (k) -> likelihoods[k]);

	p_cohost: (want, profile) ->
		if want == 'fresh_air'
			_.max([Recommender.p_cohost('simple',profile), Recommender.p_cohost('active',profile)])
		else
			likely_everyone_refuses = 1.0
			for friend, aspects of profile.friends
				p_friend_cohost = if aspects[want] then aspects[want][0] else 0.0
				likely_everyone_refuses = likely_everyone_refuses * (1 - p_friend_cohost)
			1 - likely_everyone_refuses

	p_tagalong: (want, profile) ->
		likely_everyone_refuses = 1.0
		for friend, aspects of profile.friends
			p_friend_cohost = if aspects[want] then aspects[want][1] else 0.1
			likely_everyone_refuses = likely_everyone_refuses * (1 - p_friend_cohost)
		1 - likely_everyone_refuses

	best_cohost: (want, profile) ->
		if want == 'fresh_air'
			Recommender.best_cohost('simple', profile) or Recommender.best_cohost('active', profile)
		else
			_.max Object.keys(profile.friends), (k) ->
				if profile.friends[k][want] then profile.friends[k][want][0] else 0.0

	best_tagalong: (want, profile) ->
		if want == 'fresh_air'
			Recommender.best_tagalong('simple', profile) or Recommender.best_tagalong('active', profile)
		else
			_.max Object.keys(profile.friends), (k) ->
				if profile.friends[k][want] then profile.friends[k][want][1] else 0.1

	p_makes_time: (want, profile, min_time) ->
		if profile.wants_hours[want] > min_time then 0.3 else 0.9

	p_venue_exists: (want, profile) ->
		if profile.environment == 'urban' then 0.9 else 0.3

	p_event_exists: (want, profile) ->
		if profile.environment == 'urban' then 0.7 else 0.2

	p_fulfilling_group_activity: (want, profile) ->
		Recommender.p_cohost(want, profile) * Recommender.p_makes_time(want, profile, 1.5) * broad_likelihood['group_activity'][want]

	p_fulfilling_solo_activity: (want, profile) ->
		Recommender.p_makes_time(want, profile, 0.2) * broad_likelihood['solo_activity'][want]

	p_fulfilling_event: (want, profile) ->
		Recommender.p_event_exists(want, profile) * Recommender.p_tagalong(want, profile) * Recommender.p_makes_time(want, profile, 1.0) * broad_likelihood['event'][want]

	p_fulfilling_venue: (want, profile) ->
		Recommender.p_venue_exists(want, profile) * Recommender.p_tagalong(want, profile) * Recommender.p_makes_time(want, profile, 3.0) * broad_likelihood['venue'][want]
