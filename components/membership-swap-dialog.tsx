"use client"

import { useState } from "react"
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group"
import { dataService } from "@/lib/data"
import type { Member } from "@/lib/types"
import { Badge } from "@/components/ui/badge"

interface MembershipSwapDialogProps {
  member: Member
  onClose: () => void
  onSwap: (newPlanId: string, reason: string) => void
}

export function MembershipSwapDialog({ member, onClose, onSwap }: MembershipSwapDialogProps) {
  const [selectedPlan, setSelectedPlan] = useState("")
  const [reason, setReason] = useState("")
  const plans = dataService.getPlans()
  const currentPlan = dataService.getPlan(member.membershipPlan)

  const handleSwap = () => {
    if (selectedPlan && selectedPlan !== member.membershipPlan) {
      onSwap(selectedPlan, reason)
    }
  }

  const getChangeType = (newPlanId: string) => {
    const newPlan = dataService.getPlan(newPlanId)
    if (!currentPlan || !newPlan) return "change"

    if (newPlan.price > currentPlan.price) return "upgrade"
    if (newPlan.price < currentPlan.price) return "downgrade"
    return "swap"
  }

  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="max-w-2xl">
        <DialogHeader>
          <DialogTitle>Change Membership Plan</DialogTitle>
        </DialogHeader>

        <div className="space-y-6">
          <div className="rounded-lg border border-border bg-muted/50 p-4">
            <p className="text-sm text-muted-foreground">Current Plan</p>
            <p className="mt-1 text-lg font-semibold">{currentPlan?.name}</p>
            <p className="text-sm text-muted-foreground">{currentPlan?.price.toLocaleString()} EGP</p>
          </div>

          <div>
            <Label>Select New Plan</Label>
            <RadioGroup value={selectedPlan} onValueChange={setSelectedPlan} className="mt-3 space-y-3">
              {plans.map((plan) => {
                const changeType = getChangeType(plan.id)
                const isCurrentPlan = plan.id === member.membershipPlan

                return (
                  <div
                    key={plan.id}
                    className={`flex items-start gap-3 rounded-lg border p-4 ${
                      selectedPlan === plan.id ? "border-primary bg-primary/5" : "border-border"
                    } ${isCurrentPlan ? "opacity-50" : ""}`}
                  >
                    <RadioGroupItem value={plan.id} id={plan.id} disabled={isCurrentPlan} className="mt-1" />
                    <div className="flex-1">
                      <div className="flex items-center gap-2">
                        <Label htmlFor={plan.id} className="cursor-pointer font-semibold">
                          {plan.name}
                        </Label>
                        {!isCurrentPlan && changeType === "upgrade" && (
                          <Badge className="bg-success/10 text-success">Upgrade</Badge>
                        )}
                        {!isCurrentPlan && changeType === "downgrade" && (
                          <Badge className="bg-warning/10 text-warning">Downgrade</Badge>
                        )}
                        {isCurrentPlan && <Badge variant="outline">Current</Badge>}
                      </div>
                      <p className="mt-1 text-sm font-medium">{plan.price.toLocaleString()} EGP</p>
                      <ul className="mt-2 space-y-1">
                        {plan.benefits.slice(0, 3).map((benefit, index) => (
                          <li key={index} className="flex items-center gap-2 text-xs text-muted-foreground">
                            <div className="h-1 w-1 rounded-full bg-primary" />
                            {benefit}
                          </li>
                        ))}
                      </ul>
                    </div>
                  </div>
                )
              })}
            </RadioGroup>
          </div>

          <div>
            <Label htmlFor="reason">Reason for Change (Optional)</Label>
            <Textarea
              id="reason"
              placeholder="Enter reason for membership change..."
              value={reason}
              onChange={(e) => setReason(e.target.value)}
              className="mt-2"
              rows={3}
            />
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={onClose}>
            Cancel
          </Button>
          <Button onClick={handleSwap} disabled={!selectedPlan || selectedPlan === member.membershipPlan}>
            Confirm Change
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
