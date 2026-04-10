"use client"

import { useEffect, useState } from "react"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Search, Plus, DollarSign, Calendar, User } from "lucide-react"
import { dataService } from "@/lib/data"
import type { Payment } from "@/lib/types"
import { AddPaymentDialog } from "@/components/add-payment-dialog"

export default function PaymentsPage() {
  const [payments, setPayments] = useState<Payment[]>([])
  const [searchQuery, setSearchQuery] = useState("")
  const [filteredPayments, setFilteredPayments] = useState<Payment[]>([])
  const [showAddDialog, setShowAddDialog] = useState(false)
  const [activeTab, setActiveTab] = useState("all")

  useEffect(() => {
    const allPayments = dataService.getPayments()
    setPayments(allPayments)
    setFilteredPayments(allPayments)
  }, [])

  useEffect(() => {
    let filtered = payments

    if (activeTab !== "all") {
      filtered = filtered.filter((p) => p.type === activeTab)
    }

    if (searchQuery) {
      const q = searchQuery.toLowerCase()
      filtered = filtered.filter((p) => p.memberName.toLowerCase().includes(q) || p.id.includes(q))
    }

    setFilteredPayments(filtered)
  }, [searchQuery, payments, activeTab])

  const getStatusColor = (status: string) => {
    switch (status) {
      case "completed":
        return "bg-success/10 text-success border-success/20"
      case "pending":
        return "bg-warning/10 text-warning border-warning/20"
      case "refunded":
        return "bg-destructive/10 text-destructive border-destructive/20"
      default:
        return "bg-muted text-muted-foreground"
    }
  }

  const getMethodBadge = (method: string) => {
    const labels: Record<string, string> = {
      cash: "Cash",
      card: "Card",
      "bank-transfer": "Bank Transfer",
    }
    return labels[method] || method
  }

  const totalRevenue = payments.filter((p) => p.status === "completed").reduce((sum, p) => sum + p.amount, 0)
  const pendingAmount = payments.filter((p) => p.status === "pending").reduce((sum, p) => sum + p.amount, 0)
  const membershipRevenue = payments
    .filter((p) => p.type === "membership" && p.status === "completed")
    .reduce((sum, p) => sum + p.amount, 0)
  const ptRevenue = payments
    .filter((p) => p.type === "pt-session" && p.status === "completed")
    .reduce((sum, p) => sum + p.amount, 0)

  return (
    <div className="p-8">
      <div className="mb-8 flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Payments</h1>
          <p className="mt-2 text-muted-foreground">Track all payments and financial transactions</p>
        </div>
        <Button onClick={() => setShowAddDialog(true)}>
          <Plus className="mr-2 h-4 w-4" />
          Record Payment
        </Button>
      </div>

      <div className="mb-6 grid gap-4 md:grid-cols-4">
        <Card className="p-4">
          <p className="text-sm text-muted-foreground">Total Revenue</p>
          <p className="mt-2 text-2xl font-bold text-success">{totalRevenue.toLocaleString()} EGP</p>
        </Card>
        <Card className="p-4">
          <p className="text-sm text-muted-foreground">Pending</p>
          <p className="mt-2 text-2xl font-bold text-warning">{pendingAmount.toLocaleString()} EGP</p>
        </Card>
        <Card className="p-4">
          <p className="text-sm text-muted-foreground">Membership Revenue</p>
          <p className="mt-2 text-2xl font-bold">{membershipRevenue.toLocaleString()} EGP</p>
        </Card>
        <Card className="p-4">
          <p className="text-sm text-muted-foreground">PT Revenue</p>
          <p className="mt-2 text-2xl font-bold">{ptRevenue.toLocaleString()} EGP</p>
        </Card>
      </div>

      <Card className="mb-6 p-4">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            placeholder="Search payments by member name or ID..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-10"
          />
        </div>
      </Card>

      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <TabsList>
          <TabsTrigger value="all">All</TabsTrigger>
          <TabsTrigger value="membership">Membership</TabsTrigger>
          <TabsTrigger value="pt-session">PT Sessions</TabsTrigger>
          <TabsTrigger value="class">Classes</TabsTrigger>
          <TabsTrigger value="product">Products</TabsTrigger>
          <TabsTrigger value="other">Other</TabsTrigger>
        </TabsList>

        <TabsContent value={activeTab} className="mt-6">
          <div className="grid gap-4">
            {filteredPayments.map((payment) => (
              <Card key={payment.id} className="p-6">
                <div className="flex items-start justify-between">
                  <div className="flex gap-4">
                    <div className="flex h-12 w-12 items-center justify-center rounded-full bg-success/10">
                      <DollarSign className="h-6 w-6 text-success" />
                    </div>
                    <div className="flex-1">
                      <div className="flex items-center gap-3">
                        <h3 className="text-lg font-semibold">{payment.memberName}</h3>
                        <Badge className={getStatusColor(payment.status)}>{payment.status}</Badge>
                        <Badge variant="outline">{getMethodBadge(payment.method)}</Badge>
                      </div>
                      <div className="mt-2 flex flex-wrap gap-4 text-sm text-muted-foreground">
                        <div className="flex items-center gap-1">
                          <DollarSign className="h-4 w-4" />
                          {payment.amount.toLocaleString()} EGP
                        </div>
                        <div className="flex items-center gap-1">
                          <Calendar className="h-4 w-4" />
                          {new Date(payment.date).toLocaleString()}
                        </div>
                        <div className="flex items-center gap-1">
                          <User className="h-4 w-4" />
                          {payment.type.replace("-", " ").replace(/\b\w/g, (l) => l.toUpperCase())}
                        </div>
                      </div>
                      {payment.notes && <p className="mt-2 text-sm text-muted-foreground">{payment.notes}</p>}
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="text-2xl font-bold text-success">{payment.amount.toLocaleString()} EGP</p>
                    <p className="text-xs text-muted-foreground">ID: {payment.id}</p>
                  </div>
                </div>
              </Card>
            ))}

            {filteredPayments.length === 0 && (
              <Card className="p-12 text-center">
                <p className="text-muted-foreground">
                  {searchQuery ? "No payments found matching your search" : "No payments in this category"}
                </p>
              </Card>
            )}
          </div>
        </TabsContent>
      </Tabs>

      {showAddDialog && (
        <AddPaymentDialog
          onClose={() => setShowAddDialog(false)}
          onAdd={(newPayment) => {
            dataService.addPayment(newPayment)
            setPayments(dataService.getPayments())
            setShowAddDialog(false)
          }}
        />
      )}
    </div>
  )
}
