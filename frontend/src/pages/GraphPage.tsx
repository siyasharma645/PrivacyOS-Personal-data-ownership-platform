import { useCallback, useMemo } from 'react'
import { useQuery } from '@tanstack/react-query'
import ReactFlow, {
  Background, Controls, MiniMap, useNodesState, useEdgesState,
  addEdge, type Node, type Edge, type Connection,
  BackgroundVariant, MarkerType, Handle, Position, NodeProps
} from 'reactflow'
import 'reactflow/dist/style.css'
import { Network, RefreshCw } from 'lucide-react'
import { graphApi } from '@/api'
import { SectionHeader, PageLoader } from '@/components/ui'
import { getScoreColor } from '@/utils'
import type { GraphData } from '@/types'
import { useQueryClient } from '@tanstack/react-query'

// ── Custom Node Components ──────────────────────────────────
const NODE_COLORS: Record<string, string> = {
  USER: '#6366f1',
  ACCOUNT: '#3b82f6',
  PERMISSION: '#f59e0b',
  DATA_CATEGORY: '#10b981',
}

const RISK_COLORS: Record<string, string> = {
  LOW: '#22c55e', MEDIUM: '#f59e0b', HIGH: '#f97316', CRITICAL: '#ef4444',
}

function UserNode({ data }: NodeProps) {
  return (
    <div className="px-4 py-3 rounded-xl border-2 shadow-lg min-w-[140px]"
      style={{ background: '#18181b', borderColor: '#6366f1', boxShadow: '0 0 16px #6366f133' }}>
      <Handle type="source" position={Position.Bottom} style={{ background: '#6366f1', border: 'none' }} />
      <div className="flex flex-col items-center gap-1">
        <div className="w-8 h-8 rounded-full bg-brand-600 flex items-center justify-center text-white text-sm font-bold">
          {(data.label as string)[0]?.toUpperCase()}
        </div>
        <p className="text-xs font-semibold text-zinc-100 text-center">{data.label as string}</p>
        <p className="text-xs text-zinc-500">{data.email as string}</p>
        <div className="mt-1 px-2 py-0.5 rounded-full text-xs font-bold" style={{ color: getScoreColor(data.score as number) }}>
          Score: {data.score as number}
        </div>
      </div>
    </div>
  )
}

function AccountNode({ data }: NodeProps) {
  const colors: Record<string, string> = { GOOGLE: '#4285f4', GITHUB: '#6e40c9', LINKEDIN: '#0a66c2' }
  const prov = (data.label as string).toUpperCase()
  const col = colors[prov] ?? '#6366f1'
  return (
    <div className="px-3 py-2.5 rounded-lg border shadow-md min-w-[120px]"
      style={{ background: '#18181b', borderColor: col + '66' }}>
      <Handle type="target" position={Position.Top} style={{ background: col, border: 'none' }} />
      <Handle type="source" position={Position.Bottom} style={{ background: col, border: 'none' }} />
      <div className="flex items-center gap-2">
        <div className="w-6 h-6 rounded flex items-center justify-center text-xs font-bold text-white"
          style={{ background: col }}>
          {(data.label as string)[0]}
        </div>
        <div>
          <p className="text-xs font-semibold text-zinc-100">{data.label as string}</p>
          <p className="text-xs text-zinc-500">{data.permCount as number} perms</p>
        </div>
      </div>
    </div>
  )
}

function PermissionNode({ data }: NodeProps) {
  const riskCol = RISK_COLORS[data.riskLevel as string] ?? '#6b7280'
  return (
    <div className="px-3 py-2 rounded-lg border shadow-sm min-w-[110px]"
      style={{ background: '#18181b', borderColor: riskCol + '55' }}>
      <Handle type="target" position={Position.Top} style={{ background: riskCol, border: 'none' }} />
      <Handle type="source" position={Position.Bottom} style={{ background: riskCol, border: 'none' }} />
      <div>
        <p className="text-xs font-medium text-zinc-200 truncate max-w-[140px]">{data.label as string}</p>
        <span className="text-xs px-1 py-0.5 rounded font-medium" style={{ color: riskCol, background: riskCol + '22' }}>
          {data.riskLevel as string}
        </span>
      </div>
    </div>
  )
}

function DataCategoryNode({ data }: NodeProps) {
  const riskCol = RISK_COLORS[data.riskLevel as string] ?? '#10b981'
  return (
    <div className="px-2.5 py-1.5 rounded-full border text-xs font-medium"
      style={{ background: riskCol + '15', borderColor: riskCol + '40', color: riskCol }}>
      <Handle type="target" position={Position.Top} style={{ background: riskCol, border: 'none', width: 6, height: 6 }} />
      {data.label as string}
    </div>
  )
}

const nodeTypes = {
  USER: UserNode,
  ACCOUNT: AccountNode,
  PERMISSION: PermissionNode,
  DATA_CATEGORY: DataCategoryNode,
}

