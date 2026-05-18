'use client'

import { useState } from 'react'
import Link from 'next/link'
import { Button } from '@/components/ui/button'
import type { Group } from '@/types/database'

interface GroupCardProps {
  group: Group
  userId: string
}

export function GroupCard({ group, userId }: GroupCardProps) {
  const isOwner = group.created_by === userId  // ← created_by
  const [copied, setCopied] = useState(false)

  async function handleCopyInvite() {
    const url = `${window.location.origin}/invite/${group.invite_code}`
    await navigator.clipboard.writeText(url)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  return (
    <div className="bg-[#161616] rounded-xl border border-[#262626] p-4">
      <div className="flex items-start justify-between gap-2 mb-3">
        <div className="min-w-0">
          <div className="flex items-center gap-2 mb-0.5">
            <h3 className="text-white font-semibold text-sm truncate">{group.name}</h3>
            {isOwner && (
              <span className="text-[10px] text-[#F5A623] bg-[#F5A62318] px-1.5 py-0.5 rounded font-medium shrink-0">
                Admin
              </span>
            )}
          </div>
          <p className="text-[#555] text-xs">
            Código: <span className="text-[#888] font-mono tracking-wider">{group.invite_code}</span>
          </p>
        </div>
      </div>

      <div className="flex gap-2">
        <Link href={`/grupo/${group.id}`} className="flex-1">
          <Button
            size="sm"
            variant="outline"
            className="w-full h-8 text-xs border-[#2E2E2E] text-white bg-transparent hover:bg-[#1E1E1E]"
          >
            Ver grupo
          </Button>
        </Link>
        <Button
          size="sm"
          variant="outline"
          onClick={handleCopyInvite}
          className="h-8 text-xs border-[#2E2E2E] text-[#F5A623] bg-transparent hover:bg-[#1E1E1E] shrink-0 min-w-[100px]"
        >
          {copied ? '✓ Copiado' : 'Copiar link'}
        </Button>
      </div>
    </div>
  )
}
