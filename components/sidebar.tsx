"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import { Users, UserPlus, Calendar, DollarSign, UserCheck, BarChart3, Dumbbell, LayoutDashboard } from "lucide-react"
import { cn } from "@/lib/utils"

const navigation = [
  { name: "Dashboard", href: "/", icon: LayoutDashboard },
  { name: "Members", href: "/members", icon: Users },
  { name: "Guests & Sales", href: "/guests", icon: UserPlus },
  { name: "Attendance", href: "/attendance", icon: Calendar },
  { name: "Trainers", href: "/trainers", icon: UserCheck },
  { name: "Payments", href: "/payments", icon: DollarSign },
  { name: "Reports", href: "/reports", icon: BarChart3 },
]

export function Sidebar() {
  const pathname = usePathname()

  return (
    <div className="flex h-full w-64 flex-col border-r border-border bg-card">
      <div className="flex h-16 items-center gap-2 border-b border-border px-6">
        <Dumbbell className="h-6 w-6 text-primary" />
        <span className="text-lg font-semibold">GymFlow</span>
      </div>
      <nav className="flex-1 space-y-1 p-4">
        {navigation.map((item) => {
          const isActive = pathname === item.href
          return (
            <Link
              key={item.name}
              href={item.href}
              className={cn(
                "flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors",
                isActive
                  ? "bg-primary text-primary-foreground"
                  : "text-muted-foreground hover:bg-accent hover:text-foreground",
              )}
            >
              <item.icon className="h-5 w-5" />
              {item.name}
            </Link>
          )
        })}
      </nav>
      <div className="border-t border-border p-4">
        <div className="text-xs text-muted-foreground">
          <div>Logged in as</div>
          <div className="mt-1 font-medium text-foreground">Admin User</div>
        </div>
      </div>
    </div>
  )
}
