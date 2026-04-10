import type { MembershipPlan, Member, Guest, Trainer, Attendance, Payment } from "./types"

export const membershipPlans: MembershipPlan[] = [
  {
    id: "basic-1",
    name: "Basic Monthly",
    price: 500,
    duration: 1,
    benefits: ["Access to gym equipment", "Locker room access", "3 sessions per week"],
    sessionsPerWeek: 3,
  },
  {
    id: "standard-1",
    name: "Standard Monthly",
    price: 800,
    duration: 1,
    benefits: ["Unlimited gym access", "Locker room access", "Group classes", "Nutrition consultation"],
    sessionsPerWeek: -1, // unlimited
  },
  {
    id: "premium-1",
    name: "Premium Monthly",
    price: 1200,
    duration: 1,
    benefits: ["Unlimited gym access", "All group classes", "4 PT sessions", "Nutrition plan", "Sauna access"],
    sessionsPerWeek: -1,
    ptSessions: 4,
  },
  {
    id: "basic-3",
    name: "Basic Quarterly",
    price: 1350,
    duration: 3,
    benefits: ["Access to gym equipment", "Locker room access", "3 sessions per week", "10% discount"],
    sessionsPerWeek: 3,
  },
  {
    id: "standard-3",
    name: "Standard Quarterly",
    price: 2160,
    duration: 3,
    benefits: ["Unlimited gym access", "Group classes", "Nutrition consultation", "10% discount"],
    sessionsPerWeek: -1,
  },
  {
    id: "premium-3",
    name: "Premium Quarterly",
    price: 3240,
    duration: 3,
    benefits: ["Unlimited gym access", "All classes", "12 PT sessions", "Nutrition plan", "Sauna", "10% discount"],
    sessionsPerWeek: -1,
    ptSessions: 12,
  },
  {
    id: "basic-6",
    name: "Basic Semi-Annual",
    price: 2550,
    duration: 6,
    benefits: ["Access to gym equipment", "Locker room access", "3 sessions per week", "15% discount"],
    sessionsPerWeek: 3,
  },
  {
    id: "standard-6",
    name: "Standard Semi-Annual",
    price: 4080,
    duration: 6,
    benefits: ["Unlimited gym access", "Group classes", "Nutrition consultation", "15% discount"],
    sessionsPerWeek: -1,
  },
  {
    id: "premium-6",
    name: "Premium Semi-Annual",
    price: 6120,
    duration: 6,
    benefits: ["Unlimited gym access", "All classes", "24 PT sessions", "Nutrition plan", "Sauna", "15% discount"],
    sessionsPerWeek: -1,
    ptSessions: 24,
  },
  {
    id: "basic-12",
    name: "Basic Annual",
    price: 4800,
    duration: 12,
    benefits: ["Access to gym equipment", "Locker room access", "3 sessions per week", "20% discount"],
    sessionsPerWeek: 3,
  },
  {
    id: "standard-12",
    name: "Standard Annual",
    price: 7680,
    duration: 12,
    benefits: ["Unlimited gym access", "Group classes", "Nutrition consultation", "20% discount"],
    sessionsPerWeek: -1,
  },
  {
    id: "premium-12",
    name: "Premium Annual",
    price: 11520,
    duration: 12,
    benefits: ["Unlimited gym access", "All classes", "48 PT sessions", "Nutrition plan", "Sauna", "20% discount"],
    sessionsPerWeek: -1,
    ptSessions: 48,
  },
]

// Mock data storage
let members: Member[] = []
let guests: Guest[] = []
let trainers: Trainer[] = []
let attendance: Attendance[] = []
let payments: Payment[] = []

