"use client"

import { useState } from "react"
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Label } from "@/components/ui/label"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { dataService } from "@/lib/data"
import type { Member } from "@/lib/types"

interface AddMemberDialogProps {
  onClose: () => void
  onAdd: (member: Member) => void
}

export function AddMemberDialog({ onClose, onAdd }: AddMemberDialogProps) {
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    phone: "",
    address: "",
    dateOfBirth: "",
    emergencyContactName: "",
    emergencyContactPhone: "",
    emergencyContactRelationship: "",
    membershipPlan: "",
  })

  const plans = dataService.getPlans()

  const handleAdd = () => {
    if (!formData.name || !formData.email || !formData.phone || !formData.membershipPlan) {
      return
    }

    const plan = dataService.getPlan(formData.membershipPlan)
    if (!plan) return

    const startDate = new Date()
    const endDate = new Date()
    endDate.setMonth(endDate.getMonth() + plan.duration)

    const newMember: Member = {
      id: Date.now().toString(),
      name: formData.name,
      email: formData.email,
      phone: formData.phone,
      address: formData.address,
      dateOfBirth: formData.dateOfBirth,
      emergencyContact: {
        name: formData.emergencyContactName,
        phone: formData.emergencyContactPhone,
        relationship: formData.emergencyContactRelationship,
      },
      membershipPlan: formData.membershipPlan,
      membershipStartDate: startDate.toISOString(),
      membershipEndDate: endDate.toISOString(),
      status: "active",
      notes: "",
      joinDate: startDate.toISOString(),
      history: [],
    }

    onAdd(newMember)
  }

  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>Add New Member</DialogTitle>
        </DialogHeader>

        <div className="space-y-6">
          <div className="space-y-4">
            <h3 className="font-semibold">Personal Information</h3>
            <div className="grid gap-4 md:grid-cols-2">
              <div>
                <Label htmlFor="name">Full Name *</Label>
                <Input
                  id="name"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  className="mt-2"
                />
              </div>
              <div>
                <Label htmlFor="email">Email *</Label>
                <Input
                  id="email"
                  type="email"
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  className="mt-2"
                />
              </div>
              <div>
                <Label htmlFor="phone">Phone *</Label>
                <Input
                  id="phone"
                  value={formData.phone}
                  onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                  className="mt-2"
                />
              </div>
              <div>
                <Label htmlFor="dateOfBirth">Date of Birth</Label>
                <Input
                  id="dateOfBirth"
                  type="date"
                  value={formData.dateOfBirth}
                  onChange={(e) => setFormData({ ...formData, dateOfBirth: e.target.value })}
                  className="mt-2"
                />
              </div>
              <div className="md:col-span-2">
                <Label htmlFor="address">Address</Label>
                <Input
                  id="address"
                  value={formData.address}
                  onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                  className="mt-2"
                />
              </div>
            </div>
          </div>

          <div className="space-y-4">
            <h3 className="font-semibold">Emergency Contact</h3>
            <div className="grid gap-4 md:grid-cols-2">
              <div>
                <Label htmlFor="emergencyContactName">Name</Label>
                <Input
                  id="emergencyContactName"
                  value={formData.emergencyContactName}
                  onChange={(e) => setFormData({ ...formData, emergencyContactName: e.target.value })}
                  className="mt-2"
                />
              </div>
              <div>
                <Label htmlFor="emergencyContactPhone">Phone</Label>
                <Input
                  id="emergencyContactPhone"
                  value={formData.emergencyContactPhone}
                  onChange={(e) => setFormData({ ...formData, emergencyContactPhone: e.target.value })}
                  className="mt-2"
                />
              </div>
              <div>
                <Label htmlFor="emergencyContactRelationship">Relationship</Label>
                <Input
                  id="emergencyContactRelationship"
                  value={formData.emergencyContactRelationship}
                  onChange={(e) => setFormData({ ...formData, emergencyContactRelationship: e.target.value })}
                  className="mt-2"
                />
              </div>
            </div>
          </div>

          <div className="space-y-4">
            <h3 className="font-semibold">Membership Plan *</h3>
            <Select
              value={formData.membershipPlan}
              onValueChange={(value) => setFormData({ ...formData, membershipPlan: value })}
            >
              <SelectTrigger>
                <SelectValue placeholder="Select a membership plan" />
              </SelectTrigger>
              <SelectContent>
                {plans.map((plan) => (
                  <SelectItem key={plan.id} value={plan.id}>
                    {plan.name} - {plan.price.toLocaleString()} EGP
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={onClose}>
            Cancel
          </Button>
          <Button
            onClick={handleAdd}
            disabled={!formData.name || !formData.email || !formData.phone || !formData.membershipPlan}
          >
            Add Member
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
