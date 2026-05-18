'use client'

// components/groups/copy-invite-link-button.tsx

import { useState } from 'react'
import { Button } from '@/components/ui/button'

export function CopyInviteLinkButton({ url }: { url: string }) {
  const [copied, setCopied] = useState(false)

  async function handleCopy() {
    await navigator.clipboard.writeText(url)
    setCopied(true)
    setTimeout(() => setCopied(false), 2500)
  }

  return (
    <Button
      onClick={handleCopy}
      className="w-full bg-[#F5A623] text-black font-semibold h-10 hover:bg-[#E8981A] text-sm"
    >
      {copied ? '✓ Link copiado' : 'Copiar link de invitación'}
    </Button>
  )
}
