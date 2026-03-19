# frozen_string_literal: true

module Jobs
  class FitnessChallengeWeeklyPost < ::Jobs::Scheduled
    every 1.hour

    def execute(_args)
      return unless SiteSetting.fitness_challenge_enabled

      FitnessChallenge.active.includes(:topic).find_each do |challenge|
        next unless challenge.weekly_post_enabled
        next unless challenge.active?

        tz = ActiveSupport::TimeZone[challenge.challenge_timezone] || Time.zone
        now = Time.now.in_time_zone(tz)
        next unless now.wday == challenge.weekly_post_day
        next unless now.hour == challenge.weekly_post_hour

        DiscourseFitnessChallenge::LeaderboardPoster.post_weekly_update(challenge)
      rescue StandardError => e
        Rails.logger.error(
          "FitnessChallengeWeeklyPost error for challenge #{challenge.id}: #{e.message}\n#{e.backtrace.first(5).join("\n")}",
        )
      end
    end
  end
end
