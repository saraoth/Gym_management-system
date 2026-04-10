"use client"

import { useState } from "react"
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Label } from "@/components/ui/label"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Badge } from "@/components/ui/badge"
import { X } from "lucide-react"
import type { Trainer } from "@/lib/types"

interface EditTrainerDialogProps {
  trainer: Trainer
  onClose: () => void
  onSave: (updates: Partial<Trainer>) => void
}

export function EditTrainerDialog({ trainer, onClose, onSave }: EditTrainerDialogProps) {
  const [formData, setFormData] = useState({
    name: trainer.name,
    email: trainer.email,
    phone: trainer.phone,
    baseSalary: trainer.baseSalary.toString(),
    commissionRate: trainer.commissionRate.toString(),
    status: trainer.status,
  })
  const [specializations, setSpecializations] = useState<string[]>(trainer.specialization)
  const [newSpec, setNewSpec] = useState("")

  const handleSave = () => {
    onSave({
      name: formData.name,
      email: formData.email,
      phone: formData.phone,
      baseSalary: Number.parseFloat(formData.baseSalary),
      commissionRate: Number.parseFloat(formData.commissionRate),
      status: formData.status,
      specialization: specializations,
    })
  }

  const addSpecialization = () => {
    if (newSpec.trim() && !specializations.includes(newSpec.trim())) {
      setSpecializations([...specializations, newSpec.trim()])
      setNewSpec("")
    }
  }

  const removeSpecialization = (spec: string) => {
    setSpecializations(specializations.filter((s) => s !== spec))
  }

  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>Edit Trainer Information</DialogTitle>
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
                <Label htmlFor="status">Status</Label>
                <Select
                  value={formData.status}
                  onValueChange={(value) => setFormData({ ...formData, status: value as Trainer["status"] })}
                >
                  <SelectTrigger className="mt-2">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="active">Active</SelectItem>
                    <SelectItem value="inactive">Inactive</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>
          </div>

          <div className="space-y-4">
            <h3 className="font-semibold">Compensation</h3>
            <div className="grid gap-4 md:grid-cols-2">
              <div>
                <Label htmlFor="baseSalary">Base Salary (EGP)</Label>
                <Input
                  id="baseSalary"
                  type="number"
                  value={formData.baseSalary}
                  onChange={(e) => setFormData({ ...formData, baseSalary: e.target.value })}
                  className="mt-2"
                />
              </div>
              <div>
                <Label htmlFor="commissionRate">Commission Rate (%)</Label>
                <Input
                  id="commissionRate"
                  type="number"
                  value={formData.commissionRate}
                  onChange={(e) => setFormData({ ...formData, commissionRate: e.target.value })}
                  className="mt-2"
                />
              </div>
            </div>
          </div>

          <div className="space-y-4">
            <h3 className="font-semibold">Specialization</h3>
            <div className="flex gap-2">
              <Input
                value={newSpec}
                onChange={(e) => setNewSpec(e.target.value)}
                placeholder="Add specialization"
                onKeyPress={(e) => e.key === "Enter" && addSpecialization()}
              />
              <Button type="button" onClick={addSpecialization}>
                Add
              </Button>
            </div>
            {specializations.length > 0 && (
              <div className="flex flex-wrap gap-2">
                {specializations.map((spec) => (
                  <Badge key={spec} variant="outline" className="gap-1">
                    {spec}
                    <button onClick={() => removeSpecialization(spec)} className="ml-1">
                      <X className="h-3 w-3" />
                    </button>
                  </Badge>
                ))}
              </div>
            )}
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
