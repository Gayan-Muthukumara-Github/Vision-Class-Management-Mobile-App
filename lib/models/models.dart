import 'package:cloud_firestore/cloud_firestore.dart';

class Administrator {
  final String id;
  final String username;
  final String password;
  final DateTime createdAt;

  Administrator({
    required this.id,
    required this.username,
    required this.password,
    required this.createdAt,
  });

  factory Administrator.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Administrator(
      id: doc.id,
      username: data['username'] ?? '',
      password: data['password'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'password': password,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class Teacher {
  final String id;
  final String firstName;
  final String lastName;
  final String uniqueId;
  final String nic;
  final String phoneNumber;
  final String address;
  final String username;
  final String password;
  final bool isActive;
  final DateTime createdAt;

  Teacher({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.uniqueId,
    required this.nic,
    required this.phoneNumber,
    required this.address,
    required this.username,
    required this.password,
    this.isActive = true,
    required this.createdAt,
  });

  factory Teacher.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Teacher(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      uniqueId: data['uniqueId'] ?? '',
      nic: data['nic'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      address: data['address'] ?? '',
      username: data['username'] ?? '',
      password: data['password'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'uniqueId': uniqueId,
      'nic': nic,
      'phoneNumber': phoneNumber,
      'address': address,
      'username': username,
      'password': password,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class Student {
  final String id;
  final String firstName;
  final String lastName;
  final String uniqueId;
  final String emergencyContactNo;
  final String relationshipToContact;
  final String school;
  final String address;
  final bool isActive;
  final DateTime createdAt;

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.uniqueId,
    required this.emergencyContactNo,
    required this.relationshipToContact,
    required this.school,
    required this.address,
    this.isActive = true,
    required this.createdAt,
  });

  factory Student.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Student(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      uniqueId: data['uniqueId'] ?? '',
      emergencyContactNo: data['emergencyContactNo'] ?? '',
      relationshipToContact: data['relationshipToContact'] ?? '',
      school: data['school'] ?? '',
      address: data['address'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'uniqueId': uniqueId,
      'emergencyContactNo': emergencyContactNo,
      'relationshipToContact': relationshipToContact,
      'school': school,
      'address': address,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class SchoolYear {
  final String id;
  final String year;
  final DateTime createdAt;

  SchoolYear({
    required this.id,
    required this.year,
    required this.createdAt,
  });

  factory SchoolYear.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return SchoolYear(
      id: doc.id,
      year: data['year'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'year': year,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class Grade {
  final String id;
  final String name;
  final DateTime createdAt;

  Grade({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory Grade.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Grade(
      id: doc.id,
      name: data['name'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class Subject {
  final String id;
  final String name;
  final DateTime createdAt;

  Subject({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory Subject.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Subject(
      id: doc.id,
      name: data['name'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class Classroom {
  final String id;
  final String schoolYearId;
  final String gradeId;
  final String subjectId;
  final String? teacherId;
  final DateTime createdAt;

  Classroom({
    required this.id,
    required this.schoolYearId,
    required this.gradeId,
    required this.subjectId,
    this.teacherId,
    required this.createdAt,
  });

  factory Classroom.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Classroom(
      id: doc.id,
      schoolYearId: data['schoolYearId'] ?? '',
      gradeId: data['gradeId'] ?? '',
      subjectId: data['subjectId'] ?? '',
      teacherId: data['teacherId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'schoolYearId': schoolYearId,
      'gradeId': gradeId,
      'subjectId': subjectId,
      'teacherId': teacherId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class StudentClassroomAssignment {
  final String id;
  final String studentId;
  final String classroomId;
  final DateTime createdAt;

  StudentClassroomAssignment({
    required this.id,
    required this.studentId,
    required this.classroomId,
    required this.createdAt,
  });

  factory StudentClassroomAssignment.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return StudentClassroomAssignment(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      classroomId: data['classroomId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'classroomId': classroomId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class ExamMark {
  final String id;
  final String classroomId;
  final String studentId;
  final String month;
  final String examType;
  final double marks;
  final String? remarks;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String createdBy;
  final String? updatedBy;

  ExamMark({
    required this.id,
    required this.classroomId,
    required this.studentId,
    required this.month,
    required this.examType,
    required this.marks,
    this.remarks,
    required this.createdAt,
    this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  factory ExamMark.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ExamMark(
      id: doc.id,
      classroomId: data['classroomId'] ?? '',
      studentId: data['studentId'] ?? '',
      month: data['month'] ?? '',
      examType: data['examType'] ?? '',
      marks: (data['marks'] ?? 0).toDouble(),
      remarks: data['remarks'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      createdBy: data['createdBy'] ?? '',
      updatedBy: data['updatedBy'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'classroomId': classroomId,
      'studentId': studentId,
      'month': month,
      'examType': examType,
      'marks': marks,
      'remarks': remarks,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }
}