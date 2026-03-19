# Discourse Fitness Challenge

A Discourse plugin for running time-limited fitness challenges. Participants check in by posting with a challenge hashtag or uploading a workout photo. Admins get a real-time leaderboard dashboard, automated weekly progress posts, a final results announcement, and optional badge awards for completers.

## Screenshots

_Screenshots coming soon._

## Features

- **Hashtag or photo check-ins** — participants check in by posting with the configured hashtag (e.g. `#workout`) or by uploading any image to the challenge topic
- **One check-in per day** — enforced at both the application and database level; duplicate check-ins are silently ignored
- **Real-time admin dashboard** — leaderboard with rank, check-in count, current streak, and a GitHub-style contribution grid per participant
- **Automated weekly leaderboard posts** — posted to the challenge topic by the system user on a configurable day and hour (UTC)
- **Final results post** — automatically posted the day after the challenge ends, listing all participants who met the goal
- **Badge awards** — optionally award a custom Discourse badge to every participant who reaches the check-in goal
- **Manual leaderboard trigger** — admins can post the leaderboard at any time from the challenge management page
- **Admin check-in management** — add or remove check-ins for any user from the admin panel (for missed posts, support requests, etc.)
- **Per-challenge configuration** — each challenge has its own hashtag, dates, check-in goal, weekly post schedule, and badge settings

## Installation

Add the plugin to your Discourse `app.yml`:

```yaml
hooks:
  after_assets_precompile:
    - exec:
        cd: $home
        cmd:
          - git clone https://github.com/rusty/discourse-fitness-challenge.git plugins/discourse-fitness-challenge
```

Then rebuild your container:

```bash
./launcher rebuild app
```

## Configuration

### Site Settings

| Setting | Description |
|---|---|
| `fitness_challenge_enabled` | Master on/off switch for the plugin |

### Creating a Challenge

Go to **Admin → Plugins → Fitness Challenge → Challenges → New Challenge**.

| Field | Description |
|---|---|
| **Topic ID** | The ID of the Discourse topic where participants will post. The plugin will display the topic title as a confirmation after you enter the ID. |
| **Hashtag trigger** | The hashtag (without `#`) that triggers a check-in when included in a post. Only letters, digits, and underscores are allowed. |
| **Start date** | The first day of the challenge (inclusive). |
| **End date** | The last day of the challenge (exclusive — the challenge runs through the end of the day before this date). |
| **Check-ins needed** | The number of check-ins required to complete the challenge and qualify for the badge. |
| **Description** | Optional internal note about the challenge (not shown to participants). |
| **Enable weekly leaderboard post** | When enabled, the system automatically posts a leaderboard update to the challenge topic on a schedule. |
| **Post day of week** | Day the weekly post is published (Sunday–Saturday, UTC). |
| **Post hour (0–23 UTC)** | Hour the weekly post is published (UTC). |
| **Award completion badge** | When enabled, a Discourse badge is created and automatically granted to participants who reach the check-in goal when the challenge ends. |
| **Badge name** | Name of the badge to create (e.g. "March Fitness Champion"). |

## How Check-ins Work

A check-in is recorded automatically when a participant posts in the linked topic and their post matches either condition:

1. **Hashtag** — the post body contains the challenge hashtag (e.g. `#workout`). The match is case-insensitive and must be a whole word (preceded by a space or the start of the line).
2. **Image upload** — the post includes an image attachment (jpg, jpeg, png, gif, webp, heic, or avif).

**Rules:**
- Only one check-in is recorded per user per calendar day (based on the user's configured timezone, or UTC if none is set).
- Check-ins are only recorded while the challenge is active (between start date and end date).
- Anonymous users cannot check in.
- System posts and non-regular posts are ignored.

## Admin Dashboard

The dashboard (**Admin → Plugins → Fitness Challenge → Dashboard**) shows the currently active challenge with:

- **Challenge metadata** — hashtag, linked topic, and day progress
- **Stats tiles** — total participants, average check-ins, and overall challenge progress percentage
- **Leaderboard table** — ranked by total check-ins, showing streak and completion percentage for each participant
- **Contribution grid** — click any row to expand a GitHub-style heatmap of that participant's check-in history for the challenge period

## Weekly Posts

When **Enable weekly leaderboard post** is turned on for a challenge, the plugin posts a markdown leaderboard table to the challenge topic every week at the configured day and hour (UTC). The post is made by the system user and includes:

- The week's date range
- Current day progress in the challenge
- A ranked table of all participants with their check-in count, goal, and progress percentage

You can also trigger a leaderboard post manually at any time from the challenge detail page using the **Post leaderboard now** button.

## Final Results Post

The day after a challenge ends, the plugin automatically posts a final results summary to the challenge topic. The post includes:

- A list of all participants who reached the check-in goal (eligible for the badge)
- A summary of how many out of the total participants completed the challenge
- Congratulations to completers, or an encouraging message if no one reached the goal

The final post is sent exactly once per challenge.

## Badge Awarding

If **Award completion badge** is enabled and a **Badge name** is set, the plugin:

1. Creates a Discourse badge (Silver tier) when the challenge is saved
2. Automatically grants the badge to every participant who reaches the check-in goal when the final results post is published
3. Updates the badge name and description if you edit the challenge settings

The badge description is automatically set to reflect the linked topic title (e.g. "Awarded to participants who completed all required check-ins in March Fitness Challenge.").

## Admin Check-in Management

Admins can manually add or remove check-ins for any user from the challenge detail page (**Admin → Plugins → Fitness Challenge → Challenges → [challenge name]**). This is useful for:

- Adding check-ins for participants who posted outside the topic
- Correcting missed check-ins due to technical issues
- Removing erroneous check-ins

Manually added check-ins are marked with an "Admin" source label in the check-in list.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes, following the [Discourse plugin development guide](https://meta.discourse.org/t/beginners-guide-to-creating-discourse-plugins/30515)
4. Run the test suite: `bin/rspec plugins/discourse-fitness-challenge`
5. Lint your changes: `bin/lint --fix --recent`
6. Open a pull request

## License

MIT License. See [LICENSE](LICENSE) for details.
