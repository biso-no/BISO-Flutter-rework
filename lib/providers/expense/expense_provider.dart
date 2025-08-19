import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/expense_model.dart';
import '../../data/services/expense_service_v2.dart';
import '../../core/logging/print_migration.dart';

// Service provider
final expenseServiceProvider = Provider<ExpenseServiceV2>(
  (ref) => ExpenseServiceV2(),
);

// Expenses state provider
final expensesStateProvider =
    StateNotifierProvider<ExpensesNotifier, ExpensesState>((ref) {
      return ExpensesNotifier(ref.watch(expenseServiceProvider));
    });

// Filtered expenses provider
final filteredExpensesProvider = Provider.family<List<ExpenseModel>, String>((
  ref,
  status,
) {
  final expensesState = ref.watch(expensesStateProvider);
  if (status == 'all') {
    return expensesState.expenses;
  }
  return expensesState.expenses
      .where((expense) => expense.status == status)
      .toList();
});

// Expense statistics provider
final expenseStatisticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final service = ref.watch(expenseServiceProvider);
  return service.getExpenseStatistics();
});

class ExpensesState {
  final List<ExpenseModel> expenses;
  final bool isLoading;
  final String? error;
  final ExpenseModel? selectedExpense;

  const ExpensesState({
    this.expenses = const [],
    this.isLoading = false,
    this.error,
    this.selectedExpense,
  });

  ExpensesState copyWith({
    List<ExpenseModel>? expenses,
    bool? isLoading,
    String? error,
    ExpenseModel? selectedExpense,
  }) {
    return ExpensesState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedExpense: selectedExpense ?? this.selectedExpense,
    );
  }

  // Calculate totals by status
  double get totalPendingAmount =>
      expenses.where((e) => e.isPending).fold(0.0, (sum, e) => sum + e.total);

  double get totalApprovedAmount =>
      expenses.where((e) => e.isApproved).fold(0.0, (sum, e) => sum + e.total);

  double get totalRejectedAmount =>
      expenses.where((e) => e.isRejected).fold(0.0, (sum, e) => sum + e.total);

  double get totalPaidAmount =>
      expenses.where((e) => e.isPaid).fold(0.0, (sum, e) => sum + e.total);

  // Count by status
  int get pendingCount => expenses.where((e) => e.isPending).length;
  int get approvedCount => expenses.where((e) => e.isApproved).length;
  int get rejectedCount => expenses.where((e) => e.isRejected).length;
  int get paidCount => expenses.where((e) => e.isPaid).length;
}

class ExpensesNotifier extends StateNotifier<ExpensesState> {
  final ExpenseServiceV2 _service;

  ExpensesNotifier(this._service) : super(const ExpensesState()) {
    loadUserExpenses();
  }

  /// Load user expenses
  Future<void> loadUserExpenses({String? userId}) async {
    try {
      logPrint('💰 ExpensesNotifier: Loading user expenses');
      state = state.copyWith(isLoading: true, error: null);

      final expenses = await _service.getUserExpenses(userId: userId);

      logPrint('💰 ExpensesNotifier: Loaded ${expenses.length} expenses');
      state = state.copyWith(expenses: expenses, isLoading: false, error: null);
    } catch (e) {
      logPrint('💰 ExpensesNotifier: Failed to load expenses: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load expenses: $e',
      );
    }
  }

  /// Load expenses filtered by status
  Future<void> loadExpensesByStatus(String status, {String? userId}) async {
    try {
      logPrint('💰 ExpensesNotifier: Loading expenses with status: $status');
      state = state.copyWith(isLoading: true, error: null);

      final expenses = await _service.getExpensesByStatus(
        status,
        userId: userId,
      );

      state = state.copyWith(expenses: expenses, isLoading: false, error: null);
    } catch (e) {
      logPrint('💰 ExpensesNotifier: Failed to load expenses by status: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load expenses: $e',
      );
    }
  }

