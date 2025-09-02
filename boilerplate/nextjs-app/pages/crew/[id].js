import { useRouter } from 'next/router'
import crew from '../../src/crew'
import Link from 'next/link'
import { useState } from 'react'

export default function CrewPage() {
  const router = useRouter()
  const { id } = router.query
  const member = crew.find(c => c.id === id) || {}
  const [loading, setLoading] = useState(false)
  const [response, setResponse] = useState(null)
  const [input, setInput] = useState('')

  if (!member.id) return <div style={{padding:24}}>Loading...</div>

  async function askCrew() {
    setLoading(true)
    setResponse(null)
    try {
      const res = await fetch('/api/crewai', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ crewId: member.id, prompt: input })
      })
      const body = await res.json()
      setResponse(body)
    } catch (err) {
      setResponse({ error: String(err) })
    } finally {
      setLoading(false)
    }
  }

  return (
    <div style={{ padding: 24 }}>
      <h1>{member.name}</h1>
      <p>{member.description}</p>

      <h3>Expertise</h3>
      <ul>
        {member.expertise.map((e,i) => <li key={i}>{e}</li>)}
      </ul>

      <h3>Sample recommendations</h3>
      <ul>
        {member.recommendations.map((r,i) => <li key={i}>{r}</li>)}
      </ul>

      <hr />
      <h3>Ask this crew (CrewAI)</h3>
      <p>Paste a code snippet, PR link, or short context and click "Ask Crew" to get tailored recommendations. This uses a local mock unless you wire a real CrewAI API key (see README).</p>

      <textarea
        value={input}
        onChange={e => setInput(e.target.value)}
        rows={6}
        style={{ width: '100%', fontFamily: 'monospace', marginBottom: 8 }}
        placeholder="Paste code or context here (optional)"
      />

      <div style={{ display: 'flex', gap: 8, marginBottom: 12 }}>
        <button onClick={askCrew} disabled={loading}>
          {loading ? 'Asking…' : 'Ask Crew'}
        </button>
        <button onClick={() => { setInput(''); setResponse(null) }}>
          Clear
        </button>
      </div>

      {response && (
        <div style={{ background: '#f7f7f7', padding: 12, borderRadius: 6 }}>
          <h4>Response</h4>
          {response.error ? (
            <pre style={{ color: 'crimson' }}>{response.error}</pre>
          ) : (
            <>
              <strong>Advice:</strong>
              <pre style={{ whiteSpace: 'pre-wrap' }}>{response.advice}</pre>
              {response.plan && (
                <>
                  <strong>Plan:</strong>
                  <pre style={{ whiteSpace: 'pre-wrap' }}>{response.plan}</pre>
                </>
              )}
            </>
          )}
        </div>
      )}

      <p style={{ marginTop: 18 }}><Link href="/">← Back</Link></p>
    </div>
  )
}
