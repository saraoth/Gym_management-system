export type MembershipPlan = {
  id: string
  name: string
  price: number
  duration: number // in months
  benefits: string[]
  sessionsPerWeek?: number
  ptSessions?: number
}

export type Member = {
  id: string
  name: string
  email: string
  phone: string
  address: string
  dateOfBirth: string
  emergencyContact: {
    name: string
    phone: string
    relationship: string
  }
  membershipPlan: string
  membershipStartDate: string
  membershipEndDate: string
  status: "active" | "expired" | "frozen"
  notes: string
  joinDate: string
  photo?: string
  history: MemberHistory[]
}

export type MemberHistory = {
  id: string
  type: "membership_change" | "payment" | "attendance" | "class" | "pt_session" | "note"
  date: string
  description: string
  details?: any
  previousPlan?: string
  newPlan?: string
  amount?: number
}

export type Guest = {
  id: string
  name: string
  phone: string
  email?: string
  source: "walk-in" | "phone" | "social-media" | "referral" | "website"
  interestedPlan?: string
  status: "new" | "contacted" | "visited" | "converted" | "lost"
  notes: string
  followUpDate?: string
  assignedTo?: string
  createdAt: string
  updatedAt: string
  history: GuestHistory[]
}

export type GuestHistory = {
  id: string
  date: string
  action: string
  notes: string
  performedBy: string
}

export type Trainer = {
  id: string
  name: string
  email: string
  phone: string
  specialization: string[]
  hireDate: string
  baseSalary: number
  commissionRate: number // percentage
  status: "active" | "inactive"
  photo?: string
  totalSessions: number
  totalEarnings: number
}

export type Attendance = {
  id: string
  memberId: string
  memberName: string
  checkIn: string
  checkOut?: string
  type: "gym" | "class" | "pt-session"
  classId?: string
  trainerId?: string
}

export type Payment = {
  id: string
  memberId: string
  memberName: string
  amount: number
  type: "membership" | "pt-session" | "class" | "product" | "other"
  method: "cash" | "card" | "bank-transfer"
  status: "completed" | "pending" | "refunded"
  date: string
  notes?: string
  planId?: string
}

export type FinancialReport = {
  period: string
  totalRevenue: number
  membershipRevenue: number
  ptRevenue: number
  otherRevenue: number
  totalExpenses: number
  trainerSalaries: number
  netProfit: number
  newMembers: number
  renewals: number
  cancellations: number
}