// ── Layout algorithm ───────────────────────────────────────
function layoutNodes(graphData: GraphData): { nodes: Node[]; edges: Edge[] } {
  const nodeMap = new Map<string, Node>()
  const edgeList: Edge[] = []

  // Position by type
  const byType: Record<string, string[]> = { USER: [], ACCOUNT: [], PERMISSION: [], DATA_CATEGORY: [] }
  for (const n of graphData.nodes) {
    const t = n.type in byType ? n.type : 'DATA_CATEGORY'
    byType[t].push(n.id)
  }

  const positions: Record<string, { x: number; y: number }> = {}
  const yMap: Record<string, number> = { USER: 0, ACCOUNT: 160, PERMISSION: 340, DATA_CATEGORY: 520 }
  const xSpacing = 200

  for (const [type, ids] of Object.entries(byType)) {
    const totalW = (ids.length - 1) * xSpacing
    ids.forEach((id, i) => {
      positions[id] = { x: i * xSpacing - totalW / 2, y: yMap[type] ?? 600 }
    })
  }

  for (const n of graphData.nodes) {
    nodeMap.set(n.id, {
      id: n.id,
      type: n.type,
      position: positions[n.id] ?? { x: 0, y: 0 },
      data: { label: n.label, riskLevel: n.riskLevel, ...n.data },
    })
  }

  for (const e of graphData.edges) {
    const riskCol = RISK_COLORS[
      (nodeMap.get(e.target)?.data?.riskLevel as string) ?? 'LOW'
    ] ?? '#3f3f46'
    edgeList.push({
      id: e.id,
      source: e.source,
      target: e.target,
      label: e.label,
      labelStyle: { fontSize: 9, fill: '#71717a' },
      style: { stroke: riskCol + '88', strokeWidth: 1.5 },
      markerEnd: { type: MarkerType.ArrowClosed, color: riskCol + '88', width: 14, height: 14 },
      type: 'smoothstep',
    })
  }

  return { nodes: Array.from(nodeMap.values()), edges: edgeList }
}

export default function GraphPage() {
  const qc = useQueryClient()
  const { data: graphData, isLoading } = useQuery<GraphData>({
    queryKey: ['graph'],
    queryFn: graphApi.get,
  })

  const { nodes: initNodes, edges: initEdges } = useMemo(
    () => graphData ? layoutNodes(graphData) : { nodes: [], edges: [] },
    [graphData]
  )

  const [nodes, , onNodesChange] = useNodesState(initNodes)
  const [edges, setEdges, onEdgesChange] = useEdgesState(initEdges)
  const onConnect = useCallback((c: Connection) => setEdges(eds => addEdge(c, eds)), [setEdges])

  if (isLoading) return <PageLoader />

  const nodeCount = graphData?.nodes.length ?? 0
  const edgeCount = graphData?.edges.length ?? 0

  return (
    <div className="max-w-full space-y-4">
      <SectionHeader
        title="Data Ownership Graph"
        subtitle={`${nodeCount} nodes · ${edgeCount} relationships — interactive map of your data exposure`}
        action={
          <button onClick={() => qc.invalidateQueries({ queryKey: ['graph'] })} className="btn-secondary">
            <RefreshCw className="w-4 h-4" /> Refresh
          </button>
        }
      />

      {/* Legend */}
      <div className="flex gap-4 flex-wrap text-xs text-zinc-500">
        {[
          { color: '#6366f1', label: 'You (User)' },
          { color: '#3b82f6', label: 'Connected Account' },
          { color: '#f59e0b', label: 'Permission' },
          { color: '#10b981', label: 'Data Category' },
          { color: '#ef4444', label: 'Critical Risk' },
        ].map(({ color, label }) => (
          <div key={label} className="flex items-center gap-1.5">
            <div className="w-3 h-3 rounded-full" style={{ backgroundColor: color }} />
            {label}
          </div>
        ))}
      </div>

      {/* Graph */}
      <div className="card overflow-hidden" style={{ height: 580 }}>
        {nodeCount === 0 ? (
          <div className="h-full flex flex-col items-center justify-center gap-3">
            <Network className="w-12 h-12 text-zinc-700" />
            <p className="text-sm text-zinc-500">No data to visualize yet.</p>
            <p className="text-xs text-zinc-600">Connect accounts to see your data ownership graph.</p>
          </div>
        ) : (
          <ReactFlow
            nodes={nodes}
            edges={edges}
            onNodesChange={onNodesChange}
            onEdgesChange={onEdgesChange}
            onConnect={onConnect}
            nodeTypes={nodeTypes}
            fitView
            fitViewOptions={{ padding: 0.3 }}
            minZoom={0.3}
            maxZoom={2}
            proOptions={{ hideAttribution: true }}
          >
            <Background variant={BackgroundVariant.Dots} gap={24} size={1} color="#27272a" />
            <Controls showInteractive={false} />
            <MiniMap
              nodeColor={(n) => NODE_COLORS[n.type ?? ''] ?? '#3f3f46'}
              maskColor="rgba(9,9,11,0.8)"
              style={{ background: '#18181b' }}
            />
          </ReactFlow>
        )}
      </div>

      {/* Stats */}
      <div className="grid grid-cols-4 gap-3">
        {[
          { label: 'Total Nodes', value: nodeCount },
          { label: 'Relationships', value: edgeCount },
          { label: 'Accounts', value: graphData?.nodes.filter(n => n.type === 'ACCOUNT').length ?? 0 },
          { label: 'Data Categories', value: graphData?.nodes.filter(n => n.type === 'DATA_CATEGORY').length ?? 0 },
        ].map(({ label, value }) => (
          <div key={label} className="card p-3 text-center">
            <p className="text-xl font-bold text-zinc-100">{value}</p>
            <p className="text-xs text-zinc-500 mt-0.5">{label}</p>
          </div>
        ))}
      </div>
    </div>
  )
}
