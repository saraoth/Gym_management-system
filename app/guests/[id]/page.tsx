"use client"

import { useEffect, useState } from "react"
import { useParams, useRouter } from "next/navigation"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { ArrowLeft, Phone, Mail, Calendar, Edit, UserCheck, FileText } from "lucide-react"
import { dataService } from "@/lib/data"
import type { Guest, GuestHistory } from "@/lib/types"
import { UpdateGuestStatusDialog } from "@/components/update-guest-status-dialog"
import { AddGuestNoteDialog } from "@/components/add-guest-note-dialog"
import { EditGuestDialog } from "@/components/edit-guest-dialog"
import { ConvertToMemberDialog } from "@/components/convert-to-member-dialog"

export default function GuestDetailPage() {
  const params = useParams()
  const router = useRouter()
  const [guest, setGuest] = useState<Guest | null>(null)
  const [showStatusDialog, setShowStatusDialog] = useState(false)
  const [showNoteDialog, setShowNoteDialog] = useState(false)
  const [showEditDialog, setShowEditDialog] = useState(false)
  const [showConvertDialog, setShowConvertDialog] = useState(false)

  useEffect(() => {
    const guestId = params.id as string
    const guestData = dataService.getGuest(guestId)
    setGuest(guestData || null)
  }, [params.id])

  if (!guest) {
    return (
      <div className="flex h-full items-center justify-center">
        <p className="text-muted-foreground">Guest not found</p>
      </div>
    )
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case "new":
        return "bg-blue-500/10 text-blue-400 border-blue-500/20"
      case "contacted":
        return "bg-yellow-500/10 text-yellow-400 border-yellow-500/20"
      case "visited":
        return "bg-purple-500/10 text-purple-400 border-purple-500/20"
      case "converted":
        return "bg-success/10 text-success border-success/20"
      case "lost":
        return "bg-destructive/10 text-destructive border-destructive/20"
      default:
        return "bg-muted text-muted-foreground"
    }
  }

  const getSourceBadge = (source: string) => {
    const labels: Record<string, string> = {
      "walk-in": "Walk-in",
      phone: "Phone",
      "social-media": "Social Media",
      referral: "Referral",
      website: "Website",
    }
    return labels[source] || source
  }

  return (
    <div className="p-8">
      <Button variant="ghost" onClick={() => router.push("/guests")} className="mb-6">
        <ArrowLeft className="mr-2 h-4 w-4" />
        Back to Guests
      </Button>

      <div className="mb-6 flex items-start justify-between">
        <div className="flex gap-4">
          <div className="flex h-20 w-20 items-center justify-center rounded-full bg-primary/10 text-3xl font-semibold text-primary">
            {guest.name.charAt(0)}
          </div>
          <div>
            <div className="flex items-center gap-3">
              <h1 className="text-3xl font-bold">{guest.name}</h1>
              <Badge className={getStatusColor(guest.status)}>{guest.status}</Badge>
              <Badge variant="outline">{getSourceBadge(guest.source)}</Badge>
            </div>
            <p className="mt-2 text-muted-foreground">Lead ID: {guest.id}</p>
          </div>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" onClick={() => setShowEditDialog(true)}>
            <Edit className="mr-2 h-4 w-4" />
            Edit
          </Button>
          <Button onClick={() => setShowStatusDialog(true)}>
            <UserCheck className="mr-2 h-4 w-4" />
            Update Status
          </Button>
          {guest.status !== "converted" && (
            <Button onClick={() => setShowConvertDialog(true)} className="bg-success hover:bg-success/90">
              <UserCheck className="mr-2 h-4 w-4" />
              Convert to Member
            </Button>
          )}
        </div>
      </div>

      <Tabs defaultValue="details" className="space-y-6">
        <TabsList>
          <TabsTrigger value="details">Details</TabsTrigger>
          <TabsTrigger value="history">History</TabsTrigger>
          <TabsTrigger value="notes">Notes</TabsTrigger>
        </TabsList>

        <TabsContent value="details" className="space-y-6">
          <Card className="p-6">
            <h2 className="mb-4 text-lg font-semibold">Contact Information</h2>
            <div className="grid gap-4 md:grid-cols-2">
              <div className="flex items-start gap-3">
                <Phone className="mt-1 h-5 w-5 text-muted-foreground" />
                <div>
                  <p className="text-sm text-muted-foreground">Phone</p>
                  <p className="font-medium">{guest.phone}</p>
                </div>
              </div>
              {guest.email && (
                <div className="flex items-start gap-3">
                  <Mail className="mt-1 h-5 w-5 text-muted-foreground" />
                  <div>
                    <p className="text-sm text-muted-foreground">Email</p>
                    <p className="font-medium">{guest.email}</p>
                  </div>
                </div>
              )}
              <div className="flex items-start gap-3">
                <Calendar className="mt-1 h-5 w-5 text-muted-foreground" />
                <div>
                  <p className="text-sm text-muted-foreground">Created</p>
                  <p className="font-medium">{new Date(guest.createdAt).toLocaleString()}</p>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <Calendar className="mt-1 h-5 w-5 text-muted-foreground" />
                <div>
                  <p className="text-sm text-muted-foreground">Last Updated</p>
                  <p className="font-medium">{new Date(guest.updatedAt).toLocaleString()}</p>
                </div>
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <h2 className="mb-4 text-lg font-semibold">Lead Information</h2>
            <div className="grid gap-4 md:grid-cols-2">
              <div>
                <p className="text-sm text-muted-foreground">Source</p>
                <p className="mt-1 font-medium">{getSourceBadge(guest.source)}</p>
              </div>
              {guest.interestedPlan && (
                <div>
                  <p className="text-sm text-muted-foreground">Interested Plan</p>
                  <p className="mt-1 font-medium">{dataService.getPlan(guest.interestedPlan)?.name}</p>
                </div>
              )}
              {guest.assignedTo && (
                <div>
                  <p className="text-sm text-muted-foreground">Assigned To</p>
                  <p className="mt-1 font-medium">{guest.assignedTo}</p>
                </div>
              )}
              {guest.followUpDate && (
                <div>
                  <p className="text-sm text-muted-foreground">Follow-up Date</p>
                  <p className="mt-1 font-medium">{new Date(guest.followUpDate).toLocaleDateString()}</p>
                </div>
              )}
            </div>
          </Card>

          {guest.notes && (
            <Card className="p-6">
              <h2 className="mb-4 text-lg font-semibold">Current Notes</h2>
              <div className="rounded-lg border border-border bg-muted/50 p-4">
                <p className="text-sm">{guest.notes}</p>
              </div>
            </Card>
          )}
        </TabsContent>

        <TabsContent value="history" className="space-y-6">
          <Card className="p-6">
            <h2 className="mb-4 text-lg font-semibold">Activity History</h2>
            <div className="space-y-4">
              {guest.history.length > 0 ? (
                guest.history.map((item) => (
                  <div key={item.id} className="flex items-start gap-4 rounded-lg border border-border p-4">
                    <div className="rounded-full bg-primary/10 p-2">
                      <FileText className="h-4 w-4 text-primary" />
                    </div>
                    <div className="flex-1">
                      <p className="font-medium">{item.action}</p>
                      {item.notes && <p className="mt-1 text-sm text-muted-foreground">{item.notes}</p>}
                      <p className="mt-1 text-xs text-muted-foreground">
                        {new Date(item.date).toLocaleString()} by {item.performedBy}
                      </p>
                    </div>
                  </div>
                ))
              ) : (
                <p className="text-sm text-muted-foreground">No activity history yet</p>
              )}
            </div>
          </Card>
        </TabsContent>

        <TabsContent value="notes" className="space-y-6">
          <Card className="p-6">
            <div className="mb-4 flex items-center justify-between">
              <h2 className="text-lg font-semibold">Notes</h2>
              <Button onClick={() => setShowNoteDialog(true)}>
                <FileText className="mr-2 h-4 w-4" />
                Add Note
              </Button>
            </div>
            {guest.notes ? (
              <div className="rounded-lg border border-border bg-muted/50 p-4">
                <p className="text-sm">{guest.notes}</p>
              </div>
            ) : (
              <p className="text-sm text-muted-foreground">No notes yet</p>
            )}
          </Card>
        </TabsContent>
      </Tabs>

      {showStatusDialog && (
        <UpdateGuestStatusDialog
          guest={guest}
          onClose={() => setShowStatusDialog(false)}
          onUpdate={(status, notes) => {
            const historyEntry: GuestHistory = {
              id: Date.now().toString(),
              date: new Date().toISOString(),
              action: `Status changed to ${status}`,
              notes: notes || "",
              performedBy: "Admin User",
            }

            const updatedGuest = dataService.updateGuest(guest.id, {
              status,
              updatedAt: new Date().toISOString(),
              history: [...guest.history, historyEntry],
            })

            if (updatedGuest) {
              setGuest(updatedGuest)
            }
            setShowStatusDialog(false)
          }}
        />
      )}

      {showNoteDialog && (
        <AddGuestNoteDialog
          onClose={() => setShowNoteDialog(false)}
          onAdd={(note) => {
            const historyEntry: GuestHistory = {
              id: Date.now().toString(),
              date: new Date().toISOString(),
              action: "Note added",
              notes: note,
              performedBy: "Admin User",
            }

            const updatedGuest = dataService.updateGuest(guest.id, {
              notes: note,
              updatedAt: new Date().toISOString(),
              history: [...guest.history, historyEntry],
            })

            if (updatedGuest) {
              setGuest(updatedGuest)
            }
            setShowNoteDialog(false)
          }}
        />
      )}

      {showEditDialog && (
        <EditGuestDialog
          guest={guest}
          onClose={() => setShowEditDialog(false)}
          onSave={(updates) => {
            const updatedGuest = dataService.updateGuest(guest.id, {
              ...updates,
              updatedAt: new Date().toISOString(),
            })
            if (updatedGuest) {
              setGuest(updatedGuest)
            }
            setShowEditDialog(false)
          }}
        />
      )}

      {showConvertDialog && (
        <ConvertToMemberDialog
          guest={guest}
          onClose={() => setShowConvertDialog(false)}
          onConvert={() => {
            const updatedGuest = dataService.updateGuest(guest.id, {
              status: "converted",
              updatedAt: new Date().toISOString(),
            })
            if (updatedGuest) {
              setGuest(updatedGuest)
            }
            setShowConvertDialog(false)
            router.push("/members")
          }}
        />
      )}
    </div>
  )
}
