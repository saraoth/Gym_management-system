"use client"

import { useState } from "react"
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Label } from "@/components/ui/label"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { X } from "lucide-react"
import type { Trainer } from "@/lib/types"

interface AddTrainerDialogProps {
  onClose: () => void
  onAdd: (trainer: Trainer) => void
}

export function AddTrainerDialog({ onClose, onAdd }: AddTrainerDialogProps) {
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    phone: "",
    baseSalary: "",
    commissionRate: "",
    hireDate: "",
  })
  const [specializations, setSpecializations] = useState<string[]>([])
  const [newSpec, setNewSpec] = useState("")

  const handleAdd = () => {
    if (!formData.name || !formData.email || !formData.phone || !formData.baseSalary || !formData.commissionRate) {
      return
    }

    const newTrainer: Trainer = {
      id: Date.now().toString(),
      name: formData.name,
      email: formData.email,
      phone: formData.phone,
      specialization: specializations,
      hireDate: formData.hireDate || new Date().toISOString(),
      baseSalary: Number.parseFloat(formData.baseSalary),
      commissionRate: Number.parseFloat(formData.commissionRate),
      status: "active",
      totalSessions: 0,
      totalEarnings: 0,
    }

    onAdd(newTrainer)
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
          <DialogTitle>Add New Trainer</DialogTitle>
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
                <Label htmlFor="hireDate">Hire Date</Label>
                <Input
                  id="hireDate"
                  type="date"
                  value={formData.hireDate}
                  onChange={(e) => setFormData({ ...formData, hireDate: e.target.value })}
                  className="mt-2"
                />
              </div>
            </div>
          </div>

          <div className="space-y-4">
            <h3 className="font-semibold">Compensation</h3>
            <div className="grid gap-4 md:grid-cols-2">
              <div>
                <Label htmlFor="baseSalary">Base Salary (EGP) *</Label>
                <Input
                  id="baseSalary"
                  type="number"
                  value={formData.baseSalary}
                  onChange={(e) => setFormData({ ...formData, baseSalary: e.target.value })}
                  className="mt-2"
                  placeholder="5000"
                />
              </div>
              <div>
                <Label htmlFor="commissionRate">Commission Rate (%) *</Label>
                <Input
                  id="commissionRate"
                  type="number"
                  value={formData.commissionRate}
                  onChange={(e) => setFormData({ ...formData, commissionRate: e.target.value })}
                  className="mt-2"
                  placeholder="15"
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
                placeholder="e.g., Weight Training, Yoga, CrossFit"
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
          <Button
            onClick={handleAdd}
            disabled={
              !formData.name || !formData.email || !formData.phone || !formData.baseSalary || !formData.commissionRate
            }
          >
            Add Trainer
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
