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
