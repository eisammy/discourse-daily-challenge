# frozen_string_literal: true

module DiscourseDailyChallenge
  module LeaderboardPoster
    def self.post_weekly_update(challenge)
      topic = challenge.topic
      return unless topic

      poster = DiscourseDailyChallenge.bot_user || Discourse.system_user

      PostCreator.create!(
        poster,
        topic_id: topic.id,
        raw: build_post_body(challenge),
        skip_validations: true,
        skip_guardian: true,
      )
    end

    def self.build_post_body(challenge)
      week_end = Date.current
      week_start = week_end - 6
      rows = build_leaderboard_rows(challenge)

      header = <<~MD
        ## 🏋️ #{I18n.t("daily_challenge.weekly_post.title")}

        **#{I18n.t("daily_challenge.weekly_post.period", start: week_start.strftime("%b %-d"), finish: week_end.strftime("%b %-d, %Y"))}**

        #{I18n.t("daily_challenge.weekly_post.days_elapsed", elapsed: challenge.elapsed_days, total: (challenge.end_date - challenge.start_date).to_i)}

        | | #{I18n.t("daily_challenge.weekly_post.user")} | #{I18n.t("daily_challenge.weekly_post.check_ins")} | #{I18n.t("daily_challenge.weekly_post.goal")} | #{I18n.t("daily_challenge.weekly_post.progress")} |
        |:---:|---|:---:|:---:|:---:|
      MD

      body =
        if rows.empty?
          I18n.t("daily_challenge.weekly_post.no_participants")
        else
          rows.join("\n")
        end

      header + body + "\n\n#{I18n.t("daily_challenge.weekly_post.footer")}"
    end

    def self.build_leaderboard_rows(challenge)
      challenge
        .check_ins
        .group(:user_id)
        .order("count_all DESC")
        .count
        .first(20)
        .each_with_index
        .map do |(user_id, count), idx|
          user = User.find_by(id: user_id)
          next unless user

          progress_pct =
            challenge.check_ins_needed > 0 ? ((count.to_f / challenge.check_ins_needed) * 100).round(1) : 0
          medal =
            case idx
            when 0 then "🥇"
            when 1 then "🥈"
            when 2 then "🥉"
            else "#{idx + 1}."
            end

          "| #{medal} | @#{user.username} | #{count} | #{challenge.check_ins_needed} | #{progress_pct}% |"
        end
        .compact
    end
  end
end
