"use client"

import { useState } from "react"
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Label } from "@/components/ui/label"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { dataService } from "@/lib/data"
import type { Guest } from "@/lib/types"

interface EditGuestDialogProps {
  guest: Guest
  onClose: () => void
  onSave: (updates: Partial<Guest>) => void
}

export function EditGuestDialog({ guest, onClose, onSave }: EditGuestDialogProps) {
  const [formData, setFormData] = useState({
    name: guest.name,
    phone: guest.phone,
    email: guest.email || "",
    source: guest.source,
    interestedPlan: guest.interestedPlan || "",
    assignedTo: guest.assignedTo || "",
    followUpDate: guest.followUpDate || "",
  })

  const plans = dataService.getPlans()

  const handleSave = () => {
    onSave({
      name: formData.name,
      phone: formData.phone,
      email: formData.email || undefined,
      source: formData.source,
      interestedPlan: formData.interestedPlan || undefined,
      assignedTo: formData.assignedTo || undefined,
      followUpDate: formData.followUpDate || undefined,
    })
  }

  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="max-w-2xl">
        <DialogHeader>
          <DialogTitle>Edit Guest Information</DialogTitle>
        </DialogHeader>

        <div className="space-y-4">
          <div className="grid gap-4 md:grid-cols-2">
            <div>
              <Label htmlFor="name">Full Name</Label>
              <Input
                id="name"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                className="mt-2"
              />
            </div>
            <div>
              <Label htmlFor="phone">Phone</Label>
              <Input
                id="phone"
                value={formData.phone}
                onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                className="mt-2"
              />
            </div>
            <div>
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                value={formData.email}
                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                className="mt-2"
              />
            </div>
            <div>
              <Label htmlFor="source">Source</Label>
              <Select
                value={formData.source}
                onValueChange={(value) => setFormData({ ...formData, source: value as Guest["source"] })}
              >
                <SelectTrigger className="mt-2">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="walk-in">Walk-in</SelectItem>
                  <SelectItem value="phone">Phone</SelectItem>
                  <SelectItem value="social-media">Social Media</SelectItem>
                  <SelectItem value="referral">Referral</SelectItem>
                  <SelectItem value="website">Website</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div>
              <Label htmlFor="interestedPlan">Interested Plan</Label>
              <Select
                value={formData.interestedPlan}
                onValueChange={(value) => setFormData({ ...formData, interestedPlan: value })}
              >
                <SelectTrigger className="mt-2">
                  <SelectValue placeholder="Select plan" />
                </SelectTrigger>
                <SelectContent>
                  {plans.map((plan) => (
                    <SelectItem key={plan.id} value={plan.id}>
                      {plan.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div>
              <Label htmlFor="assignedTo">Assigned To</Label>
              <Input
                id="assignedTo"
                value={formData.assignedTo}
                onChange={(e) => setFormData({ ...formData, assignedTo: e.target.value })}
                className="mt-2"
              />
            </div>
            <div className="md:col-span-2">
              <Label htmlFor="followUpDate">Follow-up Date</Label>
              <Input
                id="followUpDate"
                type="date"
                value={formData.followUpDate}
                onChange={(e) => setFormData({ ...formData, followUpDate: e.target.value })}
                className="mt-2"
              />
            </div>
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={onClose}>
            Cancel
          </Button>
          <Button onClick={handleSave}>Save Changes</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