  /// Load a specific expense
  Future<void> loadExpense(String expenseId) async {
    try {
      logPrint('💰 ExpensesNotifier: Loading expense $expenseId');

      final expense = await _service.getExpense(expenseId);

      if (expense != null) {
        state = state.copyWith(selectedExpense: expense);

        // Also update the expense in the list if it exists
        final updatedExpenses = state.expenses.map((e) {
          return e.id == expenseId ? expense : e;
        }).toList();

        state = state.copyWith(expenses: updatedExpenses);
      }
    } catch (e) {
      logPrint('💰 ExpensesNotifier: Failed to load expense: $e');
      state = state.copyWith(error: 'Failed to load expense: $e');
    }
  }

  /// Create a new expense
  Future<ExpenseModel?> createExpense({
    required String campus,
    required String department,
    required String bankAccount,
    String? description,
    required double total,
    double? prepaymentAmount,
    String status = 'pending',
    String? eventName,
  }) async {
    try {
      logPrint('💰 ExpensesNotifier: Creating expense');
      state = state.copyWith(isLoading: true, error: null);

      final expense = await _service.createExpense(
        campus: campus,
        department: department,
        bankAccount: bankAccount,
        description: description,
        total: total,
        prepaymentAmount: prepaymentAmount,
        status: status,
        eventName: eventName,
      );

      // Add to the list
      final updatedExpenses = [expense, ...state.expenses];
      state = state.copyWith(
        expenses: updatedExpenses,
        isLoading: false,
        error: null,
      );

      logPrint('💰 ExpensesNotifier: Created expense ${expense.id}');
      return expense;
    } catch (e) {
      logPrint('💰 ExpensesNotifier: Failed to create expense: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create expense: $e',
      );
      return null;
    }
  }

  /// Update an existing expense
  Future<ExpenseModel?> updateExpense({
    required String expenseId,
    String? campus,
    String? department,
    String? bankAccount,
    String? description,
    double? total,
    double? prepaymentAmount,
    String? status,
    String? eventName,
  }) async {
    try {
      logPrint('💰 ExpensesNotifier: Updating expense $expenseId');
      state = state.copyWith(isLoading: true, error: null);

      final expense = await _service.updateExpense(
        expenseId: expenseId,
        campus: campus,
        department: department,
        bankAccount: bankAccount,
        description: description,
        total: total,
        prepaymentAmount: prepaymentAmount,
        status: status,
        eventName: eventName,
      );

      // Update in the list
      final updatedExpenses = state.expenses.map((e) {
        return e.id == expenseId ? expense : e;
      }).toList();

      state = state.copyWith(
        expenses: updatedExpenses,
        selectedExpense: expense,
        isLoading: false,
        error: null,
      );

      logPrint('💰 ExpensesNotifier: Updated expense $expenseId');
      return expense;
    } catch (e) {
      logPrint('💰 ExpensesNotifier: Failed to update expense: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update expense: $e',
      );
      return null;
    }
  }

  /// Delete an expense
  Future<bool> deleteExpense(String expenseId) async {
    try {
      logPrint('💰 ExpensesNotifier: Deleting expense $expenseId');
      state = state.copyWith(isLoading: true, error: null);

      await _service.deleteExpense(expenseId);

      // Remove from the list
      final updatedExpenses = state.expenses
          .where((e) => e.id != expenseId)
          .toList();

      state = state.copyWith(
        expenses: updatedExpenses,
        selectedExpense: state.selectedExpense?.id == expenseId
            ? null
            : state.selectedExpense,
        isLoading: false,
        error: null,
      );

      logPrint('💰 ExpensesNotifier: Deleted expense $expenseId');
      return true;
    } catch (e) {
      logPrint('💰 ExpensesNotifier: Failed to delete expense: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete expense: $e',
      );
      return false;
    }
  }

  /// Refresh expenses
  Future<void> refresh() async {
    await loadUserExpenses();
  }

  /// Clear selected expense
  void clearSelectedExpense() {
    state = state.copyWith(selectedExpense: null);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
