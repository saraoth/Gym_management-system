"use client"

import { useState } from "react"
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Label } from "@/components/ui/label"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { dataService } from "@/lib/data"
import type { Attendance } from "@/lib/types"

interface CheckInDialogProps {
  onClose: () => void
  onCheckIn: (record: Attendance) => void
}

export function CheckInDialog({ onClose, onCheckIn }: CheckInDialogProps) {
  const [formData, setFormData] = useState({
    memberId: "",
    type: "",
    trainerId: "",
  })

  const members = dataService.getMembers().filter((m) => m.status === "active")
  const trainers = dataService.getTrainers().filter((t) => t.status === "active")

  const handleCheckIn = () => {
    if (!formData.memberId || !formData.type) {
      return
    }

    const member = dataService.getMember(formData.memberId)
    if (!member) return

    const newRecord: Attendance = {
      id: Date.now().toString(),
      memberId: formData.memberId,
      memberName: member.name,
      checkIn: new Date().toISOString(),
      type: formData.type as Attendance["type"],
      trainerId: formData.trainerId || undefined,
    }

    onCheckIn(newRecord)
  }

  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Check In Member</DialogTitle>
        </DialogHeader>

        <div className="space-y-6">
          <div>
            <Label htmlFor="memberId">Member *</Label>
            <Select value={formData.memberId} onValueChange={(value) => setFormData({ ...formData, memberId: value })}>
              <SelectTrigger className="mt-2">
                <SelectValue placeholder="Select member" />
              </SelectTrigger>
              <SelectContent>
                {members.map((member) => (
                  <SelectItem key={member.id} value={member.id}>
                    {member.name}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          <div>
            <Label htmlFor="type">Check-in Type *</Label>
            <Select value={formData.type} onValueChange={(value) => setFormData({ ...formData, type: value })}>
              <SelectTrigger className="mt-2">
                <SelectValue placeholder="Select type" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="gym">Gym</SelectItem>
                <SelectItem value="class">Class</SelectItem>
                <SelectItem value="pt-session">PT Session</SelectItem>
              </SelectContent>
            </Select>
          </div>

          {formData.type === "pt-session" && (
            <div>
              <Label htmlFor="trainerId">Trainer</Label>
              <Select
                value={formData.trainerId}
                onValueChange={(value) => setFormData({ ...formData, trainerId: value })}
              >
                <SelectTrigger className="mt-2">
                  <SelectValue placeholder="Select trainer" />
                </SelectTrigger>
                <SelectContent>
                  {trainers.map((trainer) => (
                    <SelectItem key={trainer.id} value={trainer.id}>
                      {trainer.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          )}
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={onClose}>
            Cancel
          </Button>
          <Button onClick={handleCheckIn} disabled={!formData.memberId || !formData.type}>
            Check In
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
