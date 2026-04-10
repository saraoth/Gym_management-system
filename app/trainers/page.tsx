"use client"

import { useEffect, useState } from "react"
import { useRouter } from "next/navigation"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Search, Plus, Mail, Phone, Calendar, Eye } from "lucide-react"
import { dataService } from "@/lib/data"
import type { Trainer } from "@/lib/types"
import { AddTrainerDialog } from "@/components/add-trainer-dialog"

export default function TrainersPage() {
  const router = useRouter()
  const [trainers, setTrainers] = useState<Trainer[]>([])
  const [searchQuery, setSearchQuery] = useState("")
  const [filteredTrainers, setFilteredTrainers] = useState<Trainer[]>([])
  const [showAddDialog, setShowAddDialog] = useState(false)

  useEffect(() => {
    const allTrainers = dataService.getTrainers()
    setTrainers(allTrainers)
    setFilteredTrainers(allTrainers)
  }, [])

  useEffect(() => {
    if (searchQuery) {
      const q = searchQuery.toLowerCase()
      const filtered = trainers.filter(
        (t) => t.name.toLowerCase().includes(q) || t.email.toLowerCase().includes(q) || t.phone.includes(q),
      )
      setFilteredTrainers(filtered)
    } else {
      setFilteredTrainers(trainers)
    }
  }, [searchQuery, trainers])

  const getStatusColor = (status: string) => {
    return status === "active"
      ? "bg-success/10 text-success border-success/20"
      : "bg-muted text-muted-foreground border-border"
  }

  const totalSessions = trainers.reduce((sum, t) => sum + t.totalSessions, 0)
  const totalEarnings = trainers.reduce((sum, t) => sum + t.totalEarnings, 0)
  const activeTrainers = trainers.filter((t) => t.status === "active").length

  return (
    <div className="p-8">
      <div className="mb-8 flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Trainers</h1>
          <p className="mt-2 text-muted-foreground">Manage your gym trainers and track their performance</p>
        </div>
        <Button onClick={() => setShowAddDialog(true)}>
          <Plus className="mr-2 h-4 w-4" />
          Add Trainer
        </Button>
      </div>

      <div className="mb-6 grid gap-4 md:grid-cols-4">
        <Card className="p-4">
          <p className="text-sm text-muted-foreground">Total Trainers</p>
          <p className="mt-2 text-2xl font-bold">{trainers.length}</p>
        </Card>
        <Card className="p-4">
          <p className="text-sm text-muted-foreground">Active Trainers</p>
          <p className="mt-2 text-2xl font-bold text-success">{activeTrainers}</p>
        </Card>
        <Card className="p-4">
          <p className="text-sm text-muted-foreground">Total Sessions</p>
          <p className="mt-2 text-2xl font-bold">{totalSessions}</p>
        </Card>
        <Card className="p-4">
          <p className="text-sm text-muted-foreground">Total Earnings</p>
          <p className="mt-2 text-2xl font-bold">{totalEarnings.toLocaleString()} EGP</p>
        </Card>
      </div>

      <Card className="mb-6 p-4">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            placeholder="Search trainers by name, email, or phone..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-10"
          />
        </div>
      </Card>

      <div className="grid gap-6">
        {filteredTrainers.map((trainer) => (
          <Card key={trainer.id} className="p-6">
            <div className="flex items-start justify-between">
              <div className="flex gap-4">
                <div className="flex h-12 w-12 items-center justify-center rounded-full bg-primary/10 text-lg font-semibold text-primary">
                  {trainer.name.charAt(0)}
                </div>
                <div className="flex-1">
                  <div className="flex items-center gap-3">
                    <h3 className="text-lg font-semibold">{trainer.name}</h3>
                    <Badge className={getStatusColor(trainer.status)}>{trainer.status}</Badge>
                  </div>
                  <div className="mt-2 flex flex-wrap gap-4 text-sm text-muted-foreground">
                    <div className="flex items-center gap-1">
                      <Mail className="h-4 w-4" />
                      {trainer.email}
                    </div>
                    <div className="flex items-center gap-1">
                      <Phone className="h-4 w-4" />
                      {trainer.phone}
                    </div>
                    <div className="flex items-center gap-1">
                      <Calendar className="h-4 w-4" />
                      Since {new Date(trainer.hireDate).toLocaleDateString()}
                    </div>
                  </div>
                  <div className="mt-3 flex items-center gap-6">
                    <div>
                      <p className="text-xs text-muted-foreground">Specialization</p>
                      <p className="font-medium">{trainer.specialization.join(", ")}</p>
                    </div>
                    <div>
                      <p className="text-xs text-muted-foreground">Total Sessions</p>
                      <p className="font-medium">{trainer.totalSessions}</p>
                    </div>
                    <div>
                      <p className="text-xs text-muted-foreground">Total Earnings</p>
                      <p className="font-medium">{trainer.totalEarnings.toLocaleString()} EGP</p>
                    </div>
                  </div>
                </div>
              </div>
              <div className="flex gap-2">
                <Button variant="outline" size="sm" onClick={() => router.push(`/trainers/${trainer.id}`)}>
                  <Eye className="mr-2 h-4 w-4" />
                  View Details
                </Button>
              </div>
            </div>
          </Card>
        ))}

        {filteredTrainers.length === 0 && (
          <Card className="p-12 text-center">
            <p className="text-muted-foreground">
              {searchQuery ? "No trainers found matching your search" : "No trainers yet"}
            </p>
          </Card>
        )}
      </div>

      {showAddDialog && (
        <AddTrainerDialog
          onClose={() => setShowAddDialog(false)}
          onAdd={(newTrainer) => {
            dataService.addTrainer(newTrainer)
            setTrainers(dataService.getTrainers())
            setShowAddDialog(false)
          }}
        />
      )}
    </div>
  )
}
