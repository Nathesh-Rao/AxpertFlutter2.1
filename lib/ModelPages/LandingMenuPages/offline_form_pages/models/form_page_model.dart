import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/models/form_field_model.dart';

class OfflineFormPageModel {
  final String transId;
  final String caption;
  final bool visible;
  final bool attachments;
  final List<OfflineFormFieldModel> fields;

  OfflineFormPageModel({
    required this.transId,
    required this.caption,
    required this.visible,
    required this.attachments,
    required this.fields,
  });

  factory OfflineFormPageModel.fromJson(Map<String, dynamic> json) {
    return OfflineFormPageModel(
      transId: json['transid'],
      caption: json['caption'],
      visible: json['visible'] ?? true,
      attachments: json['attachments'] ?? false,
      fields: (json['fields'] as List<dynamic>)
          .map((e) => OfflineFormFieldModel.fromJson(e))
          .toList()
        ..sort(
          (a, b) => a.order.compareTo(b.order),
        ),
    );
  }

  static var tempdata = [
    {
      "transid": "temp1",
      "caption": "Temp Form",
      "visible": true,
      "attachments": true,
      "fields": [
        {
          "order": "1",
          "fld_name": "char_field",
          "fld_caption": "Character Field",
          "fld_type": "c",
          "data_type": "s",
          "hidden": "F",
          "readonly": "F",
          "allowempty": "F",
          "def_value": "default text"
        },
        {
          "order": "2",
          "fld_name": "numeric_field",
          "fld_caption": "Numeric Field",
          "fld_type": "n",
          "data_type": "n",
          "hidden": "F",
          "readonly": "F",
          "allowempty": "F",
          "def_value": "0"
        },
        {
          "order": "3",
          "fld_name": "dropdown_field",
          "fld_caption": "Dropdown Field",
          "fld_type": "dd",
          "data_type": "s",
          "hidden": "F",
          "readonly": "F",
          "allowempty": "F",
          "def_value": "option2",
          "datasource": "DS_F3"
        }
      ]
    },
    {
      "transid": "temp2",
      "caption": "Second Form",
      "visible": true,
      "attachments": false,
      "fields": [
        {
          "order": "1",
          "fld_name": "char_field",
          "fld_caption": "Character Field",
          "fld_type": "c",
          "data_type": "s",
          "hidden": "F",
          "readonly": "F",
          "allowempty": "F",
          "def_value": "default text"
        },
        {
          "order": "2",
          "fld_name": "numeric_field",
          "fld_caption": "Numeric Field",
          "fld_type": "n",
          "data_type": "n",
          "hidden": "F",
          "readonly": "F",
          "allowempty": "F",
          "def_value": "0"
        }
      ]
    },
    {
      "transid": "temp3",
      "caption": "Selection & Boolean Test",
      "visible": true,
      "attachments": false,
      "fields": [
        {
          "order": "1",
          "fld_name": "accept_terms",
          "fld_caption": "Accept Terms",
          "fld_type": "cb",
          "data_type": "b",
          "hidden": "F",
          "readonly": "F",
          "allowempty": "F",
          "def_value": "false"
        },
        {
          "order": "2",
          "fld_name": "skills",
          "fld_caption": "Skills",
          "fld_type": "cl",
          "data_type": "s",
          "hidden": "F",
          "readonly": "F",
          "allowempty": "F",
          "def_value": "",
          "datasource": "DS_SKILLS"
        },
        {
          "fld_name": "gender",
          "order": "3",
          "fld_caption": "Gender",
          "fld_type": "rb",
          "data_type": "s",
          "hidden": "F",
          "readonly": "F",
          "allowempty": "F",
          "def_value": "",
          "datasource": "DS_GENDER"
        }
      ]
    },
    {
      "transid": "temp4",
      "caption": "Date & Memo Test",
      "visible": true,
      "attachments": true,
      "fields": [
        {
          "order": "1",
          "fld_name": "dob",
          "fld_caption": "Date of Birth",
          "fld_type": "d",
          "data_type": "d",
          "hidden": "F",
          "readonly": "F",
          "allowempty": "F",
          "def_value": ""
        },
        {
          "order": "2",
          "fld_name": "remarks",
          "fld_caption": "Remarks",
          "fld_type": "m",
          "data_type": "s",
          "hidden": "F",
          "readonly": "F",
          "allowempty": "T",
          "def_value": ""
        }
      ]
    },
    {
      "transid": "temp5",
      "caption": "Image Test",
      "visible": true,
      "attachments": true,
      "fields": [
        {
          "order": "1",
          "fld_name": "co",
          "fld_caption": "From Camera",
          "fld_type": "image",
          "is_camera": "T",
          "is_gallery": "F",
          "data_type": "d",
          "hidden": "F",
          "readonly": "F",
          "allowempty": "F",
          "def_value": ""
        },
        {
          "order": "2",
          "fld_name": "go",
          "fld_caption": "From Gallery",
          "fld_type": "image",
          "is_camera": "F",
          "is_gallery": "T",
          "data_type": "d",
          "hidden": "F",
          "readonly": "F",
          "allowempty": "F",
          "def_value": ""
        },
        {
          "order": "3",
          "fld_name": "bo",
          "fld_caption": "Both Options",
          "fld_type": "image",
          "is_camera": "T",
          "is_gallery": "T",
          "data_type": "d",
          "hidden": "F",
          "readonly": "F",
          "allowempty": "F",
          "def_value": ""
        },
      ]
    }
  ];
}
