# Performance & Pattern Opportunities for MovingTasks

Based on analysis of your codebase using the Swift Concurrency, Liquid Glass, List Patterns, Scroll Patterns, and Performance Patterns references, here are specific opportunities to improve your app.

---

## ✅ What You're Already Doing Right

### 1. **Stable Identity in Lists** ✓
Your models use proper UUIDs:
```swift
@Attribute(.unique) var taskId: UUID = UUID()
@Attribute(.unique) var itemId: UUID = UUID()
```
And your ForEach loops use them:
```swift
ForEach(filteredTasks) { task in  // Uses task.id from Identifiable
```

**Why this is good:** Prevents crashes, enables smooth animations, efficient diffing.

---

### 2. **Avoiding Inline Filtering (Mostly)** ✓
In TaskListView, you use a computed property for filtering:
```swift
var filteredTasks: [Task] {
    // Filtering logic
}
```

**Why this is good:** The computed property is re-evaluated only when dependencies change, not on every scroll frame.

---

### 3. **Using LazyVStack** ✓
In TaskListView:
```swift
LazyVStack(spacing: 12) {
    ForEach(filteredTasks) { task in
```

**Why this is good:** Creates views on-demand for performance with large lists.

---

## 🔧 Performance Improvements to Consider

### 1. **Filter Logic Could Be More Efficient**

**Current code in TaskListView:**
```swift
var filteredTasks: [Task] {
    let filteredTasks = tasks
    
    switch selectedSearchType {
        case .none:
            return filteredTasks
        case .category:
            if filterValue == "All" {
                return filteredTasks
            } else {
                return filteredTasks.filter {$0.category.lowercased().contains(filterValue.lowercased())}
            }
        // ... similar for location, priority
    }
}
```

**Issue:** Calling `.lowercased()` on every task on every re-render is wasteful.

**Better approach:**
```swift
var filteredTasks: [Task] {
    guard selectedSearchType != .none, filterValue != "All" else {
        return tasks
    }
    
    let lowercasedFilter = filterValue.lowercased()  // Calculate once
    
    switch selectedSearchType {
    case .none:
        return tasks
    case .category:
        return tasks.filter { $0.category.lowercased().contains(lowercasedFilter) }
    case .location:
        return tasks.filter { $0.location.lowercased().contains(lowercasedFilter) }
    case .priority:
        return tasks.filter { $0.priority.lowercased().contains(lowercasedFilter) }
    case .status:
        if filterValue == "Completed" {
            return tasks.filter { $0.isCompleted }
        } else if filterValue == "Incomplete" {
            return tasks.filter { !$0.isCompleted }
        } else {
            return tasks
        }
    }
}
```

**Performance gain:** Single `.lowercased()` call instead of N calls for N tasks.

---

### 2. **DashboardView: Avoid Repeated Calculations**

**Current code in DashboardView:**
Multiple computed properties calculate stats:
```swift
private var totalSpent: Double {
    var total: Decimal = 0.00
    let purchasedItems = taskItems.filter { $0.wasPurchased }
    for item in purchasedItems {
        total += item.totalPrice
    }
    return NSDecimalNumber(decimal: total).doubleValue
}

private var purchasedItems: Int {
    taskItems.filter { $0.wasPurchased }.count
}
```

**Issue:** `purchasedItems` computed property filters the array AGAIN even though `totalSpent` already filtered it.

**Better approach:**
```swift
// Single source of truth
private var purchasedItemsList: [TaskItem] {
    taskItems.filter { $0.wasPurchased }
}

private var purchasedItems: Int {
    purchasedItemsList.count
}

private var totalSpent: Double {
    let total = purchasedItemsList.reduce(Decimal.zero) { $0 + $1.totalPrice }
    return NSDecimalNumber(decimal: total).doubleValue
}
```

**Performance gain:** Filter once, use many times. Cleaner code, too.

---

### 3. **StatCardView Could Be POD (Plain Old Data)**

**Current code:**
```swift
struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let gradient: [Color]
    
    private var gradientColors: [Color] {
        gradient.map { $0.opacity(0.3) }
    }
    
    var body: some View { ... }
}
```

**Issue:** The computed property `gradientColors` makes this non-POD. SwiftUI will use reflection for diffing instead of fast `memcmp`.

