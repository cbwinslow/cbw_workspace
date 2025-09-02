// CrewAI integration skeleton
// This serverless API route will call a real CrewAI provider when
// CREWAI_API_URL and CREWAI_API_KEY are set in the environment. Otherwise
// it returns a safe mocked response so the repo remains key-free.

export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).json({ error: 'Only POST allowed' })

  const { crewId, prompt } = req.body || {}
  if (!crewId) return res.status(400).json({ error: 'crewId required' })

  const API_URL = process.env.CREWAI_API_URL || ''
  const API_KEY = process.env.CREWAI_API_KEY || ''

  if (API_URL && API_KEY) {
    // Real provider flow — POST to CREWAI_API_URL with Authorization header.
    try {
      const resp = await fetch(API_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${API_KEY}`
        },
        body: JSON.stringify({ crewId, prompt })
      })

      if (!resp.ok) {
        const text = await resp.text()
        return res.status(502).json({ error: `Upstream error: ${resp.status} ${text}` })
      }

      const data = await resp.json()
      // Expecting { advice, plan } from provider — pass through.
      return res.status(200).json(data)
    } catch (err) {
      return res.status(500).json({ error: `Provider call failed: ${String(err)}` })
    }
  }

  // Fallback mock response
  const advice = `(mock) For crew ${crewId}: Based on your prompt of ${String(prompt || '').slice(0,200)}, consider focusing on small PRs, adding tests, and ensuring CI passes.`
  const plan = `1. Run automated lint and tests\n2. Create a small PR with focused change\n3. Add unit tests for new behavior\n4. Request a targeted code review from Code Review Crew`;
  await new Promise(r => setTimeout(r, 200))
  return res.status(200).json({ advice, plan })
}
