"use client"

import { useEffect, useState } from "react"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { DollarSign, TrendingUp, Users, UserPlus, Download, BarChart3 } from "lucide-react"
import { dataService } from "@/lib/data"
import {
  BarChart,
  Bar,
  LineChart,
  Line,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from "recharts"

export default function ReportsPage() {
  const [period, setPeriod] = useState("month")
  const [stats, setStats] = useState({
    totalRevenue: 0,
    membershipRevenue: 0,
    ptRevenue: 0,
    otherRevenue: 0,
    totalExpenses: 0,
    trainerSalaries: 0,
    netProfit: 0,
    newMembers: 0,
    renewals: 0,
    cancellations: 0,
    activeMembers: 0,
    totalMembers: 0,
    conversionRate: 0,
    averageRevenuePerMember: 0,
  })

  useEffect(() => {
    const members = dataService.getMembers()
    const payments = dataService.getPayments()
    const trainers = dataService.getTrainers()
    const guests = dataService.getGuests()

    const now = new Date()
    let startDate: Date

    switch (period) {
      case "week":
        startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000)
        break
      case "month":
        startDate = new Date(now.getFullYear(), now.getMonth(), 1)
        break
      case "quarter":
        startDate = new Date(now.getFullYear(), Math.floor(now.getMonth() / 3) * 3, 1)
        break
      case "year":
        startDate = new Date(now.getFullYear(), 0, 1)
        break
      default:
        startDate = new Date(now.getFullYear(), now.getMonth(), 1)
    }

    const periodPayments = payments.filter((p) => new Date(p.date) >= startDate && p.status === "completed")

    const totalRevenue = periodPayments.reduce((sum, p) => sum + p.amount, 0)
    const membershipRevenue = periodPayments
      .filter((p) => p.type === "membership")
      .reduce((sum, p) => sum + p.amount, 0)
    const ptRevenue = periodPayments.filter((p) => p.type === "pt-session").reduce((sum, p) => sum + p.amount, 0)
    const otherRevenue = totalRevenue - membershipRevenue - ptRevenue

    const trainerSalaries = trainers.reduce((sum, t) => sum + t.baseSalary, 0)
    const totalExpenses = trainerSalaries
    const netProfit = totalRevenue - totalExpenses

    const newMembers = members.filter((m) => new Date(m.joinDate) >= startDate).length
    const activeMembers = members.filter((m) => m.status === "active").length

    const convertedGuests = guests.filter((g) => g.status === "converted" && new Date(g.updatedAt) >= startDate).length
    const totalGuests = guests.filter((g) => new Date(g.createdAt) >= startDate).length
    const conversionRate = totalGuests > 0 ? (convertedGuests / totalGuests) * 100 : 0

    const averageRevenuePerMember = activeMembers > 0 ? totalRevenue / activeMembers : 0

    setStats({
      totalRevenue,
      membershipRevenue,
      ptRevenue,
      otherRevenue,
      totalExpenses,
      trainerSalaries,
      netProfit,
      newMembers,
      renewals: 0,
      cancellations: 0,
      activeMembers,
      totalMembers: members.length,
      conversionRate,
      averageRevenuePerMember,
    })
  }, [period])

  const getPeriodLabel = () => {
    switch (period) {
      case "week":
        return "This Week"
      case "month":
        return "This Month"
      case "quarter":
        return "This Quarter"
      case "year":
        return "This Year"
      default:
        return "This Month"
    }
  }

  const revenueBreakdownData = [
    { name: "Membership", value: stats.membershipRevenue, color: "#3b82f6" },
    { name: "PT Sessions", value: stats.ptRevenue, color: "#10b981" },
    { name: "Other", value: stats.otherRevenue, color: "#8b5cf6" },
  ]

  const financialComparisonData = [
    {
      name: "Financial Overview",
      Revenue: stats.totalRevenue,
      Expenses: stats.totalExpenses,
      Profit: stats.netProfit,
    },
  ]

  const membershipTrendData = [
    { month: "Jan", members: 45 },
    { month: "Feb", members: 52 },
    { month: "Mar", members: 61 },
    { month: "Apr", members: 58 },
    { month: "May", members: 67 },
    { month: "Jun", members: stats.totalMembers },
  ]

  return (
    <div className="p-8">
      <div className="mb-8 flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Reports & Analytics</h1>
          <p className="mt-2 text-muted-foreground">Comprehensive financial and operational reports</p>
        </div>
        <div className="flex gap-2">
          <Select value={period} onValueChange={setPeriod}>
            <SelectTrigger className="w-40">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="week">This Week</SelectItem>
              <SelectItem value="month">This Month</SelectItem>
              <SelectItem value="quarter">This Quarter</SelectItem>
              <SelectItem value="year">This Year</SelectItem>
            </SelectContent>
          </Select>
          <Button variant="outline">
            <Download className="mr-2 h-4 w-4" />
            Export
          </Button>
        </div>
      </div>

      <div className="mb-8">
        <h2 className="mb-4 text-xl font-semibold">Financial Overview - {getPeriodLabel()}</h2>
        <div className="grid gap-4 md:grid-cols-4">
          <Card className="p-6">
            <div className="flex items-center gap-2 text-muted-foreground">
              <DollarSign className="h-4 w-4" />
              <p className="text-sm">Total Revenue</p>
            </div>
            <p className="mt-2 text-3xl font-bold text-success">{stats.totalRevenue.toLocaleString()} EGP</p>
          </Card>
          <Card className="p-6">
            <div className="flex items-center gap-2 text-muted-foreground">
              <TrendingUp className="h-4 w-4" />
              <p className="text-sm">Total Expenses</p>
            </div>
            <p className="mt-2 text-3xl font-bold text-destructive">{stats.totalExpenses.toLocaleString()} EGP</p>
          </Card>
          <Card className="p-6">
            <div className="flex items-center gap-2 text-muted-foreground">
              <BarChart3 className="h-4 w-4" />
              <p className="text-sm">Net Profit</p>
            </div>
            <p className={`mt-2 text-3xl font-bold ${stats.netProfit >= 0 ? "text-success" : "text-destructive"}`}>
              {stats.netProfit.toLocaleString()} EGP
            </p>
          </Card>
          <Card className="p-6">
            <div className="flex items-center gap-2 text-muted-foreground">
              <DollarSign className="h-4 w-4" />
              <p className="text-sm">Avg Revenue/Member</p>
            </div>
            <p className="mt-2 text-3xl font-bold">{Math.round(stats.averageRevenuePerMember).toLocaleString()} EGP</p>
          </Card>
        </div>
      </div>

      <div className="mb-8 grid gap-6 lg:grid-cols-2">
        <Card className="p-6">
          <h2 className="mb-4 text-xl font-semibold">Revenue Breakdown</h2>
          <ResponsiveContainer width="100%" height={300}>
            <PieChart>
              <Pie
                data={revenueBreakdownData}
                cx="50%"
                cy="50%"
                labelLine={false}
                label={({ name, percent }) => `${name}: ${(percent * 100).toFixed(0)}%`}
                outerRadius={100}
                fill="#8884d8"
                dataKey="value"
              >
                {revenueBreakdownData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.color} />
                ))}
              </Pie>
              <Tooltip formatter={(value: number) => `${value.toLocaleString()} EGP`} />
            </PieChart>
          </ResponsiveContainer>
          <div className="mt-4 grid gap-2">
            {revenueBreakdownData.map((item) => (
              <div key={item.name} className="flex items-center justify-between text-sm">
                <div className="flex items-center gap-2">
                  <div className="h-3 w-3 rounded-full" style={{ backgroundColor: item.color }} />
                  <span>{item.name}</span>
                </div>
                <span className="font-semibold">{item.value.toLocaleString()} EGP</span>
              </div>
            ))}
          </div>
        </Card>

        <Card className="p-6">
          <h2 className="mb-4 text-xl font-semibold">Financial Comparison</h2>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={financialComparisonData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#333" />
              <XAxis dataKey="name" stroke="#888" />
              <YAxis stroke="#888" />
              <Tooltip
                contentStyle={{ backgroundColor: "#1a1a1a", border: "1px solid #333" }}
                formatter={(value: number) => `${value.toLocaleString()} EGP`}
              />
              <Legend />
              <Bar dataKey="Revenue" fill="#10b981" />
              <Bar dataKey="Expenses" fill="#ef4444" />
              <Bar dataKey="Profit" fill="#3b82f6" />
            </BarChart>
          </ResponsiveContainer>
        </Card>
      </div>

      <Card className="mb-8 p-6">
        <h2 className="mb-4 text-xl font-semibold">Membership Growth Trend</h2>
        <ResponsiveContainer width="100%" height={300}>
          <LineChart data={membershipTrendData}>
            <CartesianGrid strokeDasharray="3 3" stroke="#333" />
            <XAxis dataKey="month" stroke="#888" />
            <YAxis stroke="#888" />
            <Tooltip
              contentStyle={{ backgroundColor: "#1a1a1a", border: "1px solid #333" }}
              formatter={(value: number) => `${value} members`}
            />
            <Legend />
            <Line type="monotone" dataKey="members" stroke="#3b82f6" strokeWidth={2} dot={{ fill: "#3b82f6" }} />
          </LineChart>
        </ResponsiveContainer>
      </Card>

      <div className="mb-8">
        <h2 className="mb-4 text-xl font-semibold">Membership Statistics</h2>
        <div className="grid gap-4 md:grid-cols-4">
          <Card className="p-6">
            <div className="flex items-center gap-2 text-muted-foreground">
              <Users className="h-4 w-4" />
              <p className="text-sm">Total Members</p>
            </div>
            <p className="mt-2 text-3xl font-bold">{stats.totalMembers}</p>
          </Card>
          <Card className="p-6">
            <div className="flex items-center gap-2 text-muted-foreground">
              <UserPlus className="h-4 w-4" />
              <p className="text-sm">New Members</p>
            </div>
            <p className="mt-2 text-3xl font-bold text-success">{stats.newMembers}</p>
          </Card>
          <Card className="p-6">
            <div className="flex items-center gap-2 text-muted-foreground">
              <Users className="h-4 w-4" />
              <p className="text-sm">Active Members</p>
            </div>
            <p className="mt-2 text-3xl font-bold">{stats.activeMembers}</p>
          </Card>
          <Card className="p-6">
            <div className="flex items-center gap-2 text-muted-foreground">
              <TrendingUp className="h-4 w-4" />
              <p className="text-sm">Conversion Rate</p>
            </div>
            <p className="mt-2 text-3xl font-bold">{stats.conversionRate.toFixed(1)}%</p>
          </Card>
        </div>
      </div>

      <Card className="p-6">
        <h2 className="mb-4 text-xl font-semibold">Key Performance Indicators</h2>
        <div className="space-y-4">
          <div className="flex items-center justify-between rounded-lg border border-border p-4">
            <div>
              <p className="font-medium">Revenue Growth</p>
              <p className="text-sm text-muted-foreground">Compared to previous period</p>
            </div>
            <div className="text-right">
              <p className="text-2xl font-bold text-success">+0%</p>
            </div>
          </div>
          <div className="flex items-center justify-between rounded-lg border border-border p-4">
            <div>
              <p className="font-medium">Member Retention Rate</p>
              <p className="text-sm text-muted-foreground">Active members / Total members</p>
            </div>
            <div className="text-right">
              <p className="text-2xl font-bold">
                {stats.totalMembers > 0 ? Math.round((stats.activeMembers / stats.totalMembers) * 100) : 0}%
              </p>
            </div>
          </div>
          <div className="flex items-center justify-between rounded-lg border border-border p-4">
            <div>
              <p className="font-medium">Lead Conversion Rate</p>
              <p className="text-sm text-muted-foreground">Guests converted to members</p>
            </div>
            <div className="text-right">
              <p className="text-2xl font-bold">{stats.conversionRate.toFixed(1)}%</p>
            </div>
          </div>
        </div>
      </Card>
    </div>
  )
}
