enum TaskStatus { pending, assigned, inProgress, completed, cancelled }

class ProcessingTaskModel {
  final String id;
  final String taskType;
  final String description;
  final List<String> inventoryItemIds;
  final String? assignedWorkerId;
  final TaskStatus status;
  final int priority;
  final DateTime? dueDate;
  final Map<String, dynamic>? completionData;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProcessingTaskModel({
    required this.id,
    required this.taskType,
    required this.description,
    required this.inventoryItemIds,
    this.assignedWorkerId,
    required this.status,
    required this.priority,
    this.dueDate,
    this.completionData,
    this.completedAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProcessingTaskModel.fromJson(Map<String, dynamic> json) {
    return ProcessingTaskModel(
      id: json['id'],
      taskType: json['taskType'],
      description: json['description'],
      inventoryItemIds: List<String>.from(json['inventoryItemIds'] ?? []),
      assignedWorkerId: json['assignedWorkerId'],
      status: TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      priority: json['priority'] ?? 1,
      dueDate: json['dueDate'] != null 
          ? DateTime.parse(json['dueDate']) 
          : null,
      completionData: json['completionData'],
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
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
      'taskType': taskType,
      'description': description,
      'inventoryItemIds': inventoryItemIds,
      'assignedWorkerId': assignedWorkerId,
      'status': status.toString().split('.').last,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'completionData': completionData,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  ProcessingTaskModel copyWith({
    String? id,
    String? taskType,
    String? description,
    List<String>? inventoryItemIds,
    String? assignedWorkerId,
    TaskStatus? status,
    int? priority,
    DateTime? dueDate,
    Map<String, dynamic>? completionData,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProcessingTaskModel(
      id: id ?? this.id,
      taskType: taskType ?? this.taskType,
      description: description ?? this.description,
      inventoryItemIds: inventoryItemIds ?? this.inventoryItemIds,
      assignedWorkerId: assignedWorkerId ?? this.assignedWorkerId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      completionData: completionData ?? this.completionData,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending => status == TaskStatus.pending;
  bool get isAssigned => status == TaskStatus.assigned;
  bool get isInProgress => status == TaskStatus.inProgress;
  bool get isCompleted => status == TaskStatus.completed;
  bool get isCancelled => status == TaskStatus.cancelled;
  bool get isOverdue => dueDate != null && DateTime.now().isAfter(dueDate!) && !isCompleted;
  String get priorityLabel => priority == 1 ? 'Low' : priority == 2 ? 'Medium' : 'High';
} 