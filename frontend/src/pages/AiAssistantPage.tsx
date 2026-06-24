import { useState, useRef, useEffect } from 'react'
import { Send, Bot, User, Trash2, Sparkles, Loader2 } from 'lucide-react'
import { aiApi } from '@/api'
import { SectionHeader } from '@/components/ui'
import { cn } from '@/utils'
import type { ChatMessage } from '@/types'
import toast from 'react-hot-toast'

const STARTERS = [
  'What is my biggest privacy risk right now?',
  'Explain my Gmail permissions in simple terms',
  'How do I improve my privacy score?',
  'What data is being shared with third parties?',
  'Should I be worried about my breach exposure?',
]

export default function AiAssistantPage() {
  const [messages, setMessages] = useState<ChatMessage[]>([
    {
      id: '0',
      role: 'assistant',
      content: "Hi! I'm your PrivacyOS AI assistant. I have full context on your connected accounts, permissions, breaches, and privacy score. Ask me anything about your digital privacy — I'll give you specific, actionable advice.",
      timestamp: new Date(),
    }
  ])
  const [input, setInput] = useState('')
  const [loading, setLoading] = useState(false)
  const bottomRef = useRef<HTMLDivElement>(null)
  const inputRef = useRef<HTMLTextAreaElement>(null)

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages])

  const send = async (text?: string) => {
    const msg = (text ?? input).trim()
    if (!msg || loading) return

    const userMsg: ChatMessage = {
      id: Date.now().toString(),
      role: 'user',
      content: msg,
      timestamp: new Date(),
    }
    setMessages(prev => [...prev, userMsg])
    setInput('')
    setLoading(true)

    const history = messages.slice(-10).map(m => ({ role: m.role, content: m.content }))

    try {
      const data = await aiApi.chat(msg, history)
      const assistantMsg: ChatMessage = {
        id: (Date.now() + 1).toString(),
        role: 'assistant',
        content: data.response,
        timestamp: new Date(),
      }
      setMessages(prev => [...prev, assistantMsg])
    } catch {
      toast.error('AI unavailable. Check your API key configuration.')
      setMessages(prev => [...prev, {
        id: (Date.now() + 1).toString(),
        role: 'assistant',
        content: 'Sorry, I\'m temporarily unavailable. Please try again in a moment.',
        timestamp: new Date(),
      }])
    } finally {
      setLoading(false)
      setTimeout(() => inputRef.current?.focus(), 100)
    }
  }

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      send()
    }
  }

  const clearChat = () => {
    setMessages([{
      id: '0',
      role: 'assistant',
      content: "Chat cleared. What would you like to know about your privacy?",
      timestamp: new Date(),
    }])
  }

  return (
    <div className="max-w-3xl mx-auto flex flex-col h-[calc(100vh-120px)]">
      <SectionHeader
        title="AI Privacy Assistant"
        subtitle="Ask anything about your privacy posture"
        action={
          <button onClick={clearChat} className="btn-ghost text-zinc-500">
            <Trash2 className="w-4 h-4" /> Clear
          </button>
        }
      />

      {/* Chat Area */}
      <div className="flex-1 overflow-y-auto space-y-4 pb-4 pr-1">
        {messages.map(msg => (
          <div key={msg.id} className={cn('flex gap-3', msg.role === 'user' ? 'justify-end' : 'justify-start')}>
            {msg.role === 'assistant' && (
              <div className="w-8 h-8 rounded-full bg-brand-600/20 border border-brand-500/30 flex items-center justify-center shrink-0 mt-0.5">
                <Bot className="w-4 h-4 text-brand-400" />
              </div>
            )}
            <div className={cn(
              'max-w-[80%] rounded-2xl px-4 py-3 text-sm leading-relaxed',
              msg.role === 'user'
                ? 'bg-brand-600 text-white rounded-tr-sm'
                : 'bg-surface-800 border border-surface-700 text-zinc-200 rounded-tl-sm'
            )}>
              <MessageContent content={msg.content} />
            </div>
            {msg.role === 'user' && (
              <div className="w-8 h-8 rounded-full bg-surface-800 border border-surface-700 flex items-center justify-center shrink-0 mt-0.5">
                <User className="w-4 h-4 text-zinc-400" />
              </div>
            )}
          </div>
        ))}

        {loading && (
          <div className="flex gap-3 justify-start">
            <div className="w-8 h-8 rounded-full bg-brand-600/20 border border-brand-500/30 flex items-center justify-center shrink-0">
              <Bot className="w-4 h-4 text-brand-400" />
            </div>
            <div className="bg-surface-800 border border-surface-700 rounded-2xl rounded-tl-sm px-4 py-3">
              <div className="flex gap-1 items-center">
                <div className="w-2 h-2 rounded-full bg-brand-400 animate-bounce" style={{ animationDelay: '0ms' }} />
                <div className="w-2 h-2 rounded-full bg-brand-400 animate-bounce" style={{ animationDelay: '150ms' }} />
                <div className="w-2 h-2 rounded-full bg-brand-400 animate-bounce" style={{ animationDelay: '300ms' }} />
              </div>
            </div>
          </div>
        )}
        <div ref={bottomRef} />
      </div>

      {/* Starter prompts */}
      {messages.length <= 1 && (
        <div className="flex flex-wrap gap-2 mb-3">
          {STARTERS.map(s => (
            <button
              key={s}
              onClick={() => send(s)}
              className="text-xs px-3 py-1.5 rounded-full bg-surface-800 border border-surface-700 text-zinc-400 hover:text-zinc-100 hover:border-brand-500/50 transition-all"
            >
              {s}
            </button>
          ))}
        </div>
      )}

      {/* Input */}
      <div className="card p-2 flex items-end gap-2">
        <Sparkles className="w-4 h-4 text-brand-400 mb-2.5 ml-1 shrink-0" />
        <textarea
          ref={inputRef}
          value={input}
          onChange={e => setInput(e.target.value)}
          onKeyDown={handleKeyDown}
          placeholder="Ask about your privacy..."
          rows={1}
          className="flex-1 bg-transparent text-sm text-zinc-100 placeholder-zinc-500 resize-none outline-none py-1.5 max-h-32"
          style={{ lineHeight: '1.5' }}
        />
        <button
          onClick={() => send()}
          disabled={!input.trim() || loading}
          className="w-8 h-8 rounded-lg bg-brand-600 hover:bg-brand-500 disabled:opacity-40 disabled:cursor-not-allowed flex items-center justify-center transition-all shrink-0 mb-0.5"
        >
          {loading
            ? <Loader2 className="w-3.5 h-3.5 text-white animate-spin" />
            : <Send className="w-3.5 h-3.5 text-white" />}
        </button>
      </div>
      <p className="text-xs text-zinc-600 text-center mt-2">
        AI responses are based on your actual privacy data. Configure ANTHROPIC_API_KEY for full capability.
      </p>
    </div>
  )
}

function MessageContent({ content }: { content: string }) {
  // Simple markdown-ish renderer for bold and line breaks
  const parts = content.split(/(\*\*[^*]+\*\*)/g)
  return (
    <p className="whitespace-pre-wrap">
      {parts.map((part, i) =>
        part.startsWith('**') && part.endsWith('**')
          ? <strong key={i} className="font-semibold">{part.slice(2, -2)}</strong>
          : part
      )}
    </p>
  )
}
