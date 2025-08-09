import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class CreateExpenseScreen extends ConsumerStatefulWidget {
  final String? eventId;
  final String? eventName;

  const CreateExpenseScreen({
    super.key,
    this.eventId,
    this.eventName,
  });

  @override
  ConsumerState<CreateExpenseScreen> createState() => _CreateExpenseScreenState();
}

class _CreateExpenseScreenState extends ConsumerState<CreateExpenseScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Form data
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _accountHolderController = TextEditingController();
  
  String _selectedCategory = 'other';
  String? _selectedDepartmentId;
  String _selectedDepartmentName = '';
  bool _isPrepayment = false;
  DateTime _expenseDate = DateTime.now();
  final List<File> _attachedFiles = [];
  
  final List<String> _categories = [
    'event',
    'travel', 
    'supplies',
    'food',
    'other',
  ];
  
  final List<Map<String, String>> _departments = [
    {'id': 'marketing', 'name': 'Marketing Committee'},
    {'id': 'student_services', 'name': 'Student Services'},
    {'id': 'student_union', 'name': 'Student Union'},
    {'id': 'it_services', 'name': 'IT Services'},
    {'id': 'career_center', 'name': 'Career Center'},
    {'id': 'events_team', 'name': 'Events Team'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) {
      _selectedCategory = 'event';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _bankAccountController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      if (_validateCurrentStep()) {
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Basic Info
        return _formKey.currentState?.validate() ?? false;
      case 1: // Department
        return _selectedDepartmentId != null;
      case 2: // Attachments
        return _attachedFiles.isNotEmpty || _isPrepayment;
      case 3: // Payment Details
        return _bankAccountController.text.isNotEmpty && 
               _accountHolderController.text.isNotEmpty;
      case 4: // Review
        return true;
      default:
        return true;
    }
  }

  Future<void> _submitExpense() async {
    // TODO: Create expense with Appwrite
    // For now, just show success message
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense created successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Expense'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
        actions: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _previousStep,
              child: const Text('Back'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress Indicator
          LinearProgressIndicator(
            value: (_currentStep + 1) / 5,
            backgroundColor: AppColors.gray200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.orange9),
          ),
          
          // Step Indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Step ${_currentStep + 1} of 5',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '• ${_getStepTitle()}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.orange9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  _buildBasicInfoStep(),
                  _buildDepartmentSelectionStep(),
                  _buildAttachmentsStep(),
                  _buildPaymentDetailsStep(),
                  _buildReviewStep(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0: return 'Basic Information';
      case 1: return 'Department';
      case 2: return 'Receipts';
      case 3: return 'Payment Details';
      case 4: return 'Review & Submit';
      default: return '';
    }
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tell us about your expense',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Amount
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Amount (NOK)',
              prefixIcon: Icon(Icons.attach_money),
              hintText: '0.00',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Amount is required';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Please enter a valid amount';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Description
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              prefixIcon: Icon(Icons.description),
              hintText: 'What was this expense for?',
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Description is required';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Category
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(Icons.category),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(_getCategoryDisplayName(category)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedCategory = value!);
            },
          ),

          const SizedBox(height: 16),

          // Expense Date
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Expense Date'),
            subtitle: Text(_formatDate(_expenseDate)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _expenseDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() => _expenseDate = date);
              }
            },
            contentPadding: EdgeInsets.zero,
          ),

          const SizedBox(height: 16),

          // Prepayment Toggle
          SwitchListTile(
            title: const Text('Prepayment Request'),
            subtitle: const Text('Request advance payment for future expense'),
            value: _isPrepayment,
            onChanged: (value) => setState(() => _isPrepayment = value),
            contentPadding: EdgeInsets.zero,
          ),

          if (widget.eventName != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.subtleBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event, color: AppColors.defaultBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Related Event',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.defaultBlue,
                          ),
                        ),
                        Text(
                          widget.eventName!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.defaultBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: _nextStep,
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentSelectionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Which department should approve this?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the department responsible for this expense',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          ...(_departments.map<Widget>((dept) {
            final isSelected = _selectedDepartmentId == dept['id'];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: isSelected ? AppColors.subtleBlue : null,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedDepartmentId = dept['id'];
                    _selectedDepartmentName = dept['name']!;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? AppColors.defaultBlue 
                              : AppColors.gray200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.business,
                          color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          dept['name']!,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.defaultBlue : null,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.defaultBlue,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList()),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _selectedDepartmentId != null ? _nextStep : null,
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Upload receipts and documents',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isPrepayment 
                ? 'For prepayments, you can upload quotes or estimates'
                : 'Upload photos or scans of your receipts',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Upload Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImageFromCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photo'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImageFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('From Gallery'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: _pickDocument,
            icon: const Icon(Icons.attach_file),
            label: const Text('Upload Document (PDF)'),
          ),

          const SizedBox(height: 24),

          // Attached Files List
          if (_attachedFiles.isNotEmpty) ...[
            Text(
              'Attached Files',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            ...(_attachedFiles.asMap().entries.map((entry) {
              final index = entry.key;
              final file = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.gray200,
                    child: Icon(
                      _getFileIcon(file.path),
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  title: Text(
                    file.path.split('/').last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(_getFileSizeText(file)),
                  trailing: IconButton(
                    onPressed: () {
                      setState(() => _attachedFiles.removeAt(index));
                    },
                    icon: const Icon(Icons.delete, color: AppColors.error),
                  ),
                ),
              );
            })),
            
            const SizedBox(height: 24),
          ],

          if (_attachedFiles.isEmpty && !_isPrepayment) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.outline, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.upload_file,
                    size: 48,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No files uploaded yet',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Receipts are required for reimbursement',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          ElevatedButton(
            onPressed: (_attachedFiles.isNotEmpty || _isPrepayment) ? _nextStep : null,
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Payment information',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Where should we send the reimbursement?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Bank Account
          TextFormField(
            controller: _bankAccountController,
            decoration: const InputDecoration(
              labelText: 'Norwegian Bank Account',
              prefixIcon: Icon(Icons.account_balance),
              hintText: '1234 56 78901',
              helperText: '11-digit Norwegian account number',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(AppConstants.bankAccountLength),
              _BankAccountFormatter(),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bank account is required';
              }
              final digits = value.replaceAll(' ', '');
              if (digits.length != AppConstants.bankAccountLength) {
                return 'Must be ${AppConstants.bankAccountLength} digits';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Account Holder Name
          TextFormField(
            controller: _accountHolderController,
            decoration: const InputDecoration(
              labelText: 'Account Holder Name',
              prefixIcon: Icon(Icons.person),
              hintText: 'Full name as registered with bank',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Account holder name is required';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Security Notice
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.subtleBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.security, color: AppColors.defaultBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Secure Processing',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.defaultBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your payment details are encrypted and processed securely',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.defaultBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: _nextStep,
            child: const Text('Continue to Review'),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Review your expense',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please review all information before submitting',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Amount Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.subtleBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Total Amount',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.defaultBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'NOK ${amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.defaultBlue,
                  ),
                ),
                if (_isPrepayment) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.defaultBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Prepayment Request',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.defaultBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Details Cards
          _ReviewSection(
            title: 'Expense Details',
            children: [
              _ReviewItem(label: 'Description', value: _descriptionController.text),
              _ReviewItem(label: 'Category', value: _getCategoryDisplayName(_selectedCategory)),
              _ReviewItem(label: 'Date', value: _formatDate(_expenseDate)),
              _ReviewItem(label: 'Department', value: _selectedDepartmentName),
              if (widget.eventName != null)
                _ReviewItem(label: 'Event', value: widget.eventName!),
            ],
          ),

          const SizedBox(height: 16),

          _ReviewSection(
            title: 'Payment Information',
            children: [
              _ReviewItem(
                label: 'Bank Account', 
                value: _bankAccountController.text,
              ),
              _ReviewItem(
                label: 'Account Holder', 
                value: _accountHolderController.text,
              ),
            ],
          ),

          const SizedBox(height: 16),

          _ReviewSection(
            title: 'Attachments',
            children: [
              _ReviewItem(
                label: 'Files', 
                value: '${_attachedFiles.length} file(s) attached',
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Submit Button
          ElevatedButton.icon(
            onPressed: _submitExpense,
            icon: const Icon(Icons.send),
            label: Text(_isPrepayment ? 'Request Prepayment' : 'Submit for Approval'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'By submitting, you confirm that all information is accurate and you have appropriate receipts.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'event': return 'Event Expenses';
      case 'travel': return 'Travel';
      case 'supplies': return 'Supplies';
      case 'food': return 'Food & Beverages';
      case 'other': return 'Other';
      default: return category;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _getFileIcon(String path) {
    if (path.toLowerCase().endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    } else if (path.toLowerCase().contains('jpg') || 
               path.toLowerCase().contains('png') ||
               path.toLowerCase().contains('jpeg')) {
      return Icons.image;
    }
    return Icons.attach_file;
  }

  String _getFileSizeText(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _attachedFiles.add(File(image.path));
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _attachedFiles.add(File(image.path));
      });
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );
    
    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.first.path!);
      setState(() {
        _attachedFiles.add(file);
      });
    }
  }
}

class _ReviewSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ReviewSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BankAccountFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    if (text.length <= 4) {
      return newValue.copyWith(text: text);
    } else if (text.length <= 6) {
      return newValue.copyWith(
        text: '${text.substring(0, 4)} ${text.substring(4)}',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    } else {
      return newValue.copyWith(
        text: '${text.substring(0, 4)} ${text.substring(4, 6)} ${text.substring(6)}',
        selection: TextSelection.collapsed(offset: text.length + 2),
      );
    }
  }
}