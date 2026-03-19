import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { debounce } from "@ember/runloop";
import { service } from "@ember/service";
import BackButton from "discourse/components/back-button";
import Form from "discourse/components/form";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { eq } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";

export default class AdminFitnessChallengeForm extends Component {
  @service toasts;
  @service router;

  @tracked loading = false;
  @tracked weeklyPostEnabled;
  @tracked awardBadge;
  @tracked topicTitle = null;
  @tracked topicFetchState = null; // null | "loading" | "found" | "error"

  constructor(owner, args) {
    super(owner, args);
    this.weeklyPostEnabled = args.challenge?.weekly_post_enabled ?? true;
    this.awardBadge = args.challenge?.award_badge ?? true;
    if (args.challenge?.topic_id) {
      this.fetchTopicTitle(args.challenge.topic_id);
    }
  }

  get isEditing() {
    return !!this.args.challenge;
  }

  get formData() {
    if (this.isEditing) {
      const c = this.args.challenge;
      return {
        topic_id: c.topic_id,
        hashtag: c.hashtag,
        start_date: c.start_date,
        end_date: c.end_date,
        check_ins_needed: c.check_ins_needed,
        description: c.description ?? "",
        weekly_post_enabled: c.weekly_post_enabled ?? true,
        weekly_post_day: c.weekly_post_day ?? 1,
        weekly_post_hour: c.weekly_post_hour ?? 9,
        award_badge: c.award_badge ?? true,
        badge_name: c.badge_name ?? "",
        challenge_timezone: c.challenge_timezone ?? "UTC",
      };
    }
    return {
      topic_id: "",
      hashtag: "",
      start_date: "",
      end_date: "",
      check_ins_needed: 20,
      description: "",
      weekly_post_enabled: true,
      weekly_post_day: 1,
      weekly_post_hour: 9,
      award_badge: true,
      badge_name: "",
      challenge_timezone: "UTC",
    };
  }

  get timezones() {
    // ActiveSupport::TimeZone.all.map(&:name)
    return [
      "International Date Line West",
      "Midway Island",
      "American Samoa",
      "Hawaii",
      "Alaska",
      "Pacific Time (US & Canada)",
      "Tijuana",
      "Mountain Time (US & Canada)",
      "Arizona",
      "Chihuahua",
      "Mazatlan",
      "Central Time (US & Canada)",
      "Saskatchewan",
      "Guadalajara",
      "Mexico City",
      "Monterrey",
      "Central America",
      "Eastern Time (US & Canada)",
      "Indiana (East)",
      "Bogota",
      "Lima",
      "Quito",
      "Atlantic Time (Canada)",
      "Caracas",
      "La Paz",
      "Santiago",
      "Newfoundland",
      "Brasilia",
      "Buenos Aires",
      "Montevideo",
      "Georgetown",
      "Puerto Rico",
      "Greenland",
      "Mid-Atlantic",
      "Azores",
      "Cape Verde Is.",
      "Dublin",
      "Edinburgh",
      "Lisbon",
      "London",
      "Casablanca",
      "Monrovia",
      "UTC",
      "Belgrade",
      "Bratislava",
      "Budapest",
      "Ljubljana",
      "Prague",
      "Sarajevo",
      "Skopje",
      "Warsaw",
      "Zagreb",
      "Brussels",
      "Copenhagen",
      "Madrid",
      "Paris",
      "Amsterdam",
      "Berlin",
      "Bern",
      "Rome",
      "Stockholm",
      "Vienna",
      "West Central Africa",
      "Bucharest",
      "Cairo",
      "Helsinki",
      "Kyiv",
      "Riga",
      "Sofia",
      "Tallinn",
      "Vilnius",
      "Athens",
      "Istanbul",
      "Minsk",
      "Jerusalem",
      "Harare",
      "Pretoria",
      "Kaliningrad",
      "Moscow",
      "St. Petersburg",
      "Volgograd",
      "Kuwait",
      "Riyadh",
      "Nairobi",
      "Baghdad",
      "Tehran",
      "Abu Dhabi",
      "Muscat",
      "Baku",
      "Tbilisi",
      "Yerevan",
      "Kabul",
      "Ekaterinburg",
      "Islamabad",
      "Karachi",
      "Tashkent",
      "Chennai",
      "Kolkata",
      "Mumbai",
      "New Delhi",
      "Kathmandu",
      "Astana",
      "Dhaka",
      "Sri Jayawardenepura",
      "Almaty",
      "Novosibirsk",
      "Yangon",
      "Bangkok",
      "Hanoi",
      "Jakarta",
      "Krasnoyarsk",
      "Beijing",
      "Chongqing",
      "Hong Kong",
      "Urumqi",
      "Kuala Lumpur",
      "Singapore",
      "Taipei",
      "Perth",
      "Irkutsk",
      "Ulaanbaatar",
      "Seoul",
      "Osaka",
      "Sapporo",
      "Tokyo",
      "Yakutsk",
      "Adelaide",
      "Darwin",
      "Brisbane",
      "Canberra",
      "Melbourne",
      "Sydney",
      "Guam",
      "Port Moresby",
      "Hobart",
      "Vladivostok",
      "Magadan",
      "Solomon Is.",
      "New Caledonia",
      "Fiji",
      "Kamchatka",
      "Marshall Is.",
      "Auckland",
      "Wellington",
      "Nuku'alofa",
      "Tokelau Is.",
      "Chatham Is.",
      "Samoa",
    ];
  }