**Better approach:**
```swift
struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let gradient: [Color]
    let gradientOpacity: Double  // Pass opacity directly
    
    var body: some View {
        // Use gradient.map { $0.opacity(gradientOpacity) } inline
    }
}
```

Or keep the computed property but recognize it's a minor trade-off. For this small view, it's probably fine.

**Performance gain:** Marginal for this view, but good pattern to know for expensive views.

---

### 4. **BreakdownSectionView Could Cache Sorted Data**

**Current code in DashboardView:**
```swift
struct BreakdownSectionView: View {
    let data: [String: Int]
    
    var sortedData: [(String, Int)] {
        data.sorted { $0.value > $1.value }
    }
    
    var body: some View {
        // Uses sortedData
    }
}
```

**Issue:** Sorting happens on every re-render. If dashboard updates frequently, this could be wasteful.

**Better approach:**
Pass pre-sorted data:
```swift
// In DashboardView
private var sortedTasksByPriority: [(String, Int)] {
    tasksByPriority.sorted { $0.value > $1.value }
}

// Pass to view
BreakdownSectionView(
    title: "Priority Breakdown",
    icon: "exclamationmark.triangle.fill",
    gradient: [.red, .orange],
    sortedData: sortedTasksByPriority,
    total: totalTasks
)
```

**Performance gain:** Sort once in DashboardView instead of every time the view re-renders.

---

### 5. **Scroll Indicator Pattern**

**Current code in DashboardView:**
```swift
ScrollView {
    // ...
}
.scrollIndicators(.hidden)  // ✓ Modern approach
```

**Status:** ✅ Already following best practice from scroll-patterns.md!

---

### 6. **PurchasedItemsSheet: Avoid Repeated Filtering**

**Current code:**
```swift
struct PurchasedItemsSheet: View {
    let taskItems: [TaskItem]
    
    private var purchasedItemsByTask: [(Task, [TaskItem])] {
        let purchased = taskItems.filter { $0.wasPurchased }
        // Group and process
    }
    
    var body: some View {
        // Uses taskItems.filter { $0.wasPurchased }.count multiple times
    }
}
```

**Better approach:**
```swift
struct PurchasedItemsSheet: View {
    let taskItems: [TaskItem]
    
    private var purchasedItems: [TaskItem] {
        taskItems.filter { $0.wasPurchased }
    }
    
    private var purchasedItemsByTask: [(Task, [TaskItem])] {
        let grouped = Dictionary(grouping: purchasedItems) { $0.task }
        // Continue processing
    }
    
    var body: some View {
        // Use purchasedItems.count instead of filtering again
    }
}
```

**Performance gain:** Single filter pass, reuse result.

---

## 🎨 Design Enhancement Opportunities

### 1. **Consider Liquid Glass for iOS 26+**

**Where it would look amazing:**
- Stat cards in DashboardView
- Task row cards
- Toolbar buttons
- Breakdown section cards

**Example for StatCardView:**
```swift
struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let gradient: [Color]
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
            Text(value)
            Text(title)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .glassEffectWithFallback(.regular, in: .rect(cornerRadius: 12))
    }
}

// Helper extension
extension View {
    @ViewBuilder
    func glassEffectWithFallback(
        _ style: GlassEffectStyle = .regular,
        in shape: some Shape = .rect,
        fallbackMaterial: Material = .ultraThinMaterial
    ) -> some View {
        if #available(iOS 26, *) {
            self.glassEffect(style, in: shape)
        } else {
            self.background(fallbackMaterial, in: shape)
        }
    }
}
```

**Benefit:** Modern Apple design language when available, graceful fallback for older iOS.

---

### 2. **ScrollViewReader for "Scroll to Top"**

**Opportunity:** In TaskListView, add a "scroll to top" button when user scrolls down.

**Implementation:**
```swift
struct TaskListView: View {
    @State private var showScrollToTop = false
    private let topID = "top"
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    Color.clear
                        .frame(height: 1)
                        .id(topID)
                    
                    ForEach(filteredTasks) { task in
                        // Task rows
                    }
                }
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(
                                key: ScrollOffsetKey.self,
                                value: geometry.frame(in: .named("scroll")).minY
                            )
                    }
                )
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetKey.self) { offset in
                let shouldShow = offset < -200  // Scrolled down 200pts
                if shouldShow != showScrollToTop {
                    withAnimation {
                        showScrollToTop = shouldShow
                    }
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if showScrollToTop {
                    Button {
                        withAnimation {
                            proxy.scrollTo(topID, anchor: .top)
                        }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                            .background(Circle().fill(.blue))
                    }
                    .padding()
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }
}

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
```

