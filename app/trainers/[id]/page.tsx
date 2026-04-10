"use client"

import { useEffect, useState } from "react"
import { useParams, useRouter } from "next/navigation"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { ArrowLeft, Mail, Phone, Calendar, Edit, DollarSign, Activity, TrendingUp } from "lucide-react"
import { dataService } from "@/lib/data"
import type { Trainer } from "@/lib/types"
import { EditTrainerDialog } from "@/components/edit-trainer-dialog"

export default function TrainerDetailPage() {
  const params = useParams()
  const router = useRouter()
  const [trainer, setTrainer] = useState<Trainer | null>(null)
  const [showEditDialog, setShowEditDialog] = useState(false)

  useEffect(() => {
    const trainerId = params.id as string
    const trainerData = dataService.getTrainer(trainerId)
    setTrainer(trainerData || null)
  }, [params.id])

  if (!trainer) {
    return (
      <div className="flex h-full items-center justify-center">
        <p className="text-muted-foreground">Trainer not found</p>
      </div>
    )
  }

  const getStatusColor = (status: string) => {
    return status === "active"
      ? "bg-success/10 text-success border-success/20"
      : "bg-muted text-muted-foreground border-border"
  }

  const monthlyEarnings = trainer.baseSalary + (trainer.totalSessions * 100 * trainer.commissionRate) / 100

  return (
    <div className="p-8">
      <Button variant="ghost" onClick={() => router.push("/trainers")} className="mb-6">
        <ArrowLeft className="mr-2 h-4 w-4" />
        Back to Trainers
      </Button>

      <div className="mb-6 flex items-start justify-between">
        <div className="flex gap-4">
          <div className="flex h-20 w-20 items-center justify-center rounded-full bg-primary/10 text-3xl font-semibold text-primary">
            {trainer.name.charAt(0)}
          </div>
          <div>
            <div className="flex items-center gap-3">
              <h1 className="text-3xl font-bold">{trainer.name}</h1>
              <Badge className={getStatusColor(trainer.status)}>{trainer.status}</Badge>
            </div>
            <p className="mt-2 text-muted-foreground">Trainer ID: {trainer.id}</p>
          </div>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" onClick={() => setShowEditDialog(true)}>
            <Edit className="mr-2 h-4 w-4" />
            Edit
          </Button>
        </div>
      </div>

      <div className="mb-6 grid gap-4 md:grid-cols-4">
        <Card className="p-4">
          <div className="flex items-center gap-2 text-muted-foreground">
            <DollarSign className="h-4 w-4" />
            <p className="text-sm">Base Salary</p>
          </div>
          <p className="mt-2 text-2xl font-bold">{trainer.baseSalary.toLocaleString()} EGP</p>
        </Card>
        <Card className="p-4">
          <div className="flex items-center gap-2 text-muted-foreground">
            <TrendingUp className="h-4 w-4" />
            <p className="text-sm">Commission Rate</p>
          </div>
          <p className="mt-2 text-2xl font-bold">{trainer.commissionRate}%</p>
        </Card>
        <Card className="p-4">
          <div className="flex items-center gap-2 text-muted-foreground">
            <Activity className="h-4 w-4" />
            <p className="text-sm">Total Sessions</p>
          </div>
          <p className="mt-2 text-2xl font-bold">{trainer.totalSessions}</p>
        </Card>
        <Card className="p-4">
          <div className="flex items-center gap-2 text-muted-foreground">
            <DollarSign className="h-4 w-4" />
            <p className="text-sm">Total Earnings</p>
          </div>
          <p className="mt-2 text-2xl font-bold">{trainer.totalEarnings.toLocaleString()} EGP</p>
        </Card>
      </div>

      <Tabs defaultValue="details" className="space-y-6">
        <TabsList>
          <TabsTrigger value="details">Details</TabsTrigger>
          <TabsTrigger value="earnings">Earnings</TabsTrigger>
          <TabsTrigger value="sessions">Sessions</TabsTrigger>
        </TabsList>

        <TabsContent value="details" className="space-y-6">
          <Card className="p-6">
            <h2 className="mb-4 text-lg font-semibold">Personal Information</h2>
            <div className="grid gap-4 md:grid-cols-2">
              <div className="flex items-start gap-3">
                <Mail className="mt-1 h-5 w-5 text-muted-foreground" />
                <div>
                  <p className="text-sm text-muted-foreground">Email</p>
                  <p className="font-medium">{trainer.email}</p>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <Phone className="mt-1 h-5 w-5 text-muted-foreground" />
                <div>
                  <p className="text-sm text-muted-foreground">Phone</p>
                  <p className="font-medium">{trainer.phone}</p>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <Calendar className="mt-1 h-5 w-5 text-muted-foreground" />
                <div>
                  <p className="text-sm text-muted-foreground">Hire Date</p>
                  <p className="font-medium">{new Date(trainer.hireDate).toLocaleDateString()}</p>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <Activity className="mt-1 h-5 w-5 text-muted-foreground" />
                <div>
                  <p className="text-sm text-muted-foreground">Status</p>
                  <p className="font-medium capitalize">{trainer.status}</p>
                </div>
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <h2 className="mb-4 text-lg font-semibold">Specialization</h2>
            <div className="flex flex-wrap gap-2">
              {trainer.specialization.map((spec, index) => (
                <Badge key={index} variant="outline" className="text-sm">
                  {spec}
                </Badge>
              ))}
            </div>
          </Card>
        </TabsContent>

        <TabsContent value="earnings" className="space-y-6">
          <Card className="p-6">
            <h2 className="mb-4 text-lg font-semibold">Salary Breakdown</h2>
            <div className="space-y-4">
              <div className="flex items-center justify-between rounded-lg border border-border p-4">
                <div>
                  <p className="text-sm text-muted-foreground">Base Salary</p>
                  <p className="text-lg font-semibold">{trainer.baseSalary.toLocaleString()} EGP</p>
                </div>
              </div>
              <div className="flex items-center justify-between rounded-lg border border-border p-4">
                <div>
                  <p className="text-sm text-muted-foreground">Commission ({trainer.commissionRate}%)</p>
                  <p className="text-sm text-muted-foreground">
                    {trainer.totalSessions} sessions × 100 EGP × {trainer.commissionRate}%
                  </p>
                  <p className="text-lg font-semibold">
                    {((trainer.totalSessions * 100 * trainer.commissionRate) / 100).toLocaleString()} EGP
                  </p>
                </div>
              </div>
              <div className="flex items-center justify-between rounded-lg border-2 border-primary bg-primary/5 p-4">
                <div>
                  <p className="text-sm text-muted-foreground">Estimated Monthly Earnings</p>
                  <p className="text-2xl font-bold text-primary">{monthlyEarnings.toLocaleString()} EGP</p>
                </div>
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <h2 className="mb-4 text-lg font-semibold">Earnings History</h2>
            <div className="space-y-4">
              <div className="flex items-start gap-4 rounded-lg border border-border p-4">
                <div className="rounded-full bg-success/10 p-2">
                  <DollarSign className="h-4 w-4 text-success" />
                </div>
                <div className="flex-1">
                  <p className="font-medium">Total Lifetime Earnings</p>
                  <p className="text-2xl font-bold">{trainer.totalEarnings.toLocaleString()} EGP</p>
                  <p className="mt-1 text-xs text-muted-foreground">
                    From {trainer.totalSessions} sessions since {new Date(trainer.hireDate).toLocaleDateString()}
                  </p>
                </div>
              </div>
            </div>
          </Card>
        </TabsContent>

        <TabsContent value="sessions" className="space-y-6">
          <Card className="p-6">
            <h2 className="mb-4 text-lg font-semibold">Session Statistics</h2>
            <div className="grid gap-4 md:grid-cols-3">
              <div className="rounded-lg border border-border p-4">
                <p className="text-sm text-muted-foreground">Total Sessions</p>
                <p className="mt-2 text-3xl font-bold">{trainer.totalSessions}</p>
              </div>
              <div className="rounded-lg border border-border p-4">
                <p className="text-sm text-muted-foreground">Average per Month</p>
                <p className="mt-2 text-3xl font-bold">
                  {Math.round(
                    trainer.totalSessions /
                      Math.max(
                        1,
                        (new Date().getTime() - new Date(trainer.hireDate).getTime()) / (1000 * 60 * 60 * 24 * 30),
                      ),
                  )}
                </p>
              </div>
              <div className="rounded-lg border border-border p-4">
                <p className="text-sm text-muted-foreground">Revenue Generated</p>
                <p className="mt-2 text-3xl font-bold">{(trainer.totalSessions * 100).toLocaleString()} EGP</p>
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <h2 className="mb-4 text-lg font-semibold">Recent Sessions</h2>
            <p className="text-sm text-muted-foreground">
              Session history will be tracked through the attendance system
            </p>
          </Card>
        </TabsContent>
      </Tabs>

      {showEditDialog && (
        <EditTrainerDialog
          trainer={trainer}
          onClose={() => setShowEditDialog(false)}
          onSave={(updates) => {
            const updatedTrainer = dataService.updateTrainer(trainer.id, updates)
            if (updatedTrainer) {
              setTrainer(updatedTrainer)
            }
            setShowEditDialog(false)
          }}
        />
      )}
    </div>
  )
}
