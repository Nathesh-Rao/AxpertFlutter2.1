import 'dart:convert';

class TempOfflineDatasources {
  TempOfflineDatasources._();

  // MOCK API DELAY
  static Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 1200));
  }

  // OFFLINE PAGES (MOCK)
  static Future<String> fetchOfflinePages() async {
    await _delay();
    return jsonEncode(_offlinePagesJson);
  }

  // DATASOURCE VALUES (MOCK)
  static Future<String> fetchDatasource(String datasource) async {
    await _delay();

    final options = _datasourceOptions[datasource] ?? [];

    return jsonEncode({
      "data": options,
    });
  }

  // SUBMIT FORM (MOCK)
  static Future<String> submitOfflineForm(Map<String, dynamic> payload) async {
    await _delay();

    // Always success for now
    return jsonEncode({
      "status": "success",
      "message": "Form submitted successfully",
    });
  }

  // MOCK OFFLINE PAGES JSON
  static final List<Map<String, dynamic>> _offlinePagesJson = [
    {
      "transid": "temp1",
      "caption": "Employee Basic Info",
      "visible": true,
      "attachments": false,
      "fields": [
        _text("emp_name", "Employee Name", 1),
        _number("emp_age", "Age", 2),
        _dropdown("emp_dept", "Department", 3, "DS_DEPT"),
        _radio("emp_gender", "Gender", 4, "DS_GENDER"),
        _checkbox("emp_skills", "Skills", 5, "DS_SKILLS"),
        _date("emp_doj", "Date of Joining", 6),
        _memo("emp_notes", "Notes", 7),
      ]
    },
    {
      "transid": "temp2",
      "caption": "Project Allocation",
      "visible": true,
      "attachments": false,
      "fields": [
        _dropdown("project", "Project", 1, "DS_PROJECT"),
        _radio("role", "Role", 2, "DS_ROLE"),
        _number("experience", "Experience (Years)", 3),
        _checkbox("tools", "Tools Used", 4, "DS_TOOLS"),
        _date("start_date", "Start Date", 5),
        _memo("remarks", "Remarks", 6),
        _boolean("billable", "Billable", 7),
      ]
    },
    {
      "transid": "temp3",
      "caption": "HR Declaration",
      "visible": true,
      "attachments": false,
      "fields": [
        _boolean("accept_policy", "Accept Policy", 1),
        _dropdown("employment_type", "Employment Type", 2, "DS_EMP_TYPE"),
        _radio("work_mode", "Work Mode", 3, "DS_WORK_MODE"),
        _checkbox("benefits", "Benefits", 4, "DS_BENEFITS"),
        _date("confirm_date", "Confirmation Date", 5),
        _memo("comments", "Comments", 6),
        _number("notice_period", "Notice Period", 7),
      ]
    },
    {
      "transid": "temp4",
      "caption": "Image Upload Test",
      "visible": true,
      "attachments": true,
      "fields": [
        _image("camera_only", "Camera Only", 1, true, false),
        _image("gallery_only", "Gallery Only", 2, false, true),
        _image("both", "Camera & Gallery", 3, true, true),
        _dropdown("doc_type", "Document Type", 4, "DS_DOC_TYPE"),
        _radio("visibility", "Visibility", 5, "DS_VISIBILITY"),
        _memo("remarks", "Remarks", 6),
        _boolean("agree", "Agree", 7),
      ]
    },
  ];

  // MOCK DATASOURCE OPTIONS
  static final Map<String, List<String>> _datasourceOptions = {
    "DS_GENDER": ["Male", "Female", "Other"],
    "DS_DEPT": ["Engineering", "HR", "Finance", "QA"],
    "DS_SKILLS": ["Flutter", "Dart", "Java", "SQL"],
    "DS_PROJECT": ["Apollo", "Hermes", "Atlas"],
    "DS_ROLE": ["Developer", "Tester", "Manager"],
    "DS_TOOLS": ["Git", "Jira", "Figma"],
    "DS_EMP_TYPE": ["Permanent", "Contract"],
    "DS_WORK_MODE": ["Office", "Remote", "Hybrid"],
    "DS_BENEFITS": ["PF", "Insurance", "Bonus"],
    "DS_DOC_TYPE": ["ID Proof", "Address Proof"],
    "DS_VISIBILITY": ["Public", "Private"],
  };

  // FIELD BUILDERS (HELPERS)
  static Map<String, dynamic> _baseField(
    String name,
    String caption,
    int order,
    String type,
    String dataType,
  ) =>
      {
        "order": order.toString(),
        "fld_name": name,
        "fld_caption": caption,
        "fld_type": type,
        "data_type": dataType,
        "hidden": "F",
        "readonly": "F",
        "allowempty": "F",
        "def_value": "",
      };

  static Map<String, dynamic> _text(String n, String c, int o) =>
      _baseField(n, c, o, "c", "s");

  static Map<String, dynamic> _number(String n, String c, int o) =>
      _baseField(n, c, o, "n", "n");

  static Map<String, dynamic> _date(String n, String c, int o) =>
      _baseField(n, c, o, "d", "d");

  static Map<String, dynamic> _memo(String n, String c, int o) =>
      _baseField(n, c, o, "m", "s");

  static Map<String, dynamic> _boolean(String n, String c, int o) =>
      _baseField(n, c, o, "cb", "b");

  static Map<String, dynamic> _dropdown(String n, String c, int o, String ds) =>
      {
        ..._baseField(n, c, o, "dd", "s"),
        "datasource": ds,
      };

  static Map<String, dynamic> _radio(String n, String c, int o, String ds) => {
        ..._baseField(n, c, o, "rb", "s"),
        "datasource": ds,
      };

  static Map<String, dynamic> _checkbox(String n, String c, int o, String ds) =>
      {
        ..._baseField(n, c, o, "cl", "s"),
        "datasource": ds,
      };

  static Map<String, dynamic> _image(
    String n,
    String c,
    int o,
    bool camera,
    bool gallery,
  ) =>
      {
        ..._baseField(n, c, o, "image", "d"),
        "is_camera": camera ? "T" : "F",
        "is_gallery": gallery ? "T" : "F",
      };
}
