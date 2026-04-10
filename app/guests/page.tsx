"use client"

import { useEffect, useState } from "react"
import { useRouter } from "next/navigation"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Search, Plus, Phone, Mail, Calendar, Eye } from "lucide-react"
import { dataService } from "@/lib/data"
import type { Guest } from "@/lib/types"
import { AddGuestDialog } from "@/components/add-guest-dialog"

export default function GuestsPage() {
  const router = useRouter()
  const [guests, setGuests] = useState<Guest[]>([])
  const [searchQuery, setSearchQuery] = useState("")
  const [filteredGuests, setFilteredGuests] = useState<Guest[]>([])
  const [showAddDialog, setShowAddDialog] = useState(false)
  const [activeTab, setActiveTab] = useState("all")

  useEffect(() => {
    const allGuests = dataService.getGuests()
    setGuests(allGuests)
    setFilteredGuests(allGuests)
  }, [])

  useEffect(() => {
    let filtered = guests

    if (activeTab !== "all") {
      filtered = filtered.filter((g) => g.status === activeTab)
    }

    if (searchQuery) {
      const q = searchQuery.toLowerCase()
      filtered = filtered.filter(
        (g) => g.name.toLowerCase().includes(q) || g.phone.includes(q) || g.email?.toLowerCase().includes(q),
      )
    }

    setFilteredGuests(filtered)
  }, [searchQuery, guests, activeTab])

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

  const statusCounts = {
    all: guests.length,
    new: guests.filter((g) => g.status === "new").length,
    contacted: guests.filter((g) => g.status === "contacted").length,
    visited: guests.filter((g) => g.status === "visited").length,
    converted: guests.filter((g) => g.status === "converted").length,
    lost: guests.filter((g) => g.status === "lost").length,
  }

  return (
    <div className="p-8">
      <div className="mb-8 flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Guests & Sales</h1>
          <p className="mt-2 text-muted-foreground">Track prospective members and manage your sales pipeline</p>
        </div>
        <Button onClick={() => setShowAddDialog(true)}>
          <Plus className="mr-2 h-4 w-4" />
          Add Guest
        </Button>
      </div>

      <div className="mb-6 grid gap-4 md:grid-cols-5">
        <Card className="p-4">
          <p className="text-sm text-muted-foreground">Total Leads</p>
          <p className="mt-2 text-2xl font-bold">{statusCounts.all}</p>
        </Card>
        <Card className="p-4">
          <p className="text-sm text-muted-foreground">New</p>
          <p className="mt-2 text-2xl font-bold text-blue-400">{statusCounts.new}</p>
        </Card>
        <Card className="p-4">
          <p className="text-sm text-muted-foreground">Contacted</p>
          <p className="mt-2 text-2xl font-bold text-yellow-400">{statusCounts.contacted}</p>
        </Card>
        <Card className="p-4">
          <p className="text-sm text-muted-foreground">Visited</p>
          <p className="mt-2 text-2xl font-bold text-purple-400">{statusCounts.visited}</p>
        </Card>
        <Card className="p-4">
          <p className="text-sm text-muted-foreground">Converted</p>
          <p className="mt-2 text-2xl font-bold text-success">{statusCounts.converted}</p>
        </Card>
      </div>

      <Card className="mb-6 p-4">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            placeholder="Search guests by name, phone, or email..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-10"
          />
        </div>
      </Card>

      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <TabsList>
          <TabsTrigger value="all">All ({statusCounts.all})</TabsTrigger>
          <TabsTrigger value="new">New ({statusCounts.new})</TabsTrigger>
          <TabsTrigger value="contacted">Contacted ({statusCounts.contacted})</TabsTrigger>
          <TabsTrigger value="visited">Visited ({statusCounts.visited})</TabsTrigger>
          <TabsTrigger value="converted">Converted ({statusCounts.converted})</TabsTrigger>
          <TabsTrigger value="lost">Lost ({statusCounts.lost})</TabsTrigger>
        </TabsList>

        <TabsContent value={activeTab} className="mt-6">
          <div className="grid gap-6">
            {filteredGuests.map((guest) => (
              <Card key={guest.id} className="p-6">
                <div className="flex items-start justify-between">
                  <div className="flex gap-4">
                    <div className="flex h-12 w-12 items-center justify-center rounded-full bg-primary/10 text-lg font-semibold text-primary">
                      {guest.name.charAt(0)}
                    </div>
                    <div className="flex-1">
                      <div className="flex items-center gap-3">
                        <h3 className="text-lg font-semibold">{guest.name}</h3>
                        <Badge className={getStatusColor(guest.status)}>{guest.status}</Badge>
                        <Badge variant="outline">{getSourceBadge(guest.source)}</Badge>
                      </div>
                      <div className="mt-2 flex flex-wrap gap-4 text-sm text-muted-foreground">
                        <div className="flex items-center gap-1">
                          <Phone className="h-4 w-4" />
                          {guest.phone}
                        </div>
                        {guest.email && (
                          <div className="flex items-center gap-1">
                            <Mail className="h-4 w-4" />
                            {guest.email}
                          </div>
                        )}
                        <div className="flex items-center gap-1">
                          <Calendar className="h-4 w-4" />
                          Added {new Date(guest.createdAt).toLocaleDateString()}
                        </div>
                      </div>
                      <div className="mt-3 flex items-center gap-6">
                        {guest.interestedPlan && (
                          <div>
                            <p className="text-xs text-muted-foreground">Interested In</p>
                            <p className="font-medium">{dataService.getPlan(guest.interestedPlan)?.name}</p>
                          </div>
                        )}
                        {guest.followUpDate && (
                          <div>
                            <p className="text-xs text-muted-foreground">Follow-up Date</p>
                            <p className="font-medium">{new Date(guest.followUpDate).toLocaleDateString()}</p>
                          </div>
                        )}
                        {guest.assignedTo && (
                          <div>
                            <p className="text-xs text-muted-foreground">Assigned To</p>
                            <p className="font-medium">{guest.assignedTo}</p>
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                  <div className="flex gap-2">
                    <Button variant="outline" size="sm" onClick={() => router.push(`/guests/${guest.id}`)}>
                      <Eye className="mr-2 h-4 w-4" />
                      View Details
                    </Button>
                  </div>
                </div>
              </Card>
            ))}

            {filteredGuests.length === 0 && (
              <Card className="p-12 text-center">
                <p className="text-muted-foreground">
                  {searchQuery ? "No guests found matching your search" : "No guests in this category"}
                </p>
              </Card>
            )}
          </div>
        </TabsContent>
      </Tabs>

      {showAddDialog && (
        <AddGuestDialog
          onClose={() => setShowAddDialog(false)}
          onAdd={(newGuest) => {
            dataService.addGuest(newGuest)
            setGuests(dataService.getGuests())
            setShowAddDialog(false)
          }}
        />
      )}
    </div>
  )
}
