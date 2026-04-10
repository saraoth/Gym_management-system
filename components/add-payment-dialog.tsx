"use client"

import { useState } from "react"
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Label } from "@/components/ui/label"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { dataService } from "@/lib/data"
import type { Payment } from "@/lib/types"

interface AddPaymentDialogProps {
  onClose: () => void
  onAdd: (payment: Payment) => void
}

export function AddPaymentDialog({ onClose, onAdd }: AddPaymentDialogProps) {
  const [formData, setFormData] = useState({
    memberId: "",
    amount: "",
    type: "",
    method: "",
    notes: "",
  })

  const members = dataService.getMembers()

  const handleAdd = () => {
    if (!formData.memberId || !formData.amount || !formData.type || !formData.method) {
      return
    }

    const member = dataService.getMember(formData.memberId)
    if (!member) return

    const newPayment: Payment = {
      id: Date.now().toString(),
      memberId: formData.memberId,
      memberName: member.name,
      amount: Number.parseFloat(formData.amount),
      type: formData.type as Payment["type"],
      method: formData.method as Payment["method"],
      status: "completed",
      date: new Date().toISOString(),
      notes: formData.notes || undefined,
      planId: member.membershipPlan,
    }

    onAdd(newPayment)
  }

  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="max-w-2xl">
        <DialogHeader>
          <DialogTitle>Record Payment</DialogTitle>
        </DialogHeader>

        <div className="space-y-6">
          <div className="grid gap-4 md:grid-cols-2">
            <div>
              <Label htmlFor="memberId">Member *</Label>
              <Select
                value={formData.memberId}
                onValueChange={(value) => setFormData({ ...formData, memberId: value })}
              >
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
              <Label htmlFor="amount">Amount (EGP) *</Label>
              <Input
                id="amount"
                type="number"
                value={formData.amount}
                onChange={(e) => setFormData({ ...formData, amount: e.target.value })}
                className="mt-2"
                placeholder="1000"
              />
            </div>
            <div>
              <Label htmlFor="type">Payment Type *</Label>
              <Select value={formData.type} onValueChange={(value) => setFormData({ ...formData, type: value })}>
                <SelectTrigger className="mt-2">
                  <SelectValue placeholder="Select type" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="membership">Membership</SelectItem>
                  <SelectItem value="pt-session">PT Session</SelectItem>
                  <SelectItem value="class">Class</SelectItem>
                  <SelectItem value="product">Product</SelectItem>
                  <SelectItem value="other">Other</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div>
              <Label htmlFor="method">Payment Method *</Label>
              <Select value={formData.method} onValueChange={(value) => setFormData({ ...formData, method: value })}>
                <SelectTrigger className="mt-2">
                  <SelectValue placeholder="Select method" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="cash">Cash</SelectItem>
                  <SelectItem value="card">Card</SelectItem>
                  <SelectItem value="bank-transfer">Bank Transfer</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div className="md:col-span-2">
              <Label htmlFor="notes">Notes (Optional)</Label>
              <Textarea
                id="notes"
                value={formData.notes}
                onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
                className="mt-2"
                rows={3}
                placeholder="Any additional information..."
              />
            </div>
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={onClose}>
            Cancel
          </Button>
          <Button
            onClick={handleAdd}
            disabled={!formData.memberId || !formData.amount || !formData.type || !formData.method}
          >
            Record Payment
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
