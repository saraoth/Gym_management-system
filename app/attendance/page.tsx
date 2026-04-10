"use client"

import { useEffect, useState } from "react"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Search, UserCheck, LogIn, LogOut, Calendar, Clock, User } from "lucide-react"
import { dataService } from "@/lib/data"
import type { Attendance } from "@/lib/types"
import { CheckInDialog } from "@/components/check-in-dialog"

export default function AttendancePage() {
  const [attendance, setAttendance] = useState<Attendance[]>([])
  const [searchQuery, setSearchQuery] = useState("")
  const [filteredAttendance, setFilteredAttendance] = useState<Attendance[]>([])
  const [showCheckInDialog, setShowCheckInDialog] = useState(false)
  const [activeTab, setActiveTab] = useState("today")

  useEffect(() => {
    const allAttendance = dataService.getAttendance()
    setAttendance(allAttendance)
    setFilteredAttendance(allAttendance)
  }, [])

  useEffect(() => {
    let filtered = attendance

    const now = new Date()
    const today = now.toISOString().split("T")[0]

    if (activeTab === "today") {
      filtered = filtered.filter((a) => a.checkIn.startsWith(today))
    } else if (activeTab === "active") {
      filtered = filtered.filter((a) => !a.checkOut)
    }

    if (searchQuery) {
      const q = searchQuery.toLowerCase()
      filtered = filtered.filter((a) => a.memberName.toLowerCase().includes(q) || a.memberId.includes(q))
    }

    setFilteredAttendance(filtered)
  }, [searchQuery, attendance, activeTab])

  const getTypeBadge = (type: string) => {
    const labels: Record<string, { label: string; color: string }> = {
      gym: { label: "Gym", color: "bg-blue-500/10 text-blue-400 border-blue-500/20" },
      class: { label: "Class", color: "bg-purple-500/10 text-purple-400 border-purple-500/20" },
      "pt-session": { label: "PT Session", color: "bg-success/10 text-success border-success/20" },
    }
    return labels[type] || { label: type, color: "bg-muted text-muted-foreground" }
  }

  const calculateDuration = (checkIn: string, checkOut?: string) => {
    const start = new Date(checkIn)
    const end = checkOut ? new Date(checkOut) : new Date()
    const diff = end.getTime() - start.getTime()
    const hours = Math.floor(diff / (1000 * 60 * 60))
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
    return `${hours}h ${minutes}m`
  }

  const todayCount = attendance.filter((a) => a.checkIn.startsWith(new Date().toISOString().split("T")[0])).length
  const activeCount = attendance.filter((a) => !a.checkOut).length
  const totalToday = attendance.filter((a) => a.checkIn.startsWith(new Date().toISOString().split("T")[0])).length

  const handleCheckOut = (id: string) => {
    dataService.checkOut(id, new Date().toISOString())
    setAttendance(dataService.getAttendance())
  }

  return (
    <div className="p-8">
      <div className="mb-8 flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Attendance</h1>
          <p className="mt-2 text-muted-foreground">Track member check-ins and check-outs</p>
        </div>
        <Button onClick={() => setShowCheckInDialog(true)}>
          <UserCheck className="mr-2 h-4 w-4" />
          Check In Member
        </Button>
      </div>

      <div className="mb-6 grid gap-4 md:grid-cols-3">
        <Card className="p-4">
          <div className="flex items-center gap-2 text-muted-foreground">
            <Calendar className="h-4 w-4" />
            <p className="text-sm">Today's Check-ins</p>
          </div>
          <p className="mt-2 text-2xl font-bold">{todayCount}</p>
        </Card>
        <Card className="p-4">
          <div className="flex items-center gap-2 text-muted-foreground">
            <UserCheck className="h-4 w-4" />
            <p className="text-sm">Currently Active</p>
          </div>
          <p className="mt-2 text-2xl font-bold text-success">{activeCount}</p>
        </Card>
        <Card className="p-4">
          <div className="flex items-center gap-2 text-muted-foreground">
            <Clock className="h-4 w-4" />
            <p className="text-sm">Total Today</p>
          </div>
          <p className="mt-2 text-2xl font-bold">{totalToday}</p>
        </Card>
      </div>

      <Card className="mb-6 p-4">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            placeholder="Search by member name or ID..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-10"
          />
        </div>
      </Card>

      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <TabsList>
          <TabsTrigger value="today">Today</TabsTrigger>
          <TabsTrigger value="active">Currently Active</TabsTrigger>
          <TabsTrigger value="all">All Records</TabsTrigger>
        </TabsList>

        <TabsContent value={activeTab} className="mt-6">
          <div className="grid gap-4">
            {filteredAttendance.map((record) => {
              const typeBadge = getTypeBadge(record.type)
              return (
                <Card key={record.id} className="p-6">
                  <div className="flex items-start justify-between">
                    <div className="flex gap-4">
                      <div className="flex h-12 w-12 items-center justify-center rounded-full bg-primary/10">
                        <User className="h-6 w-6 text-primary" />
                      </div>
                      <div className="flex-1">
                        <div className="flex items-center gap-3">
                          <h3 className="text-lg font-semibold">{record.memberName}</h3>
                          <Badge className={typeBadge.color}>{typeBadge.label}</Badge>
                          {!record.checkOut && <Badge className="bg-success/10 text-success">Active</Badge>}
                        </div>
                        <div className="mt-2 flex flex-wrap gap-4 text-sm text-muted-foreground">
                          <div className="flex items-center gap-1">
                            <LogIn className="h-4 w-4" />
                            Check-in: {new Date(record.checkIn).toLocaleString()}
                          </div>
                          {record.checkOut && (
                            <div className="flex items-center gap-1">
                              <LogOut className="h-4 w-4" />
                              Check-out: {new Date(record.checkOut).toLocaleString()}
                            </div>
                          )}
                          <div className="flex items-center gap-1">
                            <Clock className="h-4 w-4" />
                            Duration: {calculateDuration(record.checkIn, record.checkOut)}
                          </div>
                        </div>
                        {record.trainerId && (
                          <p className="mt-2 text-sm text-muted-foreground">
                            Trainer: {dataService.getTrainer(record.trainerId)?.name || "Unknown"}
                          </p>
                        )}
                      </div>
                    </div>
                    <div className="flex gap-2">
                      {!record.checkOut && (
                        <Button variant="outline" size="sm" onClick={() => handleCheckOut(record.id)}>
                          <LogOut className="mr-2 h-4 w-4" />
                          Check Out
                        </Button>
                      )}
                    </div>
                  </div>
                </Card>
              )
            })}

            {filteredAttendance.length === 0 && (
              <Card className="p-12 text-center">
                <p className="text-muted-foreground">
                  {searchQuery ? "No attendance records found matching your search" : "No attendance records"}
                </p>
              </Card>
            )}
          </div>
        </TabsContent>
      </Tabs>

      {showCheckInDialog && (
        <CheckInDialog
          onClose={() => setShowCheckInDialog(false)}
          onCheckIn={(record) => {
            dataService.addAttendance(record)
            setAttendance(dataService.getAttendance())
            setShowCheckInDialog(false)
          }}
        />
      )}
    </div>
  )
}
