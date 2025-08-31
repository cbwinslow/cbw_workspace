import { useRouter } from 'next/router'
import stages from '../../src/stages'
import Link from 'next/link'

export default function StagePage() {
  const router = useRouter()
  const { id } = router.query
  const stage = stages.find(s => s.id === id) || {}

  if (!stage.id) return <div style={{padding:24}}>Loading...</div>

  return (
    <div style={{ padding: 24 }}>
      <h1>{stage.title}</h1>
      <p>{stage.description}</p>

      <h3>Recommended actions</h3>
      <ul>
        {stage.actions.map((a,i) => <li key={i}>{a}</li>)}
      </ul>

      <h3>Which crew helps here</h3>
      <ul>
        {stage.crews.map(c => (
          <li key={c}><Link href={`/crew/${c}`}>{c}</Link></li>
        ))}
      </ul>

      <p><Link href="/">← Back</Link></p>
    </div>
  )
}
