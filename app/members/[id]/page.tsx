"use client"

import { useEffect, useState } from "react"
import { useParams, useRouter } from "next/navigation"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import {
  ArrowLeft,
  Mail,
  Phone,
  MapPin,
  Calendar,
  User,
  Edit,
  Trash2,
  RefreshCw,
  FileText,
  DollarSign,
  Activity,
} from "lucide-react"
import { dataService } from "@/lib/data"
import type { Member, MemberHistory } from "@/lib/types"
import { MembershipSwapDialog } from "@/components/membership-swap-dialog"
import { AddNoteDialog } from "@/components/add-note-dialog"
import { EditMemberDialog } from "@/components/edit-member-dialog"

export default function MemberDetailPage() {
  const params = useParams()
  const router = useRouter()
  const [member, setMember] = useState<Member | null>(null)
  const [showSwapDialog, setShowSwapDialog] = useState(false)
  const [showNoteDialog, setShowNoteDialog] = useState(false)
  const [showEditDialog, setShowEditDialog] = useState(false)

  useEffect(() => {
    const memberId = params.id as string
    const memberData = dataService.getMember(memberId)
    setMember(memberData || null)
  }, [params.id])

  if (!member) {
    return (
      <div className="flex h-full items-center justify-center">
        <p className="text-muted-foreground">Member not found</p>
      </div>
    )
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case "active":
        return "bg-success/10 text-success border-success/20"
      case "expired":
        return "bg-destructive/10 text-destructive border-destructive/20"
      case "frozen":
        return "bg-warning/10 text-warning border-warning/20"
      default:
        return "bg-muted text-muted-foreground"
    }
  }

  const getPlanName = (planId: string) => {
    const plan = dataService.getPlan(planId)
    return plan?.name || planId
  }

  const getHistoryIcon = (type: string) => {
    switch (type) {
      case "membership_change":
        return RefreshCw
      case "payment":
        return DollarSign
      case "attendance":
      case "class":
      case "pt_session":
        return Activity
      case "note":
        return FileText
      default:
        return FileText
    }
  }

  const getHistoryColor = (type: string) => {
    switch (type) {
      case "membership_change":
        return "text-primary"
      case "payment":
        return "text-success"
      case "attendance":
      case "class":
      case "pt_session":
        return "text-blue-400"
      case "note":
        return "text-muted-foreground"
      default:
        return "text-muted-foreground"
    }
  }

  return (
    <div className="p-8">
      <Button variant="ghost" onClick={() => router.push("/members")} className="mb-6">
        <ArrowLeft className="mr-2 h-4 w-4" />
        Back to Members
      </Button>

      <div className="mb-6 flex items-start justify-between">
        <div className="flex gap-4">
          <div className="flex h-20 w-20 items-center justify-center rounded-full bg-primary/10 text-3xl font-semibold text-primary">
            {member.name.charAt(0)}
          </div>
          <div>
            <div className="flex items-center gap-3">
              <h1 className="text-3xl font-bold">{member.name}</h1>
              <Badge className={getStatusColor(member.status)}>{member.status}</Badge>
            </div>
            <p className="mt-2 text-muted-foreground">Member ID: {member.id}</p>
          </div>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" onClick={() => setShowEditDialog(true)}>
            <Edit className="mr-2 h-4 w-4" />
            Edit
          </Button>
          <Button variant="outline" onClick={() => setShowSwapDialog(true)}>
            <RefreshCw className="mr-2 h-4 w-4" />
            Change Plan
          </Button>
          <Button variant="outline" className="text-destructive hover:bg-destructive/10 bg-transparent">
            <Trash2 className="mr-2 h-4 w-4" />
            Delete
          </Button>
        </div>
      </div>

      <Tabs defaultValue="details" className="space-y-6">
        <TabsList>
          <TabsTrigger value="details">Details</TabsTrigger>
          <TabsTrigger value="membership">Membership</TabsTrigger>
          <TabsTrigger value="history">History</TabsTrigger>
          <TabsTrigger value="notes">Notes</TabsTrigger>
        </TabsList>

        <TabsContent value="details" className="space-y-6">
          <Card className="p-6">
            <h2 className="mb-4 text-lg font-semibold">Personal Information</h2>
            <div className="grid gap-4 md:grid-cols-2">
              <div className="flex items-start gap-3">
                <Mail className="mt-1 h-5 w-5 text-muted-foreground" />
                <div>
                  <p className="text-sm text-muted-foreground">Email</p>
                  <p className="font-medium">{member.email}</p>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <Phone className="mt-1 h-5 w-5 text-muted-foreground" />
                <div>
                  <p className="text-sm text-muted-foreground">Phone</p>
                  <p className="font-medium">{member.phone}</p>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <MapPin className="mt-1 h-5 w-5 text-muted-foreground" />
                <div>
                  <p className="text-sm text-muted-foreground">Address</p>
                  <p className="font-medium">{member.address}</p>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <Calendar className="mt-1 h-5 w-5 text-muted-foreground" />
                <div>
                  <p className="text-sm text-muted-foreground">Date of Birth</p>
                  <p className="font-medium">{new Date(member.dateOfBirth).toLocaleDateString()}</p>
                </div>
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <h2 className="mb-4 text-lg font-semibold">Emergency Contact</h2>
            <div className="grid gap-4 md:grid-cols-2">
              <div className="flex items-start gap-3">
                <User className="mt-1 h-5 w-5 text-muted-foreground" />
                <div>
                  <p className="text-sm text-muted-foreground">Name</p>
                  <p className="font-medium">{member.emergencyContact.name}</p>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <Phone className="mt-1 h-5 w-5 text-muted-foreground" />
                <div>
                  <p className="text-sm text-muted-foreground">Phone</p>
                  <p className="font-medium">{member.emergencyContact.phone}</p>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <User className="mt-1 h-5 w-5 text-muted-foreground" />
                <div>
                  <p className="text-sm text-muted-foreground">Relationship</p>
                  <p className="font-medium">{member.emergencyContact.relationship}</p>
                </div>
              </div>
            </div>
          </Card>
        </TabsContent>

        <TabsContent value="membership" className="space-y-6">
          <Card className="p-6">
            <div className="mb-4 flex items-center justify-between">
              <h2 className="text-lg font-semibold">Current Membership</h2>
              <Button onClick={() => setShowSwapDialog(true)}>
                <RefreshCw className="mr-2 h-4 w-4" />
                Change Plan
              </Button>
            </div>
            <div className="grid gap-6 md:grid-cols-3">
              <div>
                <p className="text-sm text-muted-foreground">Plan</p>
                <p className="mt-1 text-lg font-semibold">{getPlanName(member.membershipPlan)}</p>
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Start Date</p>
                <p className="mt-1 text-lg font-semibold">
                  {new Date(member.membershipStartDate).toLocaleDateString()}
                </p>
              </div>
              <div>
                <p className="text-sm text-muted-foreground">End Date</p>
                <p className="mt-1 text-lg font-semibold">{new Date(member.membershipEndDate).toLocaleDateString()}</p>
              </div>
            </div>
            <div className="mt-6">
              <p className="text-sm text-muted-foreground">Plan Benefits</p>
              <ul className="mt-2 space-y-1">
                {dataService.getPlan(member.membershipPlan)?.benefits.map((benefit, index) => (
                  <li key={index} className="flex items-center gap-2 text-sm">
                    <div className="h-1.5 w-1.5 rounded-full bg-primary" />
                    {benefit}
                  </li>
                ))}
              </ul>
            </div>
          </Card>

          <Card className="p-6">
            <h2 className="mb-4 text-lg font-semibold">Membership Changes</h2>
            <div className="space-y-4">
              {member.history
                .filter((h) => h.type === "membership_change")
                .map((change) => (
                  <div key={change.id} className="flex items-start gap-4 rounded-lg border border-border p-4">
                    <div className="rounded-full bg-primary/10 p-2">
                      <RefreshCw className="h-4 w-4 text-primary" />
                    </div>
                    <div className="flex-1">
                      <p className="font-medium">{change.description}</p>
                      {change.previousPlan && change.newPlan && (
                        <p className="mt-1 text-sm text-muted-foreground">
                          {getPlanName(change.previousPlan)} → {getPlanName(change.newPlan)}
                        </p>
                      )}
                      <p className="mt-1 text-xs text-muted-foreground">{new Date(change.date).toLocaleString()}</p>
                    </div>
                  </div>
                ))}
              {member.history.filter((h) => h.type === "membership_change").length === 0 && (
                <p className="text-sm text-muted-foreground">No membership changes yet</p>
              )}
            </div>
          </Card>
        </TabsContent>

        <TabsContent value="history" className="space-y-6">
          <Card className="p-6">
            <h2 className="mb-4 text-lg font-semibold">Activity History</h2>
            <div className="space-y-4">
              {member.history.length > 0 ? (
                member.history.map((item) => {
                  const Icon = getHistoryIcon(item.type)
                  return (
                    <div key={item.id} className="flex items-start gap-4 rounded-lg border border-border p-4">
                      <div className={`rounded-full bg-muted p-2 ${getHistoryColor(item.type)}`}>
                        <Icon className="h-4 w-4" />
                      </div>
                      <div className="flex-1">
                        <p className="font-medium">{item.description}</p>
                        {item.amount && (
                          <p className="mt-1 text-sm text-muted-foreground">{item.amount.toLocaleString()} EGP</p>
                        )}
                        <p className="mt-1 text-xs text-muted-foreground">{new Date(item.date).toLocaleString()}</p>
                      </div>
                    </div>
                  )
                })
              ) : (
                <p className="text-sm text-muted-foreground">No activity history yet</p>
              )}
            </div>
          </Card>
        </TabsContent>

        <TabsContent value="notes" className="space-y-6">
          <Card className="p-6">
            <div className="mb-4 flex items-center justify-between">
              <h2 className="text-lg font-semibold">Member Notes</h2>
              <Button onClick={() => setShowNoteDialog(true)}>
                <FileText className="mr-2 h-4 w-4" />
                Add Note
              </Button>
            </div>
            {member.notes ? (
              <div className="rounded-lg border border-border bg-muted/50 p-4">
                <p className="text-sm">{member.notes}</p>
              </div>
            ) : (
              <p className="text-sm text-muted-foreground">No notes yet</p>
            )}
          </Card>

          <Card className="p-6">
            <h2 className="mb-4 text-lg font-semibold">Note History</h2>
            <div className="space-y-4">
              {member.history
                .filter((h) => h.type === "note")
                .map((note) => (
                  <div key={note.id} className="flex items-start gap-4 rounded-lg border border-border p-4">
                    <div className="rounded-full bg-muted p-2">
                      <FileText className="h-4 w-4 text-muted-foreground" />
                    </div>
                    <div className="flex-1">
                      <p className="text-sm">{note.description}</p>
                      <p className="mt-1 text-xs text-muted-foreground">{new Date(note.date).toLocaleString()}</p>
                    </div>
                  </div>
                ))}
              {member.history.filter((h) => h.type === "note").length === 0 && (
                <p className="text-sm text-muted-foreground">No note history yet</p>
              )}
            </div>
          </Card>
        </TabsContent>
      </Tabs>

      {showSwapDialog && (
        <MembershipSwapDialog
          member={member}
          onClose={() => setShowSwapDialog(false)}
          onSwap={(newPlanId, reason) => {
            const oldPlan = member.membershipPlan
            const newPlan = dataService.getPlan(newPlanId)
            if (newPlan) {
              const endDate = new Date()
              endDate.setMonth(endDate.getMonth() + newPlan.duration)

              const historyEntry: MemberHistory = {
                id: Date.now().toString(),
                type: "membership_change",
                date: new Date().toISOString(),
                description: reason || "Membership plan changed",
                previousPlan: oldPlan,
                newPlan: newPlanId,
              }

              const updatedMember = dataService.updateMember(member.id, {
                membershipPlan: newPlanId,
                membershipStartDate: new Date().toISOString(),
                membershipEndDate: endDate.toISOString(),
                history: [...member.history, historyEntry],
              })

              if (updatedMember) {
                setMember(updatedMember)
              }
            }
            setShowSwapDialog(false)
          }}
        />
      )}

      {showNoteDialog && (
        <AddNoteDialog
          onClose={() => setShowNoteDialog(false)}
          onAdd={(note) => {
            const historyEntry: MemberHistory = {
              id: Date.now().toString(),
              type: "note",
              date: new Date().toISOString(),
              description: note,
            }

            const updatedMember = dataService.updateMember(member.id, {
              notes: note,
              history: [...member.history, historyEntry],
            })

            if (updatedMember) {
              setMember(updatedMember)
            }
            setShowNoteDialog(false)
          }}
        />
      )}

      {showEditDialog && (
        <EditMemberDialog
          member={member}
          onClose={() => setShowEditDialog(false)}
          onSave={(updates) => {
            const updatedMember = dataService.updateMember(member.id, updates)
            if (updatedMember) {
              setMember(updatedMember)
            }
            setShowEditDialog(false)
          }}
        />
      )}
    </div>
  )
}
