"use client"

import { useState } from "react"
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Label } from "@/components/ui/label"
import { Input } from "@/components/ui/input"
import type { Member } from "@/lib/types"

interface EditMemberDialogProps {
  member: Member
  onClose: () => void
  onSave: (updates: Partial<Member>) => void
}

export function EditMemberDialog({ member, onClose, onSave }: EditMemberDialogProps) {
  const [formData, setFormData] = useState({
    name: member.name,
    email: member.email,
    phone: member.phone,
    address: member.address,
    dateOfBirth: member.dateOfBirth,
    emergencyContactName: member.emergencyContact.name,
    emergencyContactPhone: member.emergencyContact.phone,
    emergencyContactRelationship: member.emergencyContact.relationship,
  })

  const handleSave = () => {
    onSave({
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
    })
  }

  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>Edit Member Information</DialogTitle>
        </DialogHeader>

        <div className="space-y-6">
          <div className="space-y-4">
            <h3 className="font-semibold">Personal Information</h3>
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
                <Label htmlFor="phone">Phone</Label>
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
