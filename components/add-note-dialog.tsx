"use client"

import { useState } from "react"
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"

interface AddNoteDialogProps {
  onClose: () => void
  onAdd: (note: string) => void
}

export function AddNoteDialog({ onClose, onAdd }: AddNoteDialogProps) {
  const [note, setNote] = useState("")

  const handleAdd = () => {
    if (note.trim()) {
      onAdd(note.trim())
    }
  }

  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Add Member Note</DialogTitle>
        </DialogHeader>

        <div className="space-y-4">
          <div>
            <Label htmlFor="note">Note</Label>
            <Textarea
              id="note"
              placeholder="Enter note about this member..."
              value={note}
              onChange={(e) => setNote(e.target.value)}
              className="mt-2"
              rows={5}
            />
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={onClose}>
            Cancel
          </Button>
          <Button onClick={handleAdd} disabled={!note.trim()}>
            Add Note
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
