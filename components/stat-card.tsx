import type { LucideIcon } from "lucide-react"
import { Card } from "@/components/ui/card"

interface StatCardProps {
  title: string
  value: string | number
  icon: LucideIcon
  trend?: {
    value: number
    isPositive: boolean
  }
  subtitle?: string
}

export function StatCard({ title, value, icon: Icon, trend, subtitle }: StatCardProps) {
  return (
    <Card className="p-6">
      <div className="flex items-start justify-between">
        <div className="flex-1">
          <p className="text-sm font-medium text-muted-foreground">{title}</p>
          <p className="mt-2 text-3xl font-semibold">{value}</p>
          {subtitle && <p className="mt-1 text-sm text-muted-foreground">{subtitle}</p>}
        </div>
        <div className="rounded-lg bg-primary/10 p-3">
          <Icon className="h-6 w-6 text-primary" />
        </div>
      </div>
      {trend && (
        <div className="mt-4 flex items-center gap-1 text-sm">
          <span className={trend.isPositive ? "text-success" : "text-destructive"}>
            {trend.isPositive ? "+" : ""}
            {trend.value}%
          </span>
          <span className="text-muted-foreground">from last month</span>
        </div>
      )}
    </Card>
  )
}
