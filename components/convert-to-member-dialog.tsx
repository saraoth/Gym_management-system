"use client"

import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
  DialogDescription,
} from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import type { Guest } from "@/lib/types"

interface ConvertToMemberDialogProps {
  guest: Guest
  onClose: () => void
  onConvert: () => void
}

export function ConvertToMemberDialog({ guest, onClose, onConvert }: ConvertToMemberDialogProps) {
  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Convert to Member</DialogTitle>
          <DialogDescription>
            This will mark {guest.name} as converted and redirect you to add them as a member.
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4">
          <p className="text-sm text-muted-foreground">
            After confirming, you'll be redirected to the members page where you can complete the member registration
            with full details and payment information.
          </p>
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={onClose}>
            Cancel
          </Button>
          <Button onClick={onConvert} className="bg-success hover:bg-success/90">
            Convert to Member
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
