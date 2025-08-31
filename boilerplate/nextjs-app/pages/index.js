import Link from 'next/link'
import crew from '../src/crew'
import stages from '../src/stages'

export default function Home() {
  return (
    <div style={{ fontFamily: 'system-ui, sans-serif', padding: 24 }}>
      <h1>Software Product Lifecycle Guide</h1>
      <p>This guide walks through typical stages and offers specialized crews to help.</p>

      <h2>Stages</h2>
      <ul>
        {stages.map(s => (
          <li key={s.id}><Link href={`/stages/${s.id}`}>{s.title}</Link> — {s.brief}</li>
        ))}
      </ul>

      <h2>Crews</h2>
      <ul>
        {crew.map(c => (
          <li key={c.id}><Link href={`/crew/${c.id}`}>{c.name}</Link> — {c.description}</li>
        ))}
      </ul>
    </div>
  )
}
