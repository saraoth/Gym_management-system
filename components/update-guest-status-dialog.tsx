"use client"

import { useState } from "react"
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group"
import type { Guest } from "@/lib/types"

interface UpdateGuestStatusDialogProps {
  guest: Guest
  onClose: () => void
  onUpdate: (status: Guest["status"], notes: string) => void
}

export function UpdateGuestStatusDialog({ guest, onClose, onUpdate }: UpdateGuestStatusDialogProps) {
  const [selectedStatus, setSelectedStatus] = useState<Guest["status"]>(guest.status)
  const [notes, setNotes] = useState("")

  const statuses: Array<{ value: Guest["status"]; label: string; description: string }> = [
    { value: "new", label: "New", description: "Just added to the system" },
    { value: "contacted", label: "Contacted", description: "Initial contact made" },
    { value: "visited", label: "Visited", description: "Visited the gym" },
    { value: "converted", label: "Converted", description: "Became a member" },
    { value: "lost", label: "Lost", description: "Not interested anymore" },
  ]

  const handleUpdate = () => {
    onUpdate(selectedStatus, notes)
  }

  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Update Guest Status</DialogTitle>
        </DialogHeader>

        <div className="space-y-6">
          <div>
            <Label>Select Status</Label>
            <RadioGroup
              value={selectedStatus}
              onValueChange={(value) => setSelectedStatus(value as Guest["status"])}
              className="mt-3 space-y-3"
            >
              {statuses.map((status) => (
                <div
                  key={status.value}
                  className={`flex items-start gap-3 rounded-lg border p-4 ${
                    selectedStatus === status.value ? "border-primary bg-primary/5" : "border-border"
                  }`}
                >
                  <RadioGroupItem value={status.value} id={status.value} className="mt-1" />
                  <div className="flex-1">
                    <Label htmlFor={status.value} className="cursor-pointer font-semibold">
                      {status.label}
                    </Label>
                    <p className="text-sm text-muted-foreground">{status.description}</p>
                  </div>
                </div>
              ))}
            </RadioGroup>
          </div>

          <div>
            <Label htmlFor="notes">Notes (Optional)</Label>
            <Textarea
              id="notes"
              placeholder="Add any notes about this status change..."
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              className="mt-2"
              rows={3}
            />
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={onClose}>
            Cancel
          </Button>
          <Button onClick={handleUpdate}>Update Status</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
