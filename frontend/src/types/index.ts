export type RiskLevel = 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL'
export type EventSeverity = 'INFO' | 'WARNING' | 'CRITICAL'

export interface User {
  id: string
  email: string
  fullName: string
  avatarUrl?: string
  emailVerified: boolean
  privacyScore: number
  riskLevel: RiskLevel
  provider: string
  role: string
  createdAt: string
}

export interface AuthResponse {
  accessToken: string
  refreshToken: string
  tokenType: string
  expiresIn: number
  user: User
}

export interface ConnectedAccount {
  id: string
  provider: string
  providerEmail: string
  displayName: string
  avatarUrl?: string
  status: string
  riskContribution: number
  scopes: string[]
  permissions: Permission[]
  permissionCount: number
  highRiskCount: number
  lastSyncedAt: string
  createdAt: string
}

export interface Permission {
  id: string
  accountId: string
  scopeName: string
  displayName: string
  description: string
  riskLevel: RiskLevel
  category: string
  dataTypes: string[]
  revocable: boolean
  sensitive: boolean
  grantedAt: string
}

export interface BreachRecord {
  id: string
  breachName: string
  title: string
  domain: string
  breachDate: string
  dataClasses: string[]
  pwnCount: number
  description: string
  logoPath?: string
  verified: boolean
  sensitive: boolean
  remediated: boolean
  createdAt: string
}

export interface PrivacyEvent {
  id: string
  eventType: string
  entityType: string
  title: string
  description: string
  severity: EventSeverity
  scoreBefore?: number
  scoreAfter?: number
  createdAt: string
}

export interface PrivacyRecommendation {
  id: string
  type: string
  priority: RiskLevel
  title: string
  description: string
  actionLabel: string
  actionUrl?: string
  expectedScoreImprovement: number
  status: string
  relatedAccountId?: string
  relatedAccountProvider?: string
  createdAt: string
}

export interface ScoreDataPoint {
  date: string
  score: number
}

export interface DashboardData {
  privacyScore: number
  previousScore: number
  scoreChange: number
  riskLevel: RiskLevel
  connectedAccounts: number
  activePermissions: number
  highRiskPermissions: number
  unresolvedBreaches: number
  pendingRecommendations: number
  scoreHistory: ScoreDataPoint[]
  recentAccounts: ConnectedAccount[]
  topRecommendations: PrivacyRecommendation[]
}

export interface PrivacyScoreData {
  score: number
  riskLevel: RiskLevel
  permissionPenalty: number
  breachPenalty: number
  thirdPartyPenalty: number
  sprawlPenalty: number
  stalenessPenalty: number
  breakdown: Record<string, number>
  history: ScoreDataPoint[]
}

export interface GraphNode {
  id: string
  type: string
  label: string
  riskLevel: string
  data: Record<string, unknown>
}

export interface GraphEdge {
  id: string
  source: string
  target: string
  label: string
  type: string
}

export interface GraphData {
  nodes: GraphNode[]
  edges: GraphEdge[]
}

export interface PageResponse<T> {
  content: T[]
  totalElements: number
  totalPages: number
  number: number
  size: number
}

export interface ChatMessage {
  id: string
  role: 'user' | 'assistant'
  content: string
  timestamp: Date
}
