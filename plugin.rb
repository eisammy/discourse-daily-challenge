# frozen_string_literal: true

# name: discourse-fitness-challenge
# about: Run time-limited fitness challenges on your Discourse forum. Participants check in by posting with a hashtag or uploading a workout photo. Admins get a real-time leaderboard dashboard, automated weekly progress posts, and a final results post with optional badge awards.
# version: 1.1.0
# authors: Rusty
# url: https://github.com/R23DPrinting/discourse-fitness-challenge
# required_version: 2.7.0

enabled_site_setting :fitness_challenge_enabled

register_svg_icon "dumbbell"
register_svg_icon "fire"
register_svg_icon "medal"

module ::DiscourseFitnessChallenge
  PLUGIN_NAME = "discourse-fitness-challenge"
end

require_relative "lib/discourse_fitness_challenge/engine"

after_initialize do
  add_admin_route(
    "fitness_challenge.admin.title",
    "discourse-fitness-challenge",
    { use_new_show_route: true },
  )

  require_relative "app/models/fitness_challenge"
  require_relative "app/models/fitness_check_in"
  require_relative "app/serializers/fitness_challenge_serializer"
  require_relative "app/serializers/fitness_check_in_serializer"
  require_relative "app/controllers/discourse_fitness_challenge/admin_fitness_challenges_controller"
  require_relative "app/controllers/discourse_fitness_challenge/admin_fitness_check_ins_controller"
  require_relative "app/controllers/discourse_fitness_challenge/admin_fitness_dashboard_controller"
  require_relative "lib/discourse_fitness_challenge/leaderboard_poster"
  require_relative "jobs/scheduled/fitness_challenge_weekly_post"
  require_relative "jobs/scheduled/fitness_challenge_final_post"
  require_relative "lib/discourse_fitness_challenge/check_in_service"

  on(:post_created) do |post, _opts, user|
    next unless SiteSetting.fitness_challenge_enabled
    next if post.post_type != Post.types[:regular]
    next if user.nil? || user.anonymous?

    DiscourseFitnessChallenge::CheckInService.process(post)
  end
end
