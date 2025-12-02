# Git Tag Action

A GitHub Composite Action to create and push a git tag to the current commit.

## Features

-   **Automatic Git Installation**: Checks for `git` and installs it (via `apt-get`) if missing.
-   **Git Configuration**: Automatically configures `user.name` and `user.email` to `github-actions[bot]` if not set.
-   **Tag Management**: Creates a local tag (idempotent) and pushes it to the remote repository.
-   **Checkout Included**: Includes `actions/checkout` step automatically, so you don't need to explicitly checkout in your workflow step (though typically you might already have checked out code). *Note: Since `actions/checkout` is idempotent, calling it multiple times is generally safe but might be redundant.*

## Usage

```yaml
steps:
  - uses: actions/checkout@v3
  - name: Create Tag
    uses: NVIDIA/dsx-github-actions/.github/actions/git-tag@main
    with:
      tag: "v1.0.0"
```

## Inputs

| Input | Description | Required | Default |
| :--- | :--- | :--- | :--- |
| `tag` | The tag name to create and push. | `true` | N/A |

## Behavior

1.  **Checkout**: Runs `actions/checkout@v3`.
2.  **Install Git**: Ensures `git` is installed on the runner.
3.  **Configure**: Sets git user/email to the GitHub Actions bot identity.
4.  **Tag**:
    -   Checks if the tag already exists locally.
    -   If not, creates the tag pointing to the current commit (`HEAD`).
5.  **Push**: Pushes the tag to `origin`.

## Notes

-   This action assumes it is running on a Linux runner (Ubuntu/Debian based) for the git installation logic.
-   The action uses the token provided to the workflow (implicitly via `actions/checkout`) to authenticate the push. Ensure your workflow has `contents: write` permission if you are pushing to a protected branch or need to create tags.
