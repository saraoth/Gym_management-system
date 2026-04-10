"use client"

import { useEffect, useState } from "react"
import { StatCard } from "@/components/stat-card"
import { Card } from "@/components/ui/card"
import { Users, UserPlus, DollarSign, Calendar, AlertCircle, TrendingUp, Activity } from "lucide-react"
import { dataService, initializeSampleData } from "@/lib/data"
import { Button } from "@/components/ui/button"
import Link from "next/link"
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from "recharts"

export default function DashboardPage() {
  const [stats, setStats] = useState({
    totalMembers: 0,
    activeMembers: 0,
    newGuests: 0,
    monthlyRevenue: 0,
    todayAttendance: 0,
    expiringMemberships: 0,
  })

  useEffect(() => {
    initializeSampleData()

    const members = dataService.getMembers()
    const guests = dataService.getGuests()
    const payments = dataService.getPayments()
    const attendance = dataService.getAttendance()

    const activeMembers = members.filter((m) => m.status === "active").length
    const newGuests = guests.filter((g) => g.status === "new").length

    const now = new Date()
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1)
    const monthlyRevenue = payments
      .filter((p) => new Date(p.date) >= monthStart && p.status === "completed")
      .reduce((sum, p) => sum + p.amount, 0)

    const today = now.toISOString().split("T")[0]
    const todayAttendance = attendance.filter((a) => a.checkIn.startsWith(today)).length

    const thirtyDaysFromNow = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000)
    const expiringMemberships = members.filter((m) => {
      const endDate = new Date(m.membershipEndDate)
      return endDate <= thirtyDaysFromNow && endDate >= now && m.status === "active"
    }).length

    setStats({
      totalMembers: members.length,
      activeMembers,
      newGuests,
      monthlyRevenue,
      todayAttendance,
      expiringMemberships,
    })
  }, [])

  const weeklyAttendanceData = [
    { day: "Mon", count: 45 },
    { day: "Tue", count: 52 },
    { day: "Wed", count: 48 },
    { day: "Thu", count: 61 },
    { day: "Fri", count: 55 },
    { day: "Sat", count: 67 },
    { day: "Sun", count: stats.todayAttendance },
  ]

  const revenueData = [
    { month: "Jan", revenue: 45000 },
    { month: "Feb", revenue: 52000 },
    { month: "Mar", revenue: 48000 },
    { month: "Apr", revenue: 61000 },
    { month: "May", revenue: 58000 },
    { month: "Jun", revenue: stats.monthlyRevenue },
  ]

  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold">Dashboard</h1>
        <p className="mt-2 text-muted-foreground">Welcome back! Here's what's happening with your gym today.</p>
      </div>

      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
        <StatCard
          title="Total Members"
          value={stats.totalMembers}
          icon={Users}
          subtitle={`${stats.activeMembers} active`}
        />
        <StatCard title="New Guests" value={stats.newGuests} icon={UserPlus} subtitle="This month" />
        <StatCard title="Monthly Revenue" value={`${stats.monthlyRevenue.toLocaleString()} EGP`} icon={DollarSign} />
        <StatCard title="Today's Attendance" value={stats.todayAttendance} icon={Calendar} />
      </div>

      <div className="mt-8 grid gap-6 lg:grid-cols-2">
        <Card className="p-6">
          <div className="mb-4 flex items-center gap-2">
            <Activity className="h-5 w-5 text-primary" />
            <h2 className="text-lg font-semibold">Weekly Attendance</h2>
          </div>
          <ResponsiveContainer width="100%" height={200}>
            <BarChart data={weeklyAttendanceData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#333" />
              <XAxis dataKey="day" stroke="#888" />
              <YAxis stroke="#888" />
              <Tooltip
                contentStyle={{ backgroundColor: "#1a1a1a", border: "1px solid #333" }}
                formatter={(value: number) => `${value} check-ins`}
              />
              <Bar dataKey="count" fill="#3b82f6" />
            </BarChart>
          </ResponsiveContainer>
        </Card>

        <Card className="p-6">
          <div className="mb-4 flex items-center gap-2">
            <TrendingUp className="h-5 w-5 text-success" />
            <h2 className="text-lg font-semibold">Revenue Trend</h2>
          </div>
          <ResponsiveContainer width="100%" height={200}>
            <LineChart data={revenueData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#333" />
              <XAxis dataKey="month" stroke="#888" />
              <YAxis stroke="#888" />
              <Tooltip
                contentStyle={{ backgroundColor: "#1a1a1a", border: "1px solid #333" }}
                formatter={(value: number) => `${value.toLocaleString()} EGP`}
              />
              <Line type="monotone" dataKey="revenue" stroke="#10b981" strokeWidth={2} dot={{ fill: "#10b981" }} />
            </LineChart>
          </ResponsiveContainer>
        </Card>
      </div>

      <div className="mt-8 grid gap-6 lg:grid-cols-2">
        <Card className="p-6">
          <div className="mb-4 flex items-center justify-between">
            <h2 className="text-lg font-semibold">Quick Actions</h2>
          </div>
          <div className="space-y-3">
            <Link href="/members?action=new">
              <Button className="w-full justify-start bg-transparent" variant="outline">
                <Users className="mr-2 h-4 w-4" />
                Add New Member
              </Button>
            </Link>
            <Link href="/guests?action=new">
              <Button className="w-full justify-start bg-transparent" variant="outline">
                <UserPlus className="mr-2 h-4 w-4" />
                Add New Guest
              </Button>
            </Link>
            <Link href="/attendance?action=checkin">
              <Button className="w-full justify-start bg-transparent" variant="outline">
                <Calendar className="mr-2 h-4 w-4" />
                Check-in Member
              </Button>
            </Link>
            <Link href="/payments?action=new">
              <Button className="w-full justify-start bg-transparent" variant="outline">
                <DollarSign className="mr-2 h-4 w-4" />
                Record Payment
              </Button>
            </Link>
          </div>
        </Card>

        <Card className="p-6">
          <div className="mb-4 flex items-center justify-between">
            <h2 className="text-lg font-semibold">Alerts & Notifications</h2>
            <AlertCircle className="h-5 w-5 text-warning" />
          </div>
          <div className="space-y-4">
            {stats.expiringMemberships > 0 && (
              <div className="rounded-lg border border-warning/20 bg-warning/10 p-4">
                <p className="text-sm font-medium text-warning">
                  {stats.expiringMemberships} membership{stats.expiringMemberships > 1 ? "s" : ""} expiring in 30 days
                </p>
                <Link href="/members?filter=expiring">
                  <Button variant="link" className="h-auto p-0 text-warning">
                    View members →
                  </Button>
                </Link>
              </div>
            )}
            {stats.newGuests > 0 && (
              <div className="rounded-lg border border-primary/20 bg-primary/10 p-4">
                <p className="text-sm font-medium text-primary">
                  {stats.newGuests} new guest{stats.newGuests > 1 ? "s" : ""} need follow-up
                </p>
                <Link href="/guests">
                  <Button variant="link" className="h-auto p-0 text-primary">
                    View guests →
                  </Button>
                </Link>
              </div>
            )}
            {stats.expiringMemberships === 0 && stats.newGuests === 0 && (
              <p className="text-sm text-muted-foreground">No alerts at this time</p>
            )}
          </div>
        </Card>
      </div>

      <Card className="mt-8 p-6">
        <h2 className="mb-4 text-lg font-semibold">Recent Activity</h2>
        <div className="space-y-4">
          <div className="flex items-start gap-4 rounded-lg border border-border p-4">
            <div className="rounded-full bg-success/10 p-2">
              <Users className="h-4 w-4 text-success" />
            </div>
            <div className="flex-1">
              <p className="text-sm font-medium">New member joined</p>
              <p className="text-sm text-muted-foreground">Ahmed Hassan signed up for Premium Quarterly plan</p>
              <p className="mt-1 text-xs text-muted-foreground">2 hours ago</p>
            </div>
          </div>
          <div className="flex items-start gap-4 rounded-lg border border-border p-4">
            <div className="rounded-full bg-primary/10 p-2">
              <DollarSign className="h-4 w-4 text-primary" />
            </div>
            <div className="flex-1">
              <p className="text-sm font-medium">Payment received</p>
              <p className="text-sm text-muted-foreground">3,240 EGP for membership renewal</p>
              <p className="mt-1 text-xs text-muted-foreground">5 hours ago</p>
            </div>
          </div>
        </div>
      </Card>
    </div>
  )
}
