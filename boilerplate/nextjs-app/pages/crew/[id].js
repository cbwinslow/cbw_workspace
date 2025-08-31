import { useRouter } from 'next/router'
import crew from '../../src/crew'
import Link from 'next/link'

export default function CrewPage() {
  const router = useRouter()
  const { id } = router.query
  const member = crew.find(c => c.id === id) || {}
  if (!member.id) return <div style={{padding:24}}>Loading...</div>

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

      <p><Link href="/">← Back</Link></p>
    </div>
  )
}
