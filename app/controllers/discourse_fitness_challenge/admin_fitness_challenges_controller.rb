# frozen_string_literal: true

class DiscourseFitnessChallenge::AdminFitnessChallengesController < Admin::AdminController
  requires_plugin DiscourseFitnessChallenge::PLUGIN_NAME

  def index
    challenges = FitnessChallenge.includes(:topic).order(start_date: :desc)
    render_serialized(challenges, FitnessChallengeSerializer, root: "challenges")
  end

  def show
    challenge = FitnessChallenge.includes(:topic).find_by(id: params[:id])
    raise Discourse::NotFound unless challenge
    render_serialized(challenge, FitnessChallengeSerializer, root: "challenge")
  end

  def create
    challenge = FitnessChallenge.new(challenge_params)
    if challenge.save
      sync_badge(challenge)
      render_serialized(challenge, FitnessChallengeSerializer, root: "challenge")
    else
      render_json_error(challenge)
    end
  end

  def update
    challenge = FitnessChallenge.find_by(id: params[:id])
    raise Discourse::NotFound unless challenge

    if challenge.update(challenge_params)
      sync_badge(challenge)
      render_serialized(challenge, FitnessChallengeSerializer, root: "challenge")
    else
      render_json_error(challenge)
    end
  end

  def destroy
    challenge = FitnessChallenge.find_by(id: params[:id])
    raise Discourse::NotFound unless challenge

    destroy_challenge_badge(challenge)
    challenge.destroy
    render json: success_json
  end

  def post_leaderboard
    challenge = FitnessChallenge.includes(:topic).find_by(id: params[:id])
    raise Discourse::NotFound unless challenge

    DiscourseFitnessChallenge::LeaderboardPoster.post_weekly_update(challenge)
    render json: success_json
  rescue StandardError => e
    render_json_error(e.message)
  end

  private

  def challenge_params
    params.permit(
      :topic_id,
      :hashtag,
      :start_date,
      :end_date,
      :check_ins_needed,
      :description,
      :weekly_post_enabled,
      :weekly_post_day,
      :weekly_post_hour,
      :award_badge,
      :badge_name,
      :challenge_timezone,
    )
  end

  def sync_badge(challenge)
    if challenge.award_badge && challenge.badge_name.present?
      if challenge.badge_id
        badge = Badge.find_by(id: challenge.badge_id)
        if badge
          badge.update(name: challenge.badge_name, description: badge_description_for(challenge))
        else
          create_badge_for(challenge)
        end
      else
        create_badge_for(challenge)
      end
    elsif challenge.badge_id
      Badge.find_by(id: challenge.badge_id)&.destroy
      challenge.update_column(:badge_id, nil)
    end
  rescue StandardError => e
    Rails.logger.warn(
      "FitnessChallenge: badge sync failed for challenge #{challenge.id}: #{e.message}",
    )
  end

  def create_badge_for(challenge)
    badge =
      Badge.create!(
        name: challenge.badge_name,
        description: badge_description_for(challenge),
        badge_type_id: BadgeType::Silver,
        allow_title: false,
        multiple_grant: false,
      )
    challenge.update_column(:badge_id, badge.id)
  end

  def badge_description_for(challenge)
    topic = Topic.find_by(id: challenge.topic_id)
    if topic
      I18n.t("fitness_challenge.badge.description_with_topic", title: topic.title)
    else
      I18n.t("fitness_challenge.badge.description_fallback")
    end
  end

  def destroy_challenge_badge(challenge)
    return unless challenge.badge_id
    Badge.find_by(id: challenge.badge_id)&.destroy
  end
end
