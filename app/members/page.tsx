"use client"

import { useEffect, useState } from "react"
import { useRouter } from "next/navigation"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Search, Plus, MoreVertical, Mail, Phone, Calendar, Eye } from "lucide-react"
import { dataService } from "@/lib/data"
import type { Member } from "@/lib/types"
import { AddMemberDialog } from "@/components/add-member-dialog"

export default function MembersPage() {
  const router = useRouter()
  const [members, setMembers] = useState<Member[]>([])
  const [searchQuery, setSearchQuery] = useState("")
  const [filteredMembers, setFilteredMembers] = useState<Member[]>([])
  const [showAddDialog, setShowAddDialog] = useState(false)

  useEffect(() => {
    const allMembers = dataService.getMembers()
    setMembers(allMembers)
    setFilteredMembers(allMembers)
  }, [])

  useEffect(() => {
    if (searchQuery) {
      const results = dataService.searchMembers(searchQuery)
      setFilteredMembers(results)
    } else {
      setFilteredMembers(members)
    }
  }, [searchQuery, members])

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

  return (
    <div className="p-8">
      <div className="mb-8 flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Members</h1>
          <p className="mt-2 text-muted-foreground">Manage your gym members and their subscriptions</p>
        </div>
        <Button onClick={() => setShowAddDialog(true)}>
          <Plus className="mr-2 h-4 w-4" />
          Add Member
        </Button>
      </div>

      <Card className="mb-6 p-4">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            placeholder="Search members by name, email, or phone..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-10"
          />
        </div>
      </Card>

      <div className="grid gap-6">
        {filteredMembers.map((member) => (
          <Card key={member.id} className="p-6">
            <div className="flex items-start justify-between">
              <div className="flex gap-4">
                <div className="flex h-12 w-12 items-center justify-center rounded-full bg-primary/10 text-lg font-semibold text-primary">
                  {member.name.charAt(0)}
                </div>
                <div className="flex-1">
                  <div className="flex items-center gap-3">
                    <h3 className="text-lg font-semibold">{member.name}</h3>
                    <Badge className={getStatusColor(member.status)}>{member.status}</Badge>
                  </div>
                  <div className="mt-2 flex flex-wrap gap-4 text-sm text-muted-foreground">
                    <div className="flex items-center gap-1">
                      <Mail className="h-4 w-4" />
                      {member.email}
                    </div>
                    <div className="flex items-center gap-1">
                      <Phone className="h-4 w-4" />
                      {member.phone}
                    </div>
                    <div className="flex items-center gap-1">
                      <Calendar className="h-4 w-4" />
                      Member since {new Date(member.joinDate).toLocaleDateString()}
                    </div>
                  </div>
                  <div className="mt-3 flex items-center gap-6">
                    <div>
                      <p className="text-xs text-muted-foreground">Current Plan</p>
                      <p className="font-medium">{getPlanName(member.membershipPlan)}</p>
                    </div>
                    <div>
                      <p className="text-xs text-muted-foreground">Expires</p>
                      <p className="font-medium">{new Date(member.membershipEndDate).toLocaleDateString()}</p>
                    </div>
                  </div>
                </div>
              </div>
              <div className="flex gap-2">
                <Button variant="outline" size="sm" onClick={() => router.push(`/members/${member.id}`)}>
                  <Eye className="mr-2 h-4 w-4" />
                  View Details
                </Button>
                <Button variant="ghost" size="icon">
                  <MoreVertical className="h-4 w-4" />
                </Button>
              </div>
            </div>
          </Card>
        ))}

        {filteredMembers.length === 0 && (
          <Card className="p-12 text-center">
            <p className="text-muted-foreground">
              {searchQuery ? "No members found matching your search" : "No members yet"}
            </p>
          </Card>
        )}
      </div>

      {showAddDialog && (
        <AddMemberDialog
          onClose={() => setShowAddDialog(false)}
          onAdd={(newMember) => {
            dataService.addMember(newMember)
            setMembers(dataService.getMembers())
            setShowAddDialog(false)
          }}
        />
      )}
    </div>
  )
}
