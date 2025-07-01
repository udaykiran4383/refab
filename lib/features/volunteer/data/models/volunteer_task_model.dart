enum VolunteerTaskStatus { available, assigned, inProgress, completed, cancelled }

class VolunteerTaskModel {
  final String id;
  final String taskTitle;
  final String taskDescription;
  final String taskCategory;
  final String? assignedVolunteerId;
  final VolunteerTaskStatus status;
  final int priority;
  final DateTime? dueDate;
  final DateTime? startDate;
  final DateTime? completedDate;
  final Map<String, dynamic>? completionData;
  final DateTime createdAt;
  final DateTime? updatedAt;

  VolunteerTaskModel({
    required this.id,
    required this.taskTitle,
    required this.taskDescription,
    required this.taskCategory,
    this.assignedVolunteerId,
    required this.status,
    required this.priority,
    this.dueDate,
    this.startDate,
    this.completedDate,
    this.completionData,
    required this.createdAt,
    this.updatedAt,
  });

  factory VolunteerTaskModel.fromJson(Map<String, dynamic> json) {
    return VolunteerTaskModel(
      id: json['id'],
      taskTitle: json['taskTitle'],
      taskDescription: json['taskDescription'],
      taskCategory: json['taskCategory'],
      assignedVolunteerId: json['assignedVolunteerId'],
      status: VolunteerTaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      priority: json['priority'] ?? 1,
      dueDate: json['dueDate'] != null 
          ? DateTime.parse(json['dueDate']) 
          : null,
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate']) 
          : null,
      completedDate: json['completedDate'] != null 
          ? DateTime.parse(json['completedDate']) 
          : null,
      completionData: json['completionData'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskTitle': taskTitle,
      'taskDescription': taskDescription,
      'taskCategory': taskCategory,
      'assignedVolunteerId': assignedVolunteerId,
      'status': status.toString().split('.').last,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'completionData': completionData,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  VolunteerTaskModel copyWith({
    String? id,
    String? taskTitle,
    String? taskDescription,
    String? taskCategory,
    String? assignedVolunteerId,
    VolunteerTaskStatus? status,
    int? priority,
    DateTime? dueDate,
    DateTime? startDate,
    DateTime? completedDate,
    Map<String, dynamic>? completionData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VolunteerTaskModel(
      id: id ?? this.id,
      taskTitle: taskTitle ?? this.taskTitle,
      taskDescription: taskDescription ?? this.taskDescription,
      taskCategory: taskCategory ?? this.taskCategory,
      assignedVolunteerId: assignedVolunteerId ?? this.assignedVolunteerId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      startDate: startDate ?? this.startDate,
      completedDate: completedDate ?? this.completedDate,
      completionData: completionData ?? this.completionData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isAvailable => status == VolunteerTaskStatus.available;
  bool get isAssigned => status == VolunteerTaskStatus.assigned;
  bool get isInProgress => status == VolunteerTaskStatus.inProgress;
  bool get isCompleted => status == VolunteerTaskStatus.completed;
  bool get isCancelled => status == VolunteerTaskStatus.cancelled;
  bool get isOverdue => dueDate != null && DateTime.now().isAfter(dueDate!) && !isCompleted;
  String get priorityLabel => priority == 1 ? 'Low' : priority == 2 ? 'Medium' : 'High';
  String get formattedDueDate => dueDate != null 
      ? '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}'
      : 'No due date';
} 