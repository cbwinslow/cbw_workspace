const crew = [
  {
    id: 'code-review',
    name: 'Code Review Crew',
    description: 'Specializes in automated + human code review and recommendations.',
    expertise: ['PR guidance', 'Static analysis', 'Test coverage suggestions'],
    recommendations: [
      'Enforce PR size limits',
      'Add unit/integration tests for new code paths',
      'Use linters and static analyzers as pre-commit hooks'
    ]
  },
  {
    id: 'product-dev',
    name: 'Product Dev Crew',
    description: 'Focuses on product decisions, prioritization, and delivery practices.',
    expertise: ['Roadmaps', 'User stories', 'UAT'],
    recommendations: [
      'Prioritize by impact vs effort',
      'Run short feedback loops with users',
      'Maintain a clear release checklist'
    ]
  },
  {
    id: 'tech-expert',
    name: 'Technical Experts Crew',
    description: 'Masters of architecture and choosing the right tooling for production.',
    expertise: ['Architecture reviews', 'Tool recommendations', 'Scalability patterns'],
    recommendations: [
      'Prefer containerized, reproducible builds for CI',
      'Use trunk-based development + feature flags for continuous delivery',
      'Pin tool versions and provide repo-local installers (e.g., Bazelisk)'
    ]
  }
]

export default crew
