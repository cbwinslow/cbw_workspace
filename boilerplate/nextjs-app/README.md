# Lifecycle Guide Next.js App

Small Next.js app that walks users through a typical software product lifecycle and exposes three specialized crews:

- Code Review Crew
- Product Dev Crew
- Technical Experts Crew

Run locally:

```bash
cd boilerplate/nextjs-app
npm install
npm run dev
```

Open http://localhost:3000

CI
--
This project includes a GitHub Actions workflow at `.github/workflows/nextjs-ci.yml` which installs dependencies and runs `npm run build` for the app on push and pull requests that touch `boilerplate/nextjs-app/**`.

CrewAI integration
------------------
The crew pages include an "Ask this crew" box which posts to a local API route at `/api/crewai`.

- By default the API route returns a mocked response to keep the repo key-free.
- To wire a real AI provider, replace the mock in `pages/api/crewai.js` with a request to your preferred API and store the API key in environment variables (for Vercel: Project Settings → Environment Variables; for GitHub Actions: repository secrets).

Example: in GitHub Actions you can set `CREWAI_API_KEY` and call the real endpoint from the serverless route or from an Actions step.

CI: wire CrewAI (example)
-------------------------
Below is an example snippet you can add to your CI workflow to provide CrewAI credentials as secrets and exercise the API route.

```yaml
# jobs.build.steps:
	- name: Set up Node
		uses: actions/setup-node@v4
		with:
			node-version: '18'

	- name: Install
		working-directory: boilerplate/nextjs-app
		run: npm ci

	- name: Run CrewAI smoke test
		env:
			CREWAI_API_URL: ${{ secrets.CREWAI_API_URL }}
			CREWAI_API_KEY: ${{ secrets.CREWAI_API_KEY }}
		run: |
			# call the serverless route locally using a small server or integration test framework
			node -e "console.log('CREWAI smoke test placeholder')"
```

Set `CREWAI_API_URL` and `CREWAI_API_KEY` in your repository secrets before enabling the test. The smoke test is intentionally a placeholder to avoid hard failures in public forks.