  get daysOfWeek() {
    return [
      { value: 0, name: i18n("fitness_challenge.admin.form.days.sunday") },
      { value: 1, name: i18n("fitness_challenge.admin.form.days.monday") },
      { value: 2, name: i18n("fitness_challenge.admin.form.days.tuesday") },
      { value: 3, name: i18n("fitness_challenge.admin.form.days.wednesday") },
      { value: 4, name: i18n("fitness_challenge.admin.form.days.thursday") },
      { value: 5, name: i18n("fitness_challenge.admin.form.days.friday") },
      { value: 6, name: i18n("fitness_challenge.admin.form.days.saturday") },
    ];
  }

  async fetchTopicTitle(topicId) {
    if (!topicId) {
      this.topicTitle = null;
      this.topicFetchState = null;
      return;
    }
    this.topicFetchState = "loading";
    this.topicTitle = null;
    try {
      const data = await ajax(`/t/${topicId}.json`);
      this.topicTitle = data.title;
      this.topicFetchState = "found";
    } catch {
      this.topicTitle = null;
      this.topicFetchState = "error";
    }
  }

  @action
  handleTopicIdChange(value, { set, name }) {
    set(name, value);
    debounce(this, this.fetchTopicTitle, value, 500);
  }

  @action
  handleWeeklyPostEnabled(value, { set, name }) {
    this.weeklyPostEnabled = value;
    set(name, value);
  }

  @action
  handleAwardBadge(value, { set, name }) {
    this.awardBadge = value;
    set(name, value);
  }

  @action
  async onSubmit(data) {
    if (this.loading) {
      return;
    }
    this.loading = true;
    try {
      let result;
      if (this.isEditing) {
        result = await ajax(
          `/admin/plugins/discourse-fitness-challenge/challenges/${this.args.challenge.id}`,
          { type: "PUT", data }
        );
        this.toasts.success({
          duration: "short",
          data: { message: i18n("fitness_challenge.admin.challenges.updated") },
        });
      } else {
        result = await ajax(
          "/admin/plugins/discourse-fitness-challenge/challenges",
          { type: "POST", data }
        );
        this.toasts.success({
          duration: "short",
          data: { message: i18n("fitness_challenge.admin.challenges.created") },
        });
      }
      this.args.onSave?.(result.challenge);
      if (!this.isEditing) {
        this.router.transitionTo(
          "adminPlugins.show.discourse-fitness-challenge-challenges.show",
          result.challenge.id
        );
      }
    } catch (err) {
      popupAjaxError(err);
    } finally {
      this.loading = false;
    }
  }

