# Latent GitHub Action

Run AI-powered tests with Latent
 automatically on every push or pull request.

## Usage

1. ## Add Secret
   ```bash
   In your repository, go to:
   Settings > Secrets and variables > Actions > New repository secret
   ```


2. ## Generate API Key from Latent
   ```bash
   Name: LATENT_API_KEY
   Value: your Latent API key
   ```

3. ## Create Workflow
   ```bash
   Name: LATENT_API_KEY
   Value: your Latent API key
   Add a new workflow file in your repo:
   .github/workflows/latent-tests.yml

   name: Latent Tests

   on: [push, pull_request]
   jobs:
   run-latent:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Latent Tests
        uses: latent/github-action@v1
        with:
          api-key: ${{ secrets.LATENT_API_KEY }}
          project-id: my-project-id
          website-url: my-website-url (optional)
   ```


## Push Code

On every push or pull_request, Latent will:

Receive repo, commit, and branch info

Trigger AI-powered tests via your Latent dashboard

Return pass/fail results directly in GitHub Actions