**Benefit:** Better UX for long task lists.

---

## 🧪 Testing Recommendations

### 1. **Add Swift Testing for Business Logic**

**What to test:**
- Task.totalCost calculation
- TaskItem.totalPrice with quantity
- Filtering logic
- Enum utilities

**Example:**
```swift
import Testing
@testable import MovingTasks

@Suite("Task Calculations")
struct TaskCalculationTests {
    
    @Test("Total cost sums all item prices")
    func testTotalCost() async throws {
        let task = Task(
            taskTitle: "Test Task",
            taskDescription: "Test",
            location: "Kitchen",
            category: "Cleaning",
            priority: "High"
        )
        
        let item1 = TaskItem(
            itemTitle: "Item 1",
            itemDescription: "",
            price: "10.00",
            quantity: "2",
            url: "",
            wasPurchased: false
        )
        item1.task = task
        
        let item2 = TaskItem(
            itemTitle: "Item 2",
            itemDescription: "",
            price: "5.50",
            quantity: "1",
            url: "",
            wasPurchased: false
        )
        item2.task = task
        
        let total = task.taskItemsArray.reduce(Decimal.zero) { $0 + $1.totalPrice }
        
        #expect(total == Decimal(string: "25.50"))
    }
    
    @Test("Completed percentage calculates correctly")
    func testCompletionPercentage() {
        let tasks = [
            Task(/* ... */, isCompleted: true),
            Task(/* ... */, isCompleted: true),
            Task(/* ... */, isCompleted: false),
            Task(/* ... */, isCompleted: false),
        ]
        
        let completedCount = tasks.filter { $0.isCompleted }.count
        let percentage = Double(completedCount) / Double(tasks.count) * 100
        
        #expect(percentage == 50.0)
    }
}
```

---

## 📋 Summary Checklist

### High Priority (Do Soon)
- [ ] Optimize filtering logic in TaskListView (cache `.lowercased()`)
- [ ] Consolidate `purchasedItems` filtering in DashboardView
- [ ] Cache sorted data in BreakdownSectionView

### Medium Priority (Nice to Have)
- [ ] Add scroll-to-top button in TaskListView
- [ ] Consider Liquid Glass for iOS 26+ with fallbacks
- [ ] Add unit tests for calculation logic

### Low Priority (Polish)
- [ ] Make StatCardView POD (or document why not)
- [ ] Profile with Instruments to find actual bottlenecks
- [ ] Add `Self._printChanges()` temporarily to debug any unexpected re-renders

---

## 🎯 Performance Testing Strategy

### Step 1: Create Stress Test Data
Add a function to generate 100+ tasks with 10+ items each:
```swift
static func stressTestData() -> [Task] {
    (1...100).map { index in
        let task = Task(
            taskTitle: "Task \(index)",
            taskDescription: "Description \(index)",
            location: LocationEnum.allCases.randomElement()!.rawValue,
            category: CategoryEnum.allCases.randomElement()!.rawValue,
            priority: PriorityEnum.allCases.randomElement()!.rawValue
        )
        
        (1...10).forEach { itemIndex in
            let item = TaskItem(
                itemTitle: "Item \(itemIndex)",
                itemDescription: "Description",
                price: "\(Double.random(in: 5...100))",
                quantity: "\(Int.random(in: 1...5))",
                url: "",
                wasPurchased: Bool.random()
            )
            item.task = task
        }
        
        return task
    }
}
```

### Step 2: Load and Profile
1. Run app with stress test data
2. Open Instruments (Cmd+I in Xcode)
3. Use SwiftUI template
4. Look for:
   - Excessive view body evaluations
   - Long-running computed properties
   - Memory leaks

### Step 3: Optimize Hot Paths
Focus on code that runs:
- On every scroll frame
- On every keystroke (if you add search)
- When lists update

---

**Remember:** Premature optimization is the root of all evil. Profile first, optimize what's actually slow!

