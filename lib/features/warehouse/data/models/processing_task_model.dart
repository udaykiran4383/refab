enum TaskStatus { pending, assigned, inProgress, completed, cancelled, onHold }
enum TaskType { sorting, cleaning, grading, packaging, qualityCheck, maintenance, inventory }
enum TaskPriority { low, medium, high, urgent }

class ProcessingTaskModel {
  final String id;
  final String warehouseId;
  final TaskType taskType;
  final String description;
  final List<String> inventoryItemIds;
  final String? assignedWorkerId;
  final String? assignedTo;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate;
  final DateTime? startDate;
  final Map<String, dynamic>? completionData;
  final Map<String, dynamic>? progressData;
  final DateTime? completedAt;
  final String? notes;
  final List<String>? dependencies;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProcessingTaskModel({
    required this.id,
    required this.warehouseId,
    required this.taskType,
    required this.description,
    required this.inventoryItemIds,
    this.assignedWorkerId,
    this.assignedTo,
    required this.status,
    required this.priority,
    this.dueDate,
    this.startDate,
    this.completionData,
    this.progressData,
    this.completedAt,
    this.notes,
    this.dependencies,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProcessingTaskModel.fromJson(Map<String, dynamic> json) {
    return ProcessingTaskModel(
      id: json['id'],
      warehouseId: json['warehouseId'],
      taskType: TaskType.values.firstWhere(
        (e) => e.toString().split('.').last == json['taskType'],
        orElse: () => TaskType.sorting,
      ),
      description: json['description'],
      inventoryItemIds: List<String>.from(json['inventoryItemIds'] ?? []),
      assignedWorkerId: json['assignedWorkerId'],
      assignedTo: json['assignedTo'],
      status: TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString().split('.').last == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      dueDate: json['dueDate'] != null 
          ? DateTime.parse(json['dueDate']) 
          : null,
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate']) 
          : null,
      completionData: json['completionData'],
      progressData: json['progressData'],
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      notes: json['notes'],
      dependencies: json['dependencies'] != null 
          ? List<String>.from(json['dependencies'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'warehouseId': warehouseId,
      'taskType': taskType.toString().split('.').last,
      'description': description,
      'inventoryItemIds': inventoryItemIds,
      'assignedWorkerId': assignedWorkerId,
      'assignedTo': assignedTo,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'dueDate': dueDate?.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'completionData': completionData,
      'progressData': progressData,
      'completedAt': completedAt?.toIso8601String(),
      'notes': notes,
      'dependencies': dependencies,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  ProcessingTaskModel copyWith({
    String? id,
    String? warehouseId,
    TaskType? taskType,
    String? description,
    List<String>? inventoryItemIds,
    String? assignedWorkerId,
    String? assignedTo,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    DateTime? startDate,
    Map<String, dynamic>? completionData,
    Map<String, dynamic>? progressData,
    DateTime? completedAt,
    String? notes,
    List<String>? dependencies,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProcessingTaskModel(
      id: id ?? this.id,
      warehouseId: warehouseId ?? this.warehouseId,
      taskType: taskType ?? this.taskType,
      description: description ?? this.description,
      inventoryItemIds: inventoryItemIds ?? this.inventoryItemIds,
      assignedWorkerId: assignedWorkerId ?? this.assignedWorkerId,
      assignedTo: assignedTo ?? this.assignedTo,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      startDate: startDate ?? this.startDate,
      completionData: completionData ?? this.completionData,
      progressData: progressData ?? this.progressData,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      dependencies: dependencies ?? this.dependencies,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending => status == TaskStatus.pending;
  bool get isAssigned => status == TaskStatus.assigned;
  bool get isInProgress => status == TaskStatus.inProgress;
  bool get isCompleted => status == TaskStatus.completed;
  bool get isCancelled => status == TaskStatus.cancelled;
  bool get isOnHold => status == TaskStatus.onHold;
  bool get isOverdue => dueDate != null && DateTime.now().isAfter(dueDate!) && !isCompleted;
  bool get isUrgent => priority == TaskPriority.urgent;
  bool get isHighPriority => priority == TaskPriority.high || priority == TaskPriority.urgent;
  String get priorityLabel => priority.toString().split('.').last;
  String get taskTypeLabel => taskType.toString().split('.').last;
  String get statusLabel => status.toString().split('.').last;
  Duration? get duration => startDate != null && completedAt != null 
      ? completedAt!.difference(startDate!)
      : null;
  String get formattedDuration => duration != null 
      ? '${duration!.inHours}h ${duration!.inMinutes % 60}m'
      : 'N/A';
} 