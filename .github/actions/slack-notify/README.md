# Slack Notify Action

A composite GitHub Action that wraps the official [slackapi/slack-github-action](https://github.com/slackapi/slack-github-action) to send notifications to Slack channels.

## Prerequisites

### 1. Create a Slack App

1. Go to https://api.slack.com/apps
2. Click **"Create New App"** → **"From scratch"**
3. Name your app (e.g., "GitHub Notifications") and select your workspace
4. Click **"Create App"**

### 2. Configure Bot Permissions

1. Navigate to **"OAuth & Permissions"** in the left sidebar
2. Scroll to **"Scopes"** → **"Bot Token Scopes"**
3. Add the following scopes:
   - `chat:write` - Send messages
   - `chat:write.public` - Send messages to public channels without joining
   - `channels:read` - (Optional) List public channels
4. Click **"Install to Workspace"** at the top
5. Copy the **"Bot User OAuth Token"** (starts with `xoxb-`)

### 3. Get Channel ID

**Method 1: From Slack UI**

1. Open the Slack channel
2. Click the channel name at the top
3. Scroll down to find the Channel ID (e.g., `C1234567890`)

**Method 2: Right-click method**

1. Right-click on the channel name
2. Select **"Copy Link"**
3. The URL contains the channel ID: `https://workspace.slack.com/archives/C1234567890`

### 4. Add Token to GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"**
4. Name: `SLACK_BOT_TOKEN`
5. Value: Your Bot User OAuth Token (from step 2)
6. Click **"Add secret"**

## Quick Start

### Basic Text Message

```yaml
name: Slack Notification

on:
  push:
    branches: [main]

jobs:
  notify:
    runs-on: ubuntu-latest
    steps:
      - uses: NVIDIA/dsx-github-actions/.github/actions/slack-notify@main
        with:
          slack-bot-token: ${{ secrets.SLACK_BOT_TOKEN }}
          channel-id: C1234567890
          message: "✅ Build completed successfully for ${{ github.repository }}!"
```

## How It Works

The action automatically injects the `channel` field into your payloads, so you don't need to include it manually:

- **Simple messages**: Just provide `message` input - channel is added automatically
- **Custom payloads**: Provide JSON in `payload` input - channel is merged automatically

**Example**: You provide this:

```json
{
  "blocks": [
    { "type": "section", "text": { "type": "mrkdwn", "text": "Hello!" } }
  ]
}
```

The action automatically merges it to:

```json
{
  "channel": "C1234567890",
  "blocks": [
    { "type": "section", "text": { "type": "mrkdwn", "text": "Hello!" } }
  ]
}
```

## Inputs

| Input             | Description                                 | Required | Default            |
| ----------------- | ------------------------------------------- | -------- | ------------------ |
| `slack-bot-token` | Slack Bot User OAuth Token (xoxb-...)       | Yes      | -                  |
| `channel-id`      | Slack channel ID (e.g., C1234567890)        | Yes      | -                  |
| `message`         | Simple text message (supports Slack mrkdwn) | No       | `''`               |
| `payload`         | Custom JSON payload for advanced formatting | No       | `''`               |
| `method`          | Slack API method to call                    | No       | `chat.postMessage` |
| `errors`          | Whether to fail the step on errors          | No       | `true`             |

## Outputs

| Output      | Description                             |
| ----------- | --------------------------------------- |
| `time`      | Time the message was sent               |
| `thread_ts` | Thread timestamp (for threaded replies) |
| `ts`        | Message timestamp                       |

## Examples

### Example 1: Deployment Success Notification

```yaml
name: Deploy and Notify

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Deploy Application
        run: ./deploy.sh

      - name: Notify Success
        if: success()
        uses: NVIDIA/dsx-github-actions/.github/actions/slack-notify@main
        with:
          slack-bot-token: ${{ secrets.SLACK_BOT_TOKEN }}
          channel-id: C1234567890
          message: |
            🚀 *Deployment Successful*

            *Repository:* ${{ github.repository }}
            *Branch:* ${{ github.ref_name }}
            *Commit:* ${{ github.sha }}
            *Author:* ${{ github.actor }}

            <${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}|View Workflow>
```

### Example 2: Failure Notification

```yaml
- name: Notify Failure
  if: failure()
  uses: NVIDIA/dsx-github-actions/.github/actions/slack-notify@main
  with:
    slack-bot-token: ${{ secrets.SLACK_BOT_TOKEN }}
    channel-id: C1234567890
    message: |
      ❌ *Build Failed*

      *Repository:* ${{ github.repository }}
      *Branch:* ${{ github.ref_name }}
      *Triggered by:* ${{ github.actor }}

      <${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}|View Logs>
```

### Example 3: Pull Request Notification

```yaml
name: PR Notifications

on:
  pull_request:
    types: [opened, closed]

jobs:
  notify:
    runs-on: ubuntu-latest
    steps:
      - name: PR Opened
        if: github.event.action == 'opened'
        uses: NVIDIA/dsx-github-actions/.github/actions/slack-notify@main
        with:
          slack-bot-token: ${{ secrets.SLACK_BOT_TOKEN }}
          channel-id: C1234567890
          message: |
            🔔 *New Pull Request*

            *Title:* ${{ github.event.pull_request.title }}
            *Author:* ${{ github.event.pull_request.user.login }}
            *Repository:* ${{ github.repository }}

            <${{ github.event.pull_request.html_url }}|View Pull Request>

      - name: PR Merged
        if: github.event.pull_request.merged == true
        uses: NVIDIA/dsx-github-actions/.github/actions/slack-notify@main
        with:
          slack-bot-token: ${{ secrets.SLACK_BOT_TOKEN }}
          channel-id: C1234567890
          message: |
            ✅ *Pull Request Merged*

            *Title:* ${{ github.event.pull_request.title }}
            *Merged by:* ${{ github.actor }}
            *Branch:* ${{ github.event.pull_request.head.ref }} → ${{ github.event.pull_request.base.ref }}
```

### Example 4: Advanced Block Kit Message

```yaml
- name: Send Rich Message
  uses: NVIDIA/dsx-github-actions/.github/actions/slack-notify@main
  with:
    slack-bot-token: ${{ secrets.SLACK_BOT_TOKEN }}
    channel-id: C1234567890
    payload: |
      {
        "blocks": [
          {
            "type": "header",
            "text": {
              "type": "plain_text",
              "text": "🎉 Release Published"
            }
          },
          {
            "type": "section",
            "fields": [
              {
                "type": "mrkdwn",
                "text": "*Version:*\nv1.2.3"
              },
              {
                "type": "mrkdwn",
                "text": "*Repository:*\n${{ github.repository }}"
              },
              {
                "type": "mrkdwn",
                "text": "*Released by:*\n${{ github.actor }}"
              },
              {
                "type": "mrkdwn",
                "text": "*Date:*\n$(date -u +'%Y-%m-%d %H:%M:%S UTC')"
              }
            ]
          },
          {
            "type": "actions",
            "elements": [
              {
                "type": "button",
                "text": {
                  "type": "plain_text",
                  "text": "View Release"
                },
                "url": "${{ github.server_url }}/${{ github.repository }}/releases/tag/v1.2.3"
              }
            ]
          }
        ]
      }
```

### Example 5: Conditional Notification (Success or Failure)

```yaml
- name: Send Build Status
  if: always()
  uses: NVIDIA/dsx-github-actions/.github/actions/slack-notify@main
  with:
    slack-bot-token: ${{ secrets.SLACK_BOT_TOKEN }}
    channel-id: C1234567890
    message: |
      ${{ job.status == 'success' && '✅' || '❌' }} *Build ${{ job.status }}*

      *Repository:* ${{ github.repository }}
      *Workflow:* ${{ github.workflow }}
      *Status:* ${{ job.status }}

      <${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}|View Details>
```

### Example 6: Reply to Thread

```yaml
- name: Initial Message
  id: initial-message
  uses: NVIDIA/dsx-github-actions/.github/actions/slack-notify@main
  with:
    slack-bot-token: ${{ secrets.SLACK_BOT_TOKEN }}
    channel-id: C1234567890
    message: "🔄 Deployment started..."

- name: Deploy
  run: ./deploy.sh

- name: Thread Reply
  uses: NVIDIA/dsx-github-actions/.github/actions/slack-notify@main
  with:
    slack-bot-token: ${{ secrets.SLACK_BOT_TOKEN }}
    channel-id: C1234567890
    payload: |
      {
        "thread_ts": "${{ steps.initial-message.outputs.ts }}",
        "text": "✅ Deployment completed successfully!"
      }
```

### Example 7: Multiple Channels

```yaml
- name: Notify Multiple Channels
  uses: NVIDIA/dsx-github-actions/.github/actions/slack-notify@main
  with:
    slack-bot-token: ${{ secrets.SLACK_BOT_TOKEN }}
    channel-id: C1234567890
    message: "📢 Important update!"

- name: Notify Dev Channel
  uses: NVIDIA/dsx-github-actions/.github/actions/slack-notify@main
  with:
    slack-bot-token: ${{ secrets.SLACK_BOT_TOKEN }}
    channel-id: C0987654321
    message: "👩‍💻 Dev team: deployment completed"
```

### Example 8: Schedule-Based Notifications

```yaml
name: Daily Report

on:
  schedule:
    - cron: "0 9 * * MON-FRI" # 9 AM UTC, Monday-Friday

jobs:
  daily-report:
    runs-on: ubuntu-latest
    steps:
      - name: Generate Report
        id: report
        run: |
          # Generate your report data
          echo "report_data=Sample report data" >> $GITHUB_OUTPUT

      - name: Send Daily Report
        uses: NVIDIA/dsx-github-actions/.github/actions/slack-notify@main
        with:
          slack-bot-token: ${{ secrets.SLACK_BOT_TOKEN }}
          channel-id: C1234567890
          message: |
            📊 *Daily Report* - $(date +'%Y-%m-%d')

            ${{ steps.report.outputs.report_data }}
```

### Example 9: Using Different API Methods

```yaml
# Update a message
- name: Update Message
  uses: NVIDIA/dsx-github-actions/.github/actions/slack-notify@main
  with:
    slack-bot-token: ${{ secrets.SLACK_BOT_TOKEN }}
    channel-id: C1234567890
    method: chat.update
    payload: |
      {
        "ts": "${{ steps.previous-message.outputs.ts }}",
        "text": "Updated message content"
      }
```

## Message Formatting

### Slack Mrkdwn Syntax

````
*bold text*
_italic text_
~strikethrough~
`code`
```code block```
> quote
• bullet
````

### Links

```
<https://example.com|Link Text>
<@U1234567890> - Mention user
<!channel> - Mention channel
<!here> - Mention active users
```

### Emojis

```
:smile: :rocket: :tada: :white_check_mark: :x:
```

## Block Kit Builder

Use the [Slack Block Kit Builder](https://app.slack.com/block-kit-builder) to design rich interactive messages.

## Troubleshooting

### Issue: "not_in_channel" Error

**Solution**: Either:

1. Add the bot to the channel (invite it like a regular user), OR
2. Add the `chat:write.public` scope to post to public channels without joining

### Issue: "channel_not_found" Error

**Solution**:

- Verify the channel ID is correct (not the channel name)
- Ensure the bot has access to the channel
- For private channels, the bot must be invited

### Issue: Token Not Working

**Solution**:

- Ensure you're using the Bot User OAuth Token (starts with `xoxb-`)
- Verify the token is added to GitHub Secrets correctly
- Check that required scopes are added to the bot

### Issue: Message Not Formatted

**Solution**:

- For simple formatting, use the `message` input with mrkdwn syntax
- For advanced formatting, use the `payload` input with Block Kit JSON
- Don't mix `message` and `payload` - `payload` takes precedence

### Issue: Rate Limiting

**Solution**:

- Slack has rate limits on API calls
- Use the `retries` input to handle temporary failures
- Consider batching notifications or using webhooks for high-volume scenarios

## Best Practices

### 1. Use GitHub Secrets for Tokens

Always store Slack tokens in GitHub Secrets, never hardcode them:

```yaml
slack-bot-token: ${{ secrets.SLACK_BOT_TOKEN }}
```

### 2. Use Channel IDs, Not Names

Always use channel IDs (e.g., `C1234567890`) instead of names (e.g., `#general`).

### 3. Add Context to Messages

Include relevant information in your notifications:

```yaml
message: |
  *Repository:* ${{ github.repository }}
  *Branch:* ${{ github.ref_name }}
  *Commit:* ${{ github.sha }}
  *Author:* ${{ github.actor }}
```

### 4. Use Conditional Notifications

Only send notifications when necessary:

```yaml
if: success()  # Only on success
if: failure()  # Only on failure
if: always()   # Always send
```

### 5. Handle Errors Gracefully

For non-critical notifications, set `errors: 'false'`:

```yaml
with:
  errors: "false" # Don't fail workflow if notification fails
```

### 6. Use Threads for Related Messages

Keep related messages organized using threads:

```yaml
thread_ts: ${{ steps.initial-message.outputs.ts }}
```

### 7. Design for Mobile

Keep messages concise and scannable - many users will read them on mobile devices.

## Security Considerations

1. **Token Storage**: Always use GitHub Secrets for Slack tokens
2. **Token Scope**: Use the minimum required scopes for your bot
3. **Channel Access**: Only give bot access to channels it needs
4. **Sensitive Data**: Avoid including secrets or sensitive data in messages
5. **Token Rotation**: Periodically rotate your Slack bot tokens

## Slack API Methods

Besides `chat.postMessage`, you can use other methods:

- `chat.update` - Update an existing message
- `chat.delete` - Delete a message
- `chat.scheduleMessage` - Schedule a message
- `files.upload` - Upload a file
- `reactions.add` - Add a reaction to a message

Refer to the [Slack API documentation](https://api.slack.com/methods) for all available methods.

## References

- [Slack API Documentation](https://api.slack.com/)
- [Slack Block Kit Builder](https://app.slack.com/block-kit-builder)
- [slackapi/slack-github-action](https://github.com/slackapi/slack-github-action)
- [Slack Message Formatting](https://api.slack.com/reference/surfaces/formatting)
- [Slack OAuth Scopes](https://api.slack.com/scopes)

## License

Copyright (c) 2025, NVIDIA CORPORATION. All rights reserved.

Licensed under the Apache License, Version 2.0.
