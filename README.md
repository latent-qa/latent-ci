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
   Add a new workflow file in your repo:
   .github/workflows/latent-ci.yml
   
   ```bash
   name: Run Tests

   on:
     push:
       branches: [ main, develop ]
     pull_request:
       branches: [ main ]
     workflow_dispatch:
   
   jobs:
     test:
       runs-on: ubuntu-latest
       
       steps:
         - name: Checkout code
           uses: actions/checkout@v4
           
         - name: Run Latent Tests
           id: latent
           uses: latent-qa/latent-ci@v1.0
           with:
             api_key: ${{ secrets.LATENT_API_KEY }}
             project_id: ${{ secrets.LATENT_PROJECT_ID }}
             website_url: ${{ secrets.STAGING_URL }}  # Optional
             
         - name: Display test results
           run: |
             echo "Tests passed: ${{ steps.latent.outputs.passed }}"
             echo "Tests failed: ${{ steps.latent.outputs.failed }}"
             echo "Total tests: ${{ steps.latent.outputs.total }}"
             echo "Execution time: ${{ steps.latent.outputs.execution_time }}s"
             
         # Optional: Create a GitHub status check
         - name: Update status check
           if: always()
           run: |
             if [ "${{ steps.latent.outputs.failed }}" -eq "0" ]; then
               echo "All tests passed! ✅"
             else
               echo "${{ steps.latent.outputs.failed }} tests failed ❌"
             fi
   ```


## Push Code

On every push or pull_request, Latent will:

Receive repo, commit, and branch info

Trigger AI-powered tests via your Latent dashboard

Return pass/fail results directly in GitHub Actions