// Initialize with sample data
export function initializeSampleData() {
  members = [
    {
      id: "1",
      name: "Ahmed Hassan",
      email: "ahmed.hassan@email.com",
      phone: "+20 100 123 4567",
      address: "Cairo, Egypt",
      dateOfBirth: "1995-03-15",
      emergencyContact: {
        name: "Sara Hassan",
        phone: "+20 100 765 4321",
        relationship: "Sister",
      },
      membershipPlan: "premium-3",
      membershipStartDate: "2024-11-01",
      membershipEndDate: "2025-02-01",
      status: "active",
      notes: "Interested in weight training",
      joinDate: "2024-11-01",
      history: [],
    },
  ]

  guests = [
    {
      id: "1",
      name: "Mohamed Ali",
      phone: "+20 101 234 5678",
      email: "mohamed.ali@email.com",
      source: "social-media",
      interestedPlan: "standard-1",
      status: "contacted",
      notes: "Interested in starting next month",
      followUpDate: "2025-01-20",
      assignedTo: "Sales Team",
      createdAt: "2025-01-10",
      updatedAt: "2025-01-12",
      history: [],
    },
  ]

  trainers = [
    {
      id: "1",
      name: "Karim Mahmoud",
      email: "karim.trainer@gym.com",
      phone: "+20 102 345 6789",
      specialization: ["Weight Training", "Bodybuilding", "Nutrition"],
      hireDate: "2023-06-01",
      baseSalary: 5000,
      commissionRate: 15,
      status: "active",
      totalSessions: 120,
      totalEarnings: 23000,
    },
  ]

  attendance = [
    {
      id: "1",
      memberId: "1",
      memberName: "Ahmed Hassan",
      checkIn: new Date().toISOString(),
      type: "gym",
    },
  ]

  payments = [
    {
      id: "1",
      memberId: "1",
      memberName: "Ahmed Hassan",
      amount: 3240,
      type: "membership",
      method: "card",
      status: "completed",
      date: new Date().toISOString(),
      planId: "premium-3",
    },
  ]
}

// Data service functions
export const dataService = {
  // Members
  getMembers: () => members,
  getMember: (id: string) => members.find((m) => m.id === id),
  addMember: (member: Member) => {
    members.push(member)
    return member
  },
  updateMember: (id: string, updates: Partial<Member>) => {
    const index = members.findIndex((m) => m.id === id)
    if (index !== -1) {
      members[index] = { ...members[index], ...updates }
      return members[index]
    }
    return null
  },
  deleteMember: (id: string) => {
    members = members.filter((m) => m.id !== id)
  },
  searchMembers: (query: string) => {
    const q = query.toLowerCase()
    return members.filter(
      (m) => m.name.toLowerCase().includes(q) || m.email.toLowerCase().includes(q) || m.phone.includes(q),
    )
  },

  // Guests
  getGuests: () => guests,
  getGuest: (id: string) => guests.find((g) => g.id === id),
  addGuest: (guest: Guest) => {
    guests.push(guest)
    return guest
  },
  updateGuest: (id: string, updates: Partial<Guest>) => {
    const index = guests.findIndex((g) => g.id === id)
    if (index !== -1) {
      guests[index] = { ...guests[index], ...updates }
      return guests[index]
    }
    return null
  },
  deleteGuest: (id: string) => {
    guests = guests.filter((g) => g.id !== id)
  },

  // Trainers
  getTrainers: () => trainers,
  getTrainer: (id: string) => trainers.find((t) => t.id === id),
  addTrainer: (trainer: Trainer) => {
    trainers.push(trainer)
    return trainer
  },
  updateTrainer: (id: string, updates: Partial<Trainer>) => {
    const index = trainers.findIndex((t) => t.id === id)
    if (index !== -1) {
      trainers[index] = { ...trainers[index], ...updates }
      return trainers[index]
    }
    return null
  },

  // Attendance
  getAttendance: () => attendance,
  addAttendance: (record: Attendance) => {
    attendance.push(record)
    return record
  },
  checkOut: (id: string, checkOutTime: string) => {
    const index = attendance.findIndex((a) => a.id === id)
    if (index !== -1) {
      attendance[index].checkOut = checkOutTime
      return attendance[index]
    }
    return null
  },

  // Payments
  getPayments: () => payments,
  addPayment: (payment: Payment) => {
    payments.push(payment)
    return payment
  },

  // Plans
  getPlans: () => membershipPlans,
  getPlan: (id: string) => membershipPlans.find((p) => p.id === id),
}