  <template>
    <div class="fitness-challenge-form">
      {{#if this.isEditing}}
        <BackButton
          @route="adminPlugins.show.discourse-fitness-challenge-challenges"
          @label="fitness_challenge.admin.challenges.title"
        />
      {{/if}}

      <Form
        @data={{this.formData}}
        @onSubmit={{this.onSubmit}}
        class="fitness-challenge-form__fields"
        as |form|
      >
        <form.Field
          @name="topic_id"
          @title={{i18n "fitness_challenge.admin.form.topic_id"}}
          @validation="required"
          @type="input-number"
          @onSet={{this.handleTopicIdChange}}
          as |field|
        >
          <field.Control
            min="1"
            placeholder={{i18n "fitness_challenge.admin.form.topic_id_placeholder"}}
          />
        </form.Field>

        {{#if (eq this.topicFetchState "loading")}}
          <p class="fcd-topic-preview fcd-topic-preview--loading">
            {{i18n "fitness_challenge.admin.form.topic_loading"}}
          </p>
        {{else if (eq this.topicFetchState "found")}}
          <p class="fcd-topic-preview fcd-topic-preview--found">
            {{i18n "fitness_challenge.admin.form.topic_found" title=this.topicTitle}}
          </p>
        {{else if (eq this.topicFetchState "error")}}
          <p class="fcd-topic-preview fcd-topic-preview--error">
            {{i18n "fitness_challenge.admin.form.topic_not_found"}}
          </p>
        {{/if}}

        <form.Field
          @name="hashtag"
          @title={{i18n "fitness_challenge.admin.form.hashtag"}}
          @validation="required"
          @type="input"
          as |field|
        >
          <field.Control
            placeholder={{i18n "fitness_challenge.admin.form.hashtag_placeholder"}}
          />
        </form.Field>

        <form.Field
          @name="start_date"
          @title={{i18n "fitness_challenge.admin.form.start_date"}}
          @validation="required"
          @type="input-date"
          as |field|
        >
          <field.Control />
        </form.Field>

        <form.Field
          @name="end_date"
          @title={{i18n "fitness_challenge.admin.form.end_date"}}
          @validation="required"
          @type="input-date"
          as |field|
        >
          <field.Control />
        </form.Field>

        <form.Field
          @name="challenge_timezone"
          @title={{i18n "fitness_challenge.admin.form.challenge_timezone"}}
          @type="select"
          as |field|
        >
          <field.Control as |select|>
            {{#each this.timezones as |tz|}}
              <select.Option @value={{tz}}>{{tz}}</select.Option>
            {{/each}}
          </field.Control>
        </form.Field>

        <form.Field
          @name="check_ins_needed"
          @title={{i18n "fitness_challenge.admin.form.check_ins_needed"}}
          @validation="required"
          @type="input-number"
          as |field|
        >
          <field.Control min="1" />
        </form.Field>

        <form.Field
          @name="description"
          @title={{i18n "fitness_challenge.admin.form.description"}}
          @type="textarea"
          as |field|
        >
          <field.Control
            placeholder={{i18n "fitness_challenge.admin.form.description_placeholder"}}
            rows="3"
          />
        </form.Field>

        <form.Field
          @name="weekly_post_enabled"
          @title={{i18n "fitness_challenge.admin.form.weekly_post_enabled"}}
          @type="toggle"
          @onSet={{this.handleWeeklyPostEnabled}}
          as |field|
        >
          <field.Control />
        </form.Field>

        {{#if this.weeklyPostEnabled}}
          <form.Field
            @name="weekly_post_day"
            @title={{i18n "fitness_challenge.admin.form.weekly_post_day"}}
            @type="select"
            as |field|
          >
            <field.Control as |select|>
              {{#each this.daysOfWeek as |day|}}
                <select.Option @value={{day.value}}>{{day.name}}</select.Option>
              {{/each}}
            </field.Control>
          </form.Field>

          <form.Field
            @name="weekly_post_hour"
            @title={{i18n "fitness_challenge.admin.form.weekly_post_hour"}}
            @type="input-number"
            as |field|
          >
            <field.Control min="0" max="23" />
          </form.Field>
        {{/if}}

        <form.Field
          @name="award_badge"
          @title={{i18n "fitness_challenge.admin.form.award_badge"}}
          @type="toggle"
          @onSet={{this.handleAwardBadge}}
          as |field|
        >
          <field.Control />
        </form.Field>

        {{#if this.awardBadge}}
          <form.Field
            @name="badge_name"
            @title={{i18n "fitness_challenge.admin.form.badge_name"}}
            @type="input"
            as |field|
          >
            <field.Control
              placeholder={{i18n "fitness_challenge.admin.form.badge_name_placeholder"}}
            />
          </form.Field>
        {{/if}}

        <form.Actions>
          <form.Submit
            @label="fitness_challenge.admin.form.save"
            @disabled={{this.loading}}
          />
          {{#if @onCancel}}
            <form.Button
              @label="fitness_challenge.admin.form.cancel"
              @action={{@onCancel}}
              class="btn-default"
            />
          {{/if}}
        </form.Actions>
      </Form>
    </div>
  </template>
}
